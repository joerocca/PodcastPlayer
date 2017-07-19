//
//  Date+Extras.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 7/19/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation

extension Date {
    func toString(withFormat format: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
