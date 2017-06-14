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
    
    //MARK: UIViewController
    override func viewDidLoad() {
        //View
        self.view.backgroundColor = UIColor.white
        //Navigation Controller
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(rightBarButtonItemTouchUpInside))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    func rightBarButtonItemTouchUpInside(sender: UIBarButtonItem) {
        let searchVC = SearchPodcastsTableViewController()
        let searchNavC = UINavigationController(rootViewController: searchVC)
        self.present(searchNavC, animated: true, completion: nil)
    }
}
