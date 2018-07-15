//
//  NJPlayerController.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/6/26.
//

import UIKit
import IJKMediaFramework

@objc public protocol NJPlayerControllerDelegate: NJPlayerControllerPlaybackFinishDelegate, NJPlayerControllerLoadStateDelegate, NJPlayerControllerPlaybackStateStateDelegate {
}

@objc public protocol NJPlayerControllerPlaybackFinishDelegate: NSObjectProtocol {
    @objc optional func playerController(playbackFinish playerController: NJPlayerController, playbackEnded contentURLString: String)
    @objc optional func  playerController(playbackFinish playerController: NJPlayerController, playbackError contentURLString: String)
    @objc optional func  playerController(playbackFinish playerController: NJPlayerController, userExited contentURLString: String)
}

@objc public protocol NJPlayerControllerLoadStateDelegate: NSObjectProtocol {
    @objc optional func  playerController(loadState playerController: NJPlayerController, unKnown contentURLString: String)
    @objc optional func  playerController(loadState playerController: NJPlayerController, playable contentURLString: String)
    @objc optional func  playerController(loadState playerController: NJPlayerController, playthroughOK contentURLString: String)
    @objc optional func  playerController(loadState playerController: NJPlayerController, stalled contentURLString: String)
}

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
    open weak var delegate: NJPlayerControllerDelegate!
    
    public var containerView: UIView! {
        didSet {
            if IJKFFPlayer != nil {
                containerView.insertSubview(IJKFFPlayer!.view, at: 0)
                IJKFFPlayer!.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
            }
        }
    }

    public convenience init(containerView: UIView, delegate: NJPlayerControllerDelegate) {
        self.init()
        IJKFFMoviePlayerController.setLogReport(true)
        IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_DEBUG)
        self.delegate = delegate
        self.containerView = containerView
    }
    
    deinit {
        shutdown()
    }
}

// MARK:- 准备播放
extension NJPlayerController {
    
    public func prepareToPlay(contentURLString: String) -> Error? {
        guard let playUrlString = contentURLString.urlEncoding(), playUrlString.lengthOfBytes(using: .utf8) > 0  else {
            return NJPlayerControllerError.urlNil
        }
        
        // 移除上一个播放器的通知
        if IJKFFPlayer != nil {
            shutdown()
        }
        
        self.contentURLString = playUrlString
        
        initPlayer()
        
        guard IJKFFPlayer != nil else {
            return NJPlayerControllerError.playerFailNil
        }
        // 添加到父控件
        layoutViews()
        // 添加通知
        installMovieNotificationObservers()
        
        // 必须立马调用， 不然会有bug
        IJKFFPlayer?.prepareToPlay()
        return nil
    }
    
}

extension NJPlayerController {
    // 播放
    public func play() {
        if IJKFFPlayer != nil && !IJKFFPlayer!.isPlaying() {
            IJKFFPlayer?.play()
        }
    }
    
    //暂停
    public func pause() {
        if IJKFFPlayer != nil {
            IJKFFPlayer?.pause()
        }
    }
    
    // 关闭播放
    public func shutdown() {
        // 移除上一个播放器的通知
        if IJKFFPlayer != nil {
            removeMovieNotificationObservers()
            IJKFFPlayer?.shutdown()
            IJKFFPlayer!.view.removeFromSuperview()
            IJKFFPlayer = nil;
        }
    }
}

// 初始化播放器
extension NJPlayerController {
    private func initPlayer() {
        IJKFFPlayer = IJKFFMoviePlayerController(contentURLString: self.contentURLString, with: IJKFFOptions.byDefault())
        
        IJKFFPlayer?.scalingMode = .aspectFit
        //如果是直播，最好不让他自动播放，如果YES，那么就会自动播放电影，不需要通过[IJKFFPlayer play];就可以播放了，
        //但是如果NO，我们需要注册通知，然后到响应比较合适的地方去检测通知，然后必须通过[IJKFFPlayer play];手动播放
        IJKFFPlayer?.shouldAutoplay = true
    }
}

// MARK:- layoutView
extension NJPlayerController {
    private func layoutViews() {
        IJKFFPlayer?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.insertSubview(IJKFFPlayer!.view, at: 0)
        IJKFFPlayer?.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
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
            self.delegate.playerController?(loadState: self, playable: contentURLString!)
            break
        case IJKMPMovieLoadState.playthroughOK:
            self.delegate.playerController?(loadState: self, playthroughOK: contentURLString!)
            break
        case IJKMPMovieLoadState.stalled:
            self.delegate.playerController?(loadState: self, stalled: contentURLString!)
            break
        default:
            self.delegate.playerController?(loadState: self, unKnown: contentURLString!)
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
            self.delegate.playerController?(playbackFinish: self, playbackEnded: contentURLString!)
            break
        case .playbackError:
            self.delegate.playerController?(playbackFinish: self, playbackError: contentURLString!)
            break
        case .userExited:
            self.delegate.playerController?(playbackFinish: self, userExited: contentURLString!)
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
            self.delegate.playerController?(playbackState: self, stopped: contentURLString!)
            break
        case .playing:
            self.delegate.playerController?(playbackState: self, playing: contentURLString!)
            break
        case .paused:
            self.delegate.playerController?(playbackState: self, paused: contentURLString!)
            break
        case .interrupted:
            self.delegate.playerController?(playbackState: self, interrupted: contentURLString!)
            break
        case .seekingForward:
            self.delegate.playerController?(playbackState: self, seekingForward: contentURLString!)
            break
        case .seekingBackward:
            self.delegate.playerController?(playbackState: self, seekingBackward: contentURLString!)
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
