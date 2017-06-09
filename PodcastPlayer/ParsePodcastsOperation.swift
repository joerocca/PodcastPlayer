//
//  ParsePodcastsOperation.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 4/22/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import UIKit

class ParsePodcastsOperation: Operation {
    var podcasts: [Podcast]?
    
    override func main() {
        guard let dataProvider = self.dependencies
            .filter({$0 is SearchPodcastsOperation})
            .first as? SearchPodcastsOperation else {
            
            fatalError()
        }
        
        guard let data = dataProvider.data,
        let json = JSONParser.jsonDictionary(with: data),
        let podcastDicts = json["results"] as? [[String: Any]] else {
            cancel()
            return
        }
    
        var podcasts = [Podcast]()
        for podcastDict in podcastDicts {
            guard let podcast = Podcast.fromJSON(json: podcastDict) else {
                print("Error parsing Podcast")
                continue
            }
            podcasts.append(podcast)
        }
        
        self.podcasts = podcasts
    }
}
