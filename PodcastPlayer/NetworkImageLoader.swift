//
//  NetworkImageLoader.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 6/8/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation
import UIKit

public class NetworkImageLoader: NSObject {
    //MARK: Properties
    public static let shared = NetworkImageLoader()
    private let imageMemoryCache: NSCache<NSString, UIImage> = {
        let imageCache = NSCache<NSString, UIImage>()
        imageCache.name = "ImageCache"
        imageCache.totalCostLimit = {
            let physicalMemory = ProcessInfo.processInfo.physicalMemory
            let ratio = physicalMemory <= (1024 * 1024 * 512 /* 512 Mb */) ? 0.1 : 0.2
            let limit = physicalMemory / UInt64(1 / ratio)
            let calculatedTotalCostLimit = limit > UInt64(Int.max) ? Int.max : Int(limit)
            return calculatedTotalCostLimit
        }()
        return imageCache
    }()
    private let tasks = NSMapTable<UIImageView, URLSessionTask>.weakToWeakObjects()
    private let sessionDelegateQueue = OperationQueue()
    private lazy var session: URLSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: self.sessionDelegateQueue)
    public var memoryCacheSize: Int {
        get {
            return self.imageMemoryCache.totalCostLimit
        }
        set {
            self.imageMemoryCache.totalCostLimit = newValue
        }
    }
    
    //MARK: Workers
    //Downloads and caches image with URL.
    public func downloadAndCacheImage(withUrl url: URL, imageView: UIImageView, placeholderImage: UIImage? = nil, cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy){
        //Check if image is available in memory cache. If image is available, apply it to UIImageView and return.
        if let cachedImage = NetworkImageLoader.shared.imageMemoryCache.object(forKey: url.absoluteString as NSString) {
            DispatchQueue.main.async {
                imageView.image = cachedImage
            }
            return
        }
        
        //Apply placeholder image to UIImageView while we are downloading the image.
        if let placeholderImage = placeholderImage {
            imageView.image = placeholderImage
        }
        
        //Checks if there is an existing task for the UIImageView. If there is an existing task, check if the existing task's url is equal to url of new task and return if so. If the existing task's url is NOT equal to the url of the new task, cancel the task because the UITableViewCell has been reused and the old image no longer needs to be downloaded.
        if let existingTask = NetworkImageLoader.shared.tasks.object(forKey: imageView) {
            if existingTask.originalRequest?.url?.absoluteString == url.absoluteString {
                return
            } else {
                existingTask.cancel()
            }
        }
        
        let request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: 30)
        let task = NetworkImageLoader.shared.session.dataTask(with: request) { (data, response, error) in
            guard error == nil,
                response != nil,
                let data = data,
                let image = UIImage(data: data, scale: UIScreen.main.scale) else {
                return
            }
            NetworkImageLoader.shared.imageMemoryCache.setObject(image, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async {
                imageView.image = image
            }
        }
        NetworkImageLoader.shared.tasks.setObject(task, forKey: imageView)
        task.resume()
    }
    
    //If an existing task is available for the given UIImageView, it is canceled. If not, return.
    public func cancelDownloadAndCache(forImageView imageView: UIImageView) {
        guard let existingTask = NetworkImageLoader.shared.tasks.object(forKey: imageView) else {
            return
        }
        existingTask.cancel()
    }
    
    //Downloads image and stores in cache for later use.
    public func prefetchImage(withUrl url: URL) {
        guard NetworkImageLoader.shared.imageMemoryCache.object(forKey: url.absoluteString as NSString) == nil else {
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 30)
        let task = NetworkImageLoader.shared.session.dataTask(with: request) { (data, response, error) in
            guard error == nil,
                response != nil,
                let data = data,
                let image = UIImage(data: data, scale: UIScreen.main.scale) else {
                    return
            }
            NetworkImageLoader.shared.imageMemoryCache.setObject(image, forKey: url.absoluteString as NSString)
        }
        task.resume()
    }
}

extension NetworkImageLoader: URLSessionDelegate {}

extension NetworkImageLoader: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        //If response is valid, force it to be cached.
        guard let httpUrlResponse = proposedResponse.response as? HTTPURLResponse,
            httpUrlResponse.statusCode >= 200 && httpUrlResponse.statusCode < 300 else {
            return
        }
        let newProposedResponse = CachedURLResponse(response: proposedResponse.response, data: proposedResponse.data, userInfo: proposedResponse.userInfo, storagePolicy: URLCache.StoragePolicy.allowed)
        completionHandler(newProposedResponse)
    }
}
