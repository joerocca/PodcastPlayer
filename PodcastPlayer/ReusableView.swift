//
//  ReusableView.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 5/5/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation
import UIKit

protocol ReusableView: class {}

extension ReusableView where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
