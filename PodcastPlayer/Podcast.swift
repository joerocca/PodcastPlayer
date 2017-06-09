//
//  Podcast.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 4/23/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation

struct Podcast {
    //MARK: Properties
    let collectionId: Int
    let trackId: Int
    let name: String
    let artistName: String
    let feedUrl: URL
    let artworkUrl30: URL
    let artworkUrl60: URL
    let artworkUrl100: URL
    let artworkUrl600: URL
    let releaseDate: Date
    let trackCount: Int
    let genres: [String]
}
