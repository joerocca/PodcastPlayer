/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Shows how to lift operation-like objects in to the NSOperation world.
*/

import Foundation

private var URLSessionTaksOperationKVOContext = 0

class URLSessionTaskOperation: AsyncOperation {
    private let task: URLSessionTask
    
    init(task: URLSessionTask) {
        assert(task.state == .suspended, "Tasks must be suspended.")
        self.task = task
        super.init()
    }
    
    override func main() {
        assert(self.task.state == .suspended, "Task was resumed by something other than \(self).")
        self.task.addObserver(self, forKeyPath: "state", options: [], context: &URLSessionTaksOperationKVOContext)
        self.task.resume()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &URLSessionTaksOperationKVOContext else {
            return
        }
        
        if (object as? URLSessionTask) === self.task && keyPath == "state" && (self.task.state == .completed || self.task.state == .canceling) {
            task.removeObserver(self, forKeyPath: "state")
            self.state = .Finished
        }
    }
    
    override func cancel() {
        self.task.cancel()
        super.cancel()
    }
}
