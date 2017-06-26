//
//  PodcastViewController.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 5/24/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class PodcastViewController: UIViewController {
    
    //MARK: Properties
    let feedQueue = OperationQueue()
    var podcast: Podcast?
    var tracks: [Track]?
    
    //MARK: UI Properties
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PodcastDetailHeaderCell.self, forCellReuseIdentifier: PodcastDetailHeaderCell.reuseIdentifier)
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80.0
        return tableView
    }()
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        //View
        self.view.backgroundColor = UIColor.white
        //Subviews
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        //Constraints
        let viewDict = ["tableView": self.tableView]
        var allConstraints = [NSLayoutConstraint]()
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: viewDict)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: viewDict)
        NSLayoutConstraint.activate(allConstraints)
        
        guard let podcast = self.podcast else {
            fatalError()
        }
        
        let fetchPodcastTracksOperation = FetchPodcastTracksOperation(feedUrl: podcast.feedUrl)
        
        let parsePodcastTracksOperation = ParsePodcastTracksOperation()
        parsePodcastTracksOperation.addDependency(fetchPodcastTracksOperation)
        parsePodcastTracksOperation.completionBlock = { [unowned parsePodcastTracksOperation] in
            self.tracks = parsePodcastTracksOperation.tracks
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        self.feedQueue.addOperations([fetchPodcastTracksOperation, parsePodcastTracksOperation], waitUntilFinished: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PodcastViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension PodcastViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1
            case 1:
                return self.tracks?.count ?? 0
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: PodcastDetailHeaderCell.reuseIdentifier, for: indexPath) as! PodcastDetailHeaderCell
                cell.contentSizeChanged()
                
                guard let podcast = self.podcast else { fatalError() }
                cell.configure(podcast: podcast)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reuseIdentifier, for: indexPath) as! TrackCell
                cell.contentSizeChanged()
                
                guard let track = self.tracks?[indexPath.row] else { fatalError() }
                cell.configure(track: track)
                return cell
            default:
                return UITableViewCell()
        }
    }
}
