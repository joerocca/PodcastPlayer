//
//  AudioPlayer.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 8/24/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class AudioPlayer: NSObject {
    //MARK: Singleton
    public static let shared = AudioPlayer()
    
    //MARK: Properties
    var track: Track?
    var podcast: Podcast?
    private let player = AVPlayer()
    private let commandCenter = MPRemoteCommandCenter.shared()
    private static var playerItemContext = 0
    
    //MARK: Initialization
    override init() {
        super.init()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            fatalError(error.localizedDescription)
        }
        
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
    
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    //MARK: Helpers
    func prepareToPlay(podcast: Podcast, track: Track) {
        self.podcast = podcast
        self.track = track
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: track.name,
            MPMediaItemPropertyAlbumTitle: podcast.name,
            MPMediaItemPropertyArtist: podcast.artistName
        ]
        
        self.player.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &AudioPlayer.playerItemContext)
        
        guard let url = URL(string: track.url) else {
            fatalError("Could not create URL.")
        }
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &AudioPlayer.playerItemContext)
        
        self.player.replaceCurrentItem(with: playerItem)
    }
    
    //MARK: KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        guard context == &AudioPlayer.playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItemStatus
            
            // Get the status change from the change dictionary
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            // Switch over the status
            switch status {
                case .readyToPlay:
                    // Player item is ready to play.
                    print("ready")
                    self.player.rate = 1.0
                case .failed:
                    // Player item failed. See error.
                    print(self.player.currentItem?.error?.localizedDescription ?? "Error playing item.")
                case .unknown:
                    // Player item is not yet ready.
                    print("Player item is not yet ready.")
            }
        }
    }
    
    //MARK: Actions
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
