//
//  PodcastCell.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 5/2/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation
import UIKit

class PodcastCell: UITableViewCell {
    //MARK: UI Element Properties
    var artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5.0
        return imageView
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var artistNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var genresLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.lightGray
        return label
    }()
    
    var mainStackView = UIStackView()
    var innerStackView = UIStackView()
    
    //MARK: Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //Subviews
        self.contentView.addSubview(self.artworkImageView)
        
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
        innerStackView.axis = .vertical
        innerStackView.alignment = .leading
        innerStackView.distribution = .equalCentering
        innerStackView.addArrangedSubview(self.nameLabel)
        innerStackView.addArrangedSubview(self.artistNameLabel)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.alignment = .leading
        mainStackView.distribution = .equalCentering
        mainStackView.addArrangedSubview(innerStackView)
        mainStackView.addArrangedSubview(self.genresLabel)
        self.contentView.addSubview(mainStackView)
        
        //Constraints
        let viewDict = ["artworkImageView": self.artworkImageView, "mainStackView": mainStackView] as [String : Any]
        var allConstraints = [NSLayoutConstraint]()
        
        allConstraints.append(artworkImageView.heightAnchor.constraint(equalToConstant: 64))
        allConstraints.append(artworkImageView.widthAnchor.constraint(equalToConstant: 64))
        allConstraints.append(artworkImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor))
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[mainStackView(>=64)]-|", options: [], metrics: nil, views: viewDict)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[artworkImageView]-10-[mainStackView]-|", options: [], metrics: nil, views: viewDict)
        
        NSLayoutConstraint.activate(allConstraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Configuration
    func configure(podcast: Podcast) {
        self.nameLabel.text = podcast.name
        self.artistNameLabel.text = podcast.artistName
        self.genresLabel.text = podcast.genres.joined(separator: ", ")
        let task = URLSession.shared.downloadTask(with: podcast.artworkUrl100) { [unowned self] (url, response, error) in
            guard let url = url else {
                print(error?.localizedDescription ?? "Error fetching artwork")
                return
            }
            
            var data: Data
            do {
                data = try Data(contentsOf: url)
            } catch {
                print("Error")
                return
            }
            
            guard let image = UIImage(data: data) else {
                print(error?.localizedDescription ?? "Error")
                return
            }
            
            DispatchQueue.main.async {
                self.artworkImageView.image = image
            }
        }
        task.resume()
    }
}

extension PodcastCell: ReusableView {}

extension PodcastCell: PreferredFont {
    func contentSizeChanged() {
        self.nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        self.artistNameLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        self.genresLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
    }
}
