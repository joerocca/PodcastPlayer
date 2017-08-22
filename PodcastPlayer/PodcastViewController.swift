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
    fileprivate let client: PodcastFeedClient
    fileprivate let podcast: Podcast
    fileprivate var tracks: [Track]?
    
    //MARK: UI Properties
    fileprivate let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PodcastDetailHeaderCell.self, forCellReuseIdentifier: PodcastDetailHeaderCell.reuseIdentifier)
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80.0
        return tableView
    }()
    
    //MARK: Initialization
    init(client: APIClient, podcast: Podcast) {
        self.client = PodcastFeedClient(apiClient: client)
        self.podcast = podcast
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        //Navigation Controller
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
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
        
        self.client.requestFeed(with: podcast.feedUrl) { (result) in
            switch result {
                case .success(let tracks):
                    self.tracks = tracks
                    self.tableView.reloadData()
                case .failed(let error):
                    let errorString = error?.localizedDescription ?? "Error requesting feed"
                    let alertView = UIAlertController(title: "Feed Error", message: errorString, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        guard let navigationController = self.navigationController else {
                            fatalError("Navigation Controller is nil.")
                        }
                        navigationController.popViewController(animated: true)
                    })
                    alertView.addAction(okAction)
                    self.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PodcastViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        guard let track = self.tracks?[indexPath.row] else { return }
        let audioPlayerViewController = AudioPlayerViewController(podcast: self.podcast, track: track)
        let audioPlayerVCNavigationController = UINavigationController(rootViewController: audioPlayerViewController)
        self.present(audioPlayerVCNavigationController, animated: true, completion: nil)
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
