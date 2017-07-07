//
//  FetchPodcastTracksOperation.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 5/9/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation

class FetchPodcastTracksOperation: AsyncOperation {
    private var feedUrl: URL
    var data: Data?
    
    init(feedUrl: URL) {
        self.feedUrl = feedUrl
        super.init()
    }
    
    override func main() {
        let request = URLRequest(url: feedUrl, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(data!)
            self.data = data
            self.state = .Finished
        }
        task.resume()
    }
}
