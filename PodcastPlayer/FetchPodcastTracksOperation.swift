//
//  FetchPodcastTracksOperation.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 5/9/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation

class FetchPodcastTracksOperation: AsyncOperation {
    var feedUrl: URL
    var data: Data?
    
    init(feedUrl: URL) {
        self.feedUrl = feedUrl
        super.init()
    }
    
    override func main() {
        let task = URLSession.shared.dataTask(with: feedUrl) { (data, response, error) in
            print(data!)
            self.data = data
            self.state = .Finished
        }
        task.resume()
    }
}
