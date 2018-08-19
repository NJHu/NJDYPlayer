//
//  NJPlayerController.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/6/26.
//

import UIKit
import IJKMediaFramework

@objc public protocol NJPlayerControllerDelegate: NJPlayerControllerPlaybackFinishDelegate, NJPlayerControllerLoadStateDelegate, NJPlayerControllerPlaybackStateStateDelegate, NSObjectProtocol {
}

/// 播放完成
@objc public protocol NJPlayerControllerPlaybackFinishDelegate: NSObjectProtocol  {
    @objc optional func playerController(playbackFinish playerController: NJPlayerController, playbackEnded contentURLString: String)
    @objc optional func  playerController(playbackFinish playerController: NJPlayerController, playbackError contentURLString: String)
    @objc optional func  playerController(playbackFinish playerController: NJPlayerController, userExited contentURLString: String)
}


/// 加载状态
@objc public protocol NJPlayerControllerLoadStateDelegate: NSObjectProtocol {
   @objc optional func  playerController(loadState playerController: NJPlayerController, unKnown contentURLString: String)
   @objc optional func  playerController(loadState playerController: NJPlayerController, playable contentURLString: String)
   @objc optional func  playerController(loadState playerController: NJPlayerController, playthroughOK contentURLString: String)
   @objc optional func  playerController(loadState playerController: NJPlayerController, stalled contentURLString: String)
}

/// 播放器状态
@objc public protocol NJPlayerControllerPlaybackStateStateDelegate: NSObjectProtocol {
   @objc optional func  playerController(playbackState playerController: NJPlayerController, stopped contentURLString: String)
   @objc optional func  playerController(playbackState playerController: NJPlayerController, playing contentURLString: String)
   @objc optional func  playerController(playbackState playerController: NJPlayerController, paused contentURLString: String)
   @objc optional func  playerController(playbackState playerController: NJPlayerController, interrupted contentURLString: String)
   @objc optional func  playerController(playbackState playerController: NJPlayerController, seekingForward contentURLString: String)
   @objc optional func  playerController(playbackState playerController: NJPlayerController, seekingBackward contentURLString: String)
}

public enum NJPlayerControllerError: Error {
    case urlNil
    case playerFailNil
    case didPlaying
}

open class NJPlayerController: NSObject {
    
    private var IJKFFPlayer: IJKFFMoviePlayerController?
    private var contentURLString: String?
    weak var delegate: NJPlayerControllerDelegate?
    
    convenience init(delegate: NJPlayerControllerDelegate?) {
        self.init()
        IJKFFMoviePlayerController.setLogReport(true)
        IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_DEBUG)
        self.delegate = delegate
    }
    private override init() {
        super.init()
    }
    
    deinit {
        shutdown()
    }
}

// MARK:- 准备播放
extension NJPlayerController {
    
    func prepareToPlay(contentURLString: String) -> Error? {
        guard contentURLString.lengthOfBytes(using: .utf8) > 0  else {
            return NJPlayerControllerError.urlNil
        }
        
        // 移除上一个播放器的通知
        if IJKFFPlayer != nil {
            shutdown()
        }
        
        self.contentURLString = contentURLString
        
        initPlayer()
        
        guard IJKFFPlayer != nil else {
            return NJPlayerControllerError.playerFailNil
        }
        
        layoutViews()
        
        // 添加通知
        installMovieNotificationObservers()
        
        DispatchQueue.main.async {
            self.IJKFFPlayer?.prepareToPlay()
        }
        
        return nil
    }
}

extension NJPlayerController {
    
    var playerView: UIView? {
        return IJKFFPlayer?.view
    }
    
    // 播放
    func play() {
        if IJKFFPlayer != nil && !(IJKFFPlayer!.isPlaying()) {
            if IJKFFPlayer!.isPreparedToPlay {
                IJKFFPlayer?.play()
            }else {
                self.IJKFFPlayer?.prepareToPlay()
            }
        }
    }
    
    var isPlaying: Bool {
        return IJKFFPlayer?.isPlaying() ?? false
    }
    
    //暂停
    func pause() {
        if IJKFFPlayer != nil {
            IJKFFPlayer?.pause()
        }
    }
    
    // 关闭播放
    func shutdown() {
        // 移除上一个播放器的通知
        if IJKFFPlayer != nil {
            removeMovieNotificationObservers()
            IJKFFPlayer?.shutdown()
            IJKFFPlayer!.view.removeFromSuperview()
            IJKFFPlayer = nil
            contentURLString = nil
        }
    }
}

// 初始化播放器
extension NJPlayerController {
    private func initPlayer() {
        IJKFFPlayer = IJKFFMoviePlayerController(contentURLString: self.contentURLString, with: IJKFFOptions.byDefault())
        
        IJKFFPlayer?.scalingMode = .aspectFit
        
        IJKFFPlayer?.shouldAutoplay = true
    }
}

// MARK:- layoutView
extension NJPlayerController {
    private func layoutViews() {
        IJKFFPlayer?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

// MARK:- observerMethods
extension NJPlayerController {
    @objc private func loadStateDidChange(notification: NSNotification) {
        let loadState = IJKFFPlayer!.loadState
        /*
         IJKMPMovieLoadStateUnknown        = 0,
         IJKMPMovieLoadStatePlayable       = 1 << 0,
         IJKMPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
         IJKMPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
         */
        switch loadState {
        case IJKMPMovieLoadState.playable:
            self.delegate?.playerController?(loadState: self, playable: contentURLString!)
            break
        case IJKMPMovieLoadState.playthroughOK:
            self.delegate?.playerController?(loadState: self, playthroughOK: contentURLString!)
            break
        case IJKMPMovieLoadState.stalled:
            self.delegate?.playerController?(loadState: self, stalled: contentURLString!)
            break
        default:
            self.delegate?.playerController?(loadState: self, unKnown: contentURLString!)
            print("loadState: \(loadState), IJKMPMovieLoadStateUnknown")
        }
    }
    
    
    @objc private func playbackDidFinish(notification: NSNotification) {
        /*
         IJKMPMovieFinishReasonPlaybackEnded,
         IJKMPMovieFinishReasonPlaybackError,
         IJKMPMovieFinishReasonUserExited
         */
        let loadState = IJKFFPlayer!.loadState
        var reason: IJKMPMovieFinishReason = IJKMPMovieFinishReason.playbackEnded
        if let reasonValue = notification.userInfo?[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as? NSNumber {
            reason = IJKMPMovieFinishReason(rawValue: reasonValue.intValue)!
        }
        switch reason {
        case .playbackEnded:
            self.delegate?.playerController?(playbackFinish: self, playbackEnded: contentURLString!)
            break
        case .playbackError:
            self.delegate?.playerController?(playbackFinish: self, playbackError: contentURLString!)
            break
        case .userExited:
            self.delegate?.playerController?(playbackFinish: self, userExited: contentURLString!)
            break
        default:
            print(reason)
        }
    }
    
    
    @objc private func playbackIsPreparedToPlay(notification: NSNotification) {
        print("playbackIsPreparedToPlay")
    }
    
    
    @objc private func playerPlaybackStateChange(notification: NSNotification) {
        let playbackState = IJKFFPlayer!.playbackState
        /*
         IJKMPMoviePlaybackStateStopped,
         IJKMPMoviePlaybackStatePlaying,
         IJKMPMoviePlaybackStatePaused,
         IJKMPMoviePlaybackStateInterrupted,
         IJKMPMoviePlaybackStateSeekingForward,
         IJKMPMoviePlaybackStateSeekingBackward
         */
        switch playbackState {
        case .stopped:
            self.delegate?.playerController?(playbackState: self, stopped: contentURLString!)
            break
        case .playing:
            self.delegate?.playerController?(playbackState: self, playing: contentURLString!)
            break
        case .paused:
            self.delegate?.playerController?(playbackState: self, paused: contentURLString!)
            break
        case .interrupted:
            self.delegate?.playerController?(playbackState: self, interrupted: contentURLString!)
            break
        case .seekingForward:
            self.delegate?.playerController?(playbackState: self, seekingForward: contentURLString!)
            break
        case .seekingBackward:
            self.delegate?.playerController?(playbackState: self, seekingBackward: contentURLString!)
            break
        default:
            print(playbackState)
        }
    }
}

// MARK:- 添加通知&移除通知
extension NJPlayerController {
    private func installMovieNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadStateDidChange(notification:)), name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: IJKFFPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackDidFinish(notification:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: IJKFFPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackIsPreparedToPlay(notification:)), name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: IJKFFPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(playerPlaybackStateChange(notification:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: IJKFFPlayer)
    }
    
    private func removeMovieNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: IJKFFPlayer)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: IJKFFPlayer)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: IJKFFPlayer)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: IJKFFPlayer)
    }
}
