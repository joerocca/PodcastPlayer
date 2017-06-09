//
//  Podcast+JSONConvertible.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 4/23/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation

extension Podcast: JSONConvertible {
    static let releaseDateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    static func fromJSON(json: [String : Any]) -> Podcast? {
        guard let collectionId = json["collectionId"] as? Int,
            let trackId = json["trackId"] as? Int,
            let name = json["collectionName"] as? String,
            let artistName = json["artistName"] as? String,
            let feedUrl = URL(string: json["feedUrl"] as! String),
            let artworkUrl30 = URL(string: json["artworkUrl30"] as! String),
            let artworkUrl60 = URL(string: json["artworkUrl60"] as! String),
            let artworkUrl100 = URL(string: json["artworkUrl100"] as! String),
            let artworkUrl600 = URL(string: json["artworkUrl600"] as! String),
            let releaseDateString = json["releaseDate"] as? String,
            let releaseDate = releaseDateString.toDate(withFormat: releaseDateFormat),
            let trackCount = json["trackCount"] as? Int,
            let genres = json["genres"] as? [String] else {
                return nil
        }
        
        return Podcast(collectionId: collectionId,
                       trackId: trackId,
                       name: name,
                       artistName: artistName,
                       feedUrl: feedUrl,
                       artworkUrl30: artworkUrl30,
                       artworkUrl60: artworkUrl60,
                       artworkUrl100: artworkUrl100,
                       artworkUrl600: artworkUrl600,
                       releaseDate: releaseDate,
                       trackCount: trackCount,
                       genres: genres)
    }
}
