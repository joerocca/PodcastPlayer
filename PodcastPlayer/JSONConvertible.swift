//
//  JSONConvertible.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 4/23/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation

protocol JSONConvertible {
    static func fromJSON(json: [String: Any]) -> Self?
}
