//
//  PodcastDetailHeaderCell.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 6/8/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation
import UIKit

class PodcastDetailHeaderCell: UITableViewCell {
    
    //MARK: UI Properties
    let artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5.0
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()
    
    let artistNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //Subviews
        self.contentView.addSubview(self.artworkImageView)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.artistNameLabel)
        
        //Constraints
        let viewDict = ["artworkImageView": self.artworkImageView, "nameLabel": self.nameLabel, "artistNameLabel": self.artistNameLabel] as [String : Any]
        var allConstraints = [NSLayoutConstraint]()
        
        allConstraints.append(artworkImageView.heightAnchor.constraint(equalToConstant: 130))
        allConstraints.append(artworkImageView.widthAnchor.constraint(equalToConstant: 130))
        allConstraints.append(nameLabel.topAnchor.constraint(equalTo: artworkImageView.topAnchor))
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[artworkImageView]", options: [], metrics: nil, views: viewDict)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[nameLabel]-2-[artistNameLabel]", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: viewDict)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[artworkImageView]-10-[nameLabel]-|", options: [], metrics: nil, views: viewDict)
        allConstraints.append(self.contentView.bottomAnchor.constraint(equalTo: self.artworkImageView.bottomAnchor, constant: 8))
        
        NSLayoutConstraint.activate(allConstraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Configuration
    func configure(podcast: Podcast) {
        self.nameLabel.text = podcast.name
        self.artistNameLabel.text = podcast.artistName
        self.artworkImageView.setImage(withUrl: podcast.artworkUrl600)
    }
}

extension PodcastDetailHeaderCell: ReusableView {}

extension PodcastDetailHeaderCell: PreferredFont {
    func contentSizeChanged() {
        self.nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        self.artistNameLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    }
}
