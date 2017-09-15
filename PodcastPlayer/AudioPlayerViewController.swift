//
//  AudioPlayerViewController.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 8/22/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation
import UIKit

class AudioPlayerViewController: UIViewController {
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        //Navigation Controller
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AudioPlayerViewController.doneButtonAction(sender:)))
        //View
        self.view.backgroundColor = UIColor.white
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    @objc private func doneButtonAction(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
