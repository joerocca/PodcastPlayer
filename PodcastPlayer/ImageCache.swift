//
//  ImageCache.swift
//  NetworkImageLoader
//
//  Created by Joe Rocca on 9/5/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation
import UIKit

public class ImageCache {
    //MARK: Properties
    private let memoryCache: NSCache<NSString, UIImage> = {
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
    public var memoryCacheSize: Int {
        get {
            return self.memoryCache.totalCostLimit
        }
        set {
            self.memoryCache.totalCostLimit = newValue
        }
    }
    
    //MARK: Methods
    //Stores image in memory cache.
    public func store(_ image: UIImage, forKey key: String) {
        self.memoryCache.setObject(image, forKey: key as NSString)
    }
    
    //Returns the UIImage if it is available in the memory cache.
    public func memoryCachedImage(forUrl url: URL) -> UIImage? {
        guard let cachedImage = self.memoryCache.object(forKey: url.absoluteString as NSString) else {
            return nil
        }
        return cachedImage
    }
    
    //Returns the UIImage if it is available in the disk cache.
    public func diskCachedImage(forUrl url: URL) -> UIImage? {
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        guard let diskCachedResponse = URLCache.shared.cachedResponse(for: request),
            let diskCachedImage = UIImage(data: diskCachedResponse.data, scale: UIScreen.main.scale) else {
                return nil
        }
        return diskCachedImage
    }
    
    //Clears memory cache.
    public func clearMemoryCache() {
        self.memoryCache.removeAllObjects()
    }
}
