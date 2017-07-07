//
//  Podcast+JSONConvertible.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 4/23/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation

extension Podcast: JSONConvertible {
    private static let releaseDateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    static func fromJSON(json: [String : Any]) -> Podcast? {
        guard let collectionId = json["collectionId"] as? Int,
            let trackId = json["trackId"] as? Int,
            let name = json["collectionName"] as? String,
            let artistName = json["artistName"] as? String,
            let feedUrlString = json["feedUrl"] as? String,
            let feedUrl = URL(string: feedUrlString),
            let artworkUrl30String = json["artworkUrl30"] as? String,
            let artworkUrl30 = URL(string: artworkUrl30String),
            let artworkUrl60String = json["artworkUrl60"] as? String,
            let artworkUrl60 = URL(string: artworkUrl60String),
            let artworkUrl100String = json["artworkUrl100"] as? String,
            let artworkUrl100 = URL(string: artworkUrl100String),
            let artworkUrl600String = json["artworkUrl600"] as? String,
            let artworkUrl600 = URL(string: artworkUrl600String),
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
