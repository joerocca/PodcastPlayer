//
//  SearchPodcastsTableViewController.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 5/2/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import UIKit

class SearchPodcastsTableViewController: UITableViewController {
    
    //MARK: Properties
    fileprivate let client: iTunesClient
    fileprivate var podcasts: [Podcast]?
    
    //MARK: UI Properties
    fileprivate let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.tintColor = UIColor.lightGray
        searchBar.searchBarStyle = .minimal
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.returnKeyType = .done
        return searchBar
    }()
    
    //MARK: Initialization
    init(client: APIClient) {
        self.client = iTunesClient(apiClient: client)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Deinitialization
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        //View
        self.view.backgroundColor = UIColor.white
        self.clearsSelectionOnViewWillAppear = false
        //Navigation Controller
        self.navigationItem.title = "Search"
        self.navigationItem.titleView = self.searchBar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(rightBarButtonItemTouchUpInside))
        //Subviews
        self.searchBar.delegate = self
        //Table View
        self.tableView.register(PodcastCell.self, forCellReuseIdentifier: PodcastCell.reuseIdentifier)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80.0
        if #available(iOS 10.0, *) {
            self.tableView.prefetchDataSource = self
        }
        //Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(didChangePreferredContentSize), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.podcasts?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PodcastCell.reuseIdentifier, for: indexPath) as! PodcastCell
        cell.contentSizeChanged()
        
        guard let podcast = self.podcasts?[indexPath.row] else { return UITableViewCell() }
        cell.configure(podcast: podcast)
        return cell
    }
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let podcast = podcasts?[indexPath.row] else { return }
        let podcastViewController = PodcastViewController()
        podcastViewController.podcast = podcast
        self.show(podcastViewController, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? PodcastCell {
            cell.artworkImageView.cancelImageDownload()
        }
    }
    
    //MARK: Notification Center
    @objc private func didChangePreferredContentSize(notification: Notification) {
        self.tableView.reloadData()
    }
    
    //MARK: Actions
    @objc private func rightBarButtonItemTouchUpInside(sender: UIBarButtonItem) {
        self.searchBar.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
}

extension SearchPodcastsTableViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard let podcast = self.podcasts?[indexPath.row] else {
                return
            }
            NetworkImageLoader.shared.prefetchImage(withUrl: podcast.artworkUrl100)
        }
    }
}

extension SearchPodcastsTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.client.cancelCurrentSearchOperation()
            self.podcasts = nil
            self.tableView.reloadData()
            return
        }
        
        self.client.searchPodcasts(withQuery: searchText) { (result) in
            switch result {
                case .success(let podcasts):
                        self.podcasts = podcasts
                        self.tableView.reloadData()
                case .failed(let error):
                    if let error = error as NSError? {
                        if error.code == NSURLErrorCancelled {
                            print(error.localizedDescription)
                            return
                        }
                    }
                    print(error?.localizedDescription ?? "Error searching for podcasts")
            }
        }
    }
}
