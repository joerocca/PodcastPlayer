//
//  UIImageView+NetworkImageLoader.swift
//  NetworkImageLoader
//
//  Created by Joe Rocca on 6/16/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation
import UIKit

// MARK: Associated Object
private var imageTaskKey: Void?

public extension UIImageView {
    //MARK: Type Aliases
     public typealias setImageCompletion = (UIImage?, Error?) -> Void
    
    //MARK: Properties
    private var imageTask: URLSessionTask? {
        return objc_getAssociatedObject(self, &imageTaskKey) as? URLSessionTask
    }
    
    private func setImageTask(_ task: URLSessionTask?) {
        objc_setAssociatedObject(self, &imageTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    //MARK: Methods
    public func setImage(withUrl url: URL, placeholderImage: UIImage? = nil, forceRefresh: Bool = false, completion: setImageCompletion? = nil) {
        //Check if image is available in memory cache. If image is available, apply it to UIImageView and return.
        if let cachedImage = NetworkImageLoader.shared.imageCache.memoryCachedImage(forKey: url.absoluteString),
            forceRefresh == false {
            self.image = cachedImage
            completion?(cachedImage, nil)
            return
        }
        
        //Apply placeholder image to UIImageView while we are downloading the image.
        if let placeholderImage = placeholderImage {
            self.image = placeholderImage
        }
        
        //Checks if there is an existing task for the UIImageView. If there is an existing task, check if the existing task's url is equal to url of new task and return if so. If the existing task's url is NOT equal to the url of the new task, cancel the task because the UITableViewCell has been reused and the old image no longer needs to be downloaded.
        if let existingTask = self.imageTask {
            if existingTask.originalRequest?.url?.absoluteString == url.absoluteString {
                return
            } else {
                existingTask.cancel()
            }
        }
        
        let imageDownloadCompletionClosure = { [weak self] (image: UIImage?, error: Error?) in
            if let imageView = self,
                let image = image {
                imageView.setImageTask(nil)
                imageView.image = image
            }
            completion?(image, error)
        }
        
        //There is a possibility that the image was downloaded before this is called and a cached image is returned, so we check if task is returned before we add to the task to the UIImageView.
        if let task = NetworkImageLoader.shared.downloadAndCacheImage(withUrl: url, forceRefresh: forceRefresh, completion: imageDownloadCompletionClosure) {
            self.setImageTask(task)
        }
    }
    
    public func cancelImageDownload() {
        self.imageTask?.cancel()
        self.setImageTask(nil)
    }
}
