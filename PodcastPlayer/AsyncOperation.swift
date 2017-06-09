//
//  AsyncOperation.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 4/23/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {
    enum State: String {
        case Ready, Executing, Finished
        
        fileprivate var keyPath: String {
            return "is" + rawValue
        }
    }
    
    var state = State.Ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }
}

extension AsyncOperation {
    override var isReady: Bool {
        return state == .Ready
    }
    
    override var isExecuting: Bool {
        return state == .Executing
    }
    
    override var isFinished: Bool {
        return state == .Finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override func start() {
        if isCancelled {
            state = .Finished
            return
        }
        state = .Executing
        main()
    }
    
    override func cancel() {
        state = .Finished
    }
}
