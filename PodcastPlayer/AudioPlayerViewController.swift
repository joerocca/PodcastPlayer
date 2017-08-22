//
//  AudioPlayerViewController.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 8/22/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

class AudioPlayerViewController: UIViewController {
    
    //MARK: Properties
    let podcast: Podcast
    let track: Track
    var player = AVPlayer()
    let commandCenter = MPRemoteCommandCenter.shared()
    
    //MARK: Initialization
    init(podcast: Podcast, track: Track) {
        self.podcast = podcast
        self.track = track
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        //Navigation Controller
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AudioPlayerViewController.doneButtonAction(sender:)))
        //View
        self.view.backgroundColor = UIColor.white
    
        //Audio Player
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        guard let url = URL(string: self.track.url) else {
            fatalError("Could not create URL.")
        }
        let playerItem = AVPlayerItem(url: url)
        self.player.replaceCurrentItem(with: playerItem)
        self.player.rate = 1.0
        self.player.play()
        
        //Command Center
        self.commandCenter.playCommand.isEnabled = true
        self.commandCenter.playCommand.addTarget(self, action:#selector(playAction(sender:)))
        
        self.commandCenter.pauseCommand.isEnabled = true
        self.commandCenter.pauseCommand.addTarget(self, action:#selector(pauseAction(sender:)))
        
        self.commandCenter.skipForwardCommand.isEnabled = true
        self.commandCenter.skipForwardCommand.preferredIntervals = [30]
        self.commandCenter.skipForwardCommand.addTarget(self, action: #selector(seekForwardAction(sender:)))
        
        self.commandCenter.skipBackwardCommand.isEnabled = true
        self.commandCenter.skipBackwardCommand.preferredIntervals = [30]
        self.commandCenter.skipBackwardCommand.addTarget(self, action: #selector(seekBackwardAction(sender:)))
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: track.name,
            MPMediaItemPropertyAlbumTitle: podcast.name,
            MPMediaItemPropertyArtist: podcast.artistName
        ]
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    func doneButtonAction(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func playAction(sender: MPRemoteCommand) {
        self.player.play()
    }
    
    func pauseAction(sender: MPRemoteCommand) {
        self.player.pause()
    }
    
    func seekForwardAction(sender: MPSkipIntervalCommand) {
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let seekSeconds = currentTime + 30
        let seekTime = CMTimeMakeWithSeconds(seekSeconds, Int32(NSEC_PER_SEC))
        self.player.seek(to: seekTime)
    }
    
    func seekBackwardAction(sender: MPSkipIntervalCommand) {
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let seekSeconds = currentTime - 30
        let seekTime = CMTimeMakeWithSeconds(seekSeconds, Int32(NSEC_PER_SEC))
        self.player.seek(to: seekTime)
    }
}
