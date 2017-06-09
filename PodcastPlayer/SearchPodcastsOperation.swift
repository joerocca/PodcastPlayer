//
//  SearchPodcastsOperation.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 4/22/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import UIKit

class SearchPodcastsOperation: AsyncOperation {
    var query: String
    var data: Data?
    
    init(query: String) {
        self.query = query
        super.init()
    }
    
    override func main() {
        guard let urlEncodedQuery = self.query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let url = URL(string: "https://itunes.apple.com/search?term=\(urlEncodedQuery)&entity=podcast") else {
            fatalError()
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            self.data = data
            self.state = .Finished
        }
        task.resume()
    }
}
