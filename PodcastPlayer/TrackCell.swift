//
//  TrackCell.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 6/6/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation
import UIKit

class TrackCell: UITableViewCell {
    
    //MARK: UI Properties
    fileprivate let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()
    
    fileprivate let publishDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    //MARK: Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //Subviews
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.publishDateLabel)
        self.contentView.addSubview(self.descriptionLabel)
        
        //Constraints
        let viewDict = ["nameLabel": self.nameLabel, "publishDateLabel": self.publishDateLabel, "descriptionLabel": self.descriptionLabel] as [String : Any]
        var allConstraints = [NSLayoutConstraint]()
        
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLabel]-2-[publishDateLabel]-5-[descriptionLabel]", options: [], metrics: nil, views: viewDict)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[nameLabel]-|", options: [], metrics: nil, views: viewDict)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[publishDateLabel]-|", options: [], metrics: nil, views: viewDict)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[descriptionLabel]-|", options: [], metrics: nil, views: viewDict)
        allConstraints.append(self.contentView.bottomAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 8))
        
        NSLayoutConstraint.activate(allConstraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Configuration
    func configure(track: Track) {
        self.nameLabel.text = track.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        guard let formattedDate = dateFormatter.date(from: track.publishDate) else {
            fatalError("Error creating date from publish date string")
        }
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        let formattedDateString = dateFormatter.string(from: formattedDate)
        self.publishDateLabel.text = formattedDateString
        
        self.descriptionLabel.text = track.desc
    }
}

extension TrackCell: ReusableView {}

extension TrackCell: PreferredFont {
    func contentSizeChanged() {
        self.nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        self.publishDateLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        self.descriptionLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
    }
}
