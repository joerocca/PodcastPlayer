//
//  NetworkImageLoader.swift
//  NetworkImageLoader
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
    public let imageCache = ImageCache()
    private lazy var session: URLSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
    
    //MARK: Methods
    //Downloads and caches image with URL.
    @discardableResult
    public func downloadAndCacheImage(withUrl url: URL, forceRefresh: Bool = false, completion: downloadAndCacheCompletion?) -> URLSessionDataTask? {
        let mainCompletion: downloadAndCacheCompletion = { (image: UIImage?, error: Error?) in
            DispatchQueue.main.async {
                completion?(image, error)
            }
        }
        
        if let cachedImage = self.imageCache.memoryCachedImage(forKey: url.absoluteString),
            forceRefresh == false {
            mainCompletion(cachedImage, nil)
            return nil
        }
        
        let cachePolicy = forceRefresh == false ? URLRequest.CachePolicy.useProtocolCachePolicy : URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        let request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: 30)
        let task = self.session.dataTask(with: request) { (data, response, error) in
            guard error == nil,
                response != nil,
                let data = data,
                let image = UIImage(data: data, scale: UIScreen.main.scale) else {
                    mainCompletion(nil, error)
                    return
            }
            self.imageCache.store(image, forKey: url.absoluteString)
            mainCompletion(image, nil)
        }
        task.resume()
        return task
    }
    
    //Downloads image and stores in cache for later use.
    public func prefetchImage(withUrl url: URL) {
        self.downloadAndCacheImage(withUrl: url, completion: nil)
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
