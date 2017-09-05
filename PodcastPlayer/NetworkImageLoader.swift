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
    //MARK: Type Aliases
    public typealias downloadAndCacheCompletion = (UIImage?, Error?) -> Void
    
    //MARK: Properties
    public static let shared = NetworkImageLoader()
    private let imageMemoryCache: NSCache<NSString, UIImage> = {
        let imageCache = NSCache<NSString, UIImage>()
        imageCache.name = "com.joerocca.NetworkImageLoader.ImageCache"
        imageCache.totalCostLimit = {
            let physicalMemory = ProcessInfo.processInfo.physicalMemory
            let ratio = physicalMemory <= (1024 * 1024 * 512 /* 512 Mb */) ? 0.1 : 0.2
            let limit = physicalMemory / UInt64(1 / ratio)
            let calculatedTotalCostLimit = limit > UInt64(Int.max) ? Int.max : Int(limit)
            return calculatedTotalCostLimit
        }()
        return imageCache
    }()
    private lazy var session: URLSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
    public var memoryCacheSize: Int {
        get {
            return self.imageMemoryCache.totalCostLimit
        }
        set {
            self.imageMemoryCache.totalCostLimit = newValue
        }
    }

    //MARK: Methods
    //Downloads and caches image with URL.
    @discardableResult
    public func downloadAndCacheImage(withUrl url: URL, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, completion: downloadAndCacheCompletion?) -> URLSessionDataTask? {
        let mainCompletion: downloadAndCacheCompletion = { (image: UIImage?, error: Error?) in
            DispatchQueue.main.async {
                completion?(image, error)
            }
        }
        
        if let cachedImage = self.cachedImage(forUrl: url) {
            mainCompletion(cachedImage, nil)
            return nil
        }
        
        let request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: 30)
        let task = NetworkImageLoader.shared.session.dataTask(with: request) { (data, response, error) in
            guard error == nil,
                response != nil,
                let data = data,
                let image = UIImage(data: data, scale: UIScreen.main.scale) else {
                    mainCompletion(nil, error)
                    return
            }
            NetworkImageLoader.shared.imageMemoryCache.setObject(image, forKey: url.absoluteString as NSString)
            mainCompletion(image, nil)
        }
        task.resume()
        return task
    }
    
    //Downloads image and stores in cache for later use.
    public func prefetchImage(withUrl url: URL) {
        self.downloadAndCacheImage(withUrl: url, completion: nil)
    }
    
    //Returns the UIImage if it is available in the NSCache(Memory Cache).
    public func cachedImage(forUrl url: URL) -> UIImage? {
        guard let cachedImage = NetworkImageLoader.shared.imageMemoryCache.object(forKey: url.absoluteString as NSString) else {
            return nil
        }
        return cachedImage
    }
}

extension NetworkImageLoader: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        //If response is valid, force it to be cached.
        guard let httpUrlResponse = proposedResponse.response as? HTTPURLResponse,
            httpUrlResponse.statusCode >= 200 && httpUrlResponse.statusCode < 300 else {
            completionHandler(nil)
            return
        }
        let newProposedResponse = CachedURLResponse(response: proposedResponse.response, data: proposedResponse.data, userInfo: proposedResponse.userInfo, storagePolicy: URLCache.StoragePolicy.allowed)
        completionHandler(newProposedResponse)
    }
}
