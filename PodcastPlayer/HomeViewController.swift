//
//  HomeViewController.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 5/8/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    //MARK: Properties
    private let apiClient: APIClient
    
    //MARK: Initialization
    init(apiClient: APIClient) {
        self.apiClient = apiClient
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: UIViewController
    override func viewDidLoad() {
        //Navigation Controller
        self.navigationItem.title = "Podcasts"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(rightBarButtonItemTouchUpInside))
        //View
        self.view.backgroundColor = UIColor.white
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    @objc private func rightBarButtonItemTouchUpInside(sender: UIBarButtonItem) {
        let searchVC = SearchPodcastsTableViewController(client: self.apiClient)
        let searchNavC = UINavigationController(rootViewController: searchVC)
        self.present(searchNavC, animated: true, completion: nil)
    }
}
