//
//  UIImageView+NetworkImageLoader.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 6/16/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation
import UIKit

public extension UIImageView {
    public func setImage(withUrl url: URL, placeholderImage: UIImage? = nil) {
        NetworkImageLoader.shared.downloadAndCacheImage(withUrl: url, imageView: self, placeholderImage: placeholderImage)
    }
    
    public func cancelImageDownload() {
        NetworkImageLoader.shared.cancelDownloadAndCache(forImageView: self)
    }
}
