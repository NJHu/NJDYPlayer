//
//  NJPlayerManager.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/7/22.
//

import UIKit

public enum NJVideoPlayerManagerError: Error {
    case nilPlayer
}

@objc public protocol NJVideoPlayerManagerDelegate: NJPlayerControllerDelegate {
    @objc optional func  videoPlayerManager(_ videoPlayerManager: NJVideoPlayerManager, titleForContentURLString contentURLString: String) -> String?
}

public class NJVideoPlayerManager: NSObject {
    public static let sharedManager: NJVideoPlayerManager = NJVideoPlayerManager()
    private lazy var  playerController = {[weak self] in
        return NJPlayerController(delegate: self)
        }()
    public weak var delegate: NJVideoPlayerManagerDelegate?
    private lazy var presentView: NJPresentView = {[weak self] in
        let presentView = NJPresentView()
        presentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        presentView.delegate = self
        return presentView
        }()
    private weak var  containerView: UIView?
    private var shouldAutorotate: Bool = true
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceOrientationChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
}



// MARK:- call
extension NJVideoPlayerManager {
    public func prepareToPlay(contentURLString: String, in containerView: UIView, shouldAutorotate: Bool = true, delegate: NJVideoPlayerManagerDelegate) -> Error? {
        self.delegate = delegate
        self.presentView.controlView.title = self.delegate?.videoPlayerManager?(self, titleForContentURLString: contentURLString)
        let error = self.playerController.prepareToPlay(contentURLString:contentURLString)
        guard error == nil && containerView != nil else {
            return error
        }
        self.containerView = containerView
        self.shouldAutorotate = shouldAutorotate
        
        if !layoutViews(isInit: true) {
            return NJPlayerManagerError.nilPlayer
        }
        return nil
    }
}

// action
public extension NJVideoPlayerManager {
    
    var playerView: UIView {
        return self.presentView
    }
    
    // 播放
    func play() {
        if !playerController.isPlaying {
            playerController.play()
        }
    }
    
    var isPlaying: Bool {
        return playerController.isPlaying
    }
    
    //暂停
    func pause() {
        playerController.pause()
    }
    
    // 关闭播放
    func shutdown() {
        self.layoutViews(containerView: self.containerView, deviceOrientation: UIDeviceOrientation.portrait, isInit: true)
        self.playerController.shutdown()
        self.delegate = nil;
        self.containerView = nil;
        self.shouldAutorotate = true
    }
}

// MARK:- UIDeviceOrientationDidChange
extension NJVideoPlayerManager {
    @objc private func handleDeviceOrientationChange() {
        layoutViews()
    }
}

// MARK:- layoutViews
extension NJVideoPlayerManager {
    private func layoutViews(containerView: UIView? = nil, deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation, isInit: Bool = false) -> Bool {
        guard playerController.playerView != nil else {
            return false
        }
        guard  self.containerView != nil else {
            playerController.shutdown()
            presentView.removeFromSuperview()
            return false
        }
        
        var cur_deviceOrientation = deviceOrientation
        
        if !(cur_deviceOrientation == UIDeviceOrientation.landscapeLeft || cur_deviceOrientation == UIDeviceOrientation.landscapeRight || cur_deviceOrientation == UIDeviceOrientation.portrait) || !self.shouldAutorotate {
            cur_deviceOrientation = UIDeviceOrientation.portrait
        }
        
        
        if  cur_deviceOrientation == UIDeviceOrientation.portrait && UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portrait && presentView.superview != nil {
            return true
        }
        
        if cur_deviceOrientation == UIDeviceOrientation.landscapeLeft && UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeRight{
            return true
        }
        
        if cur_deviceOrientation == UIDeviceOrientation.landscapeRight && UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeLeft {
            return true
        }
        
        
        if cur_deviceOrientation == UIDeviceOrientation.landscapeLeft || cur_deviceOrientation == UIDeviceOrientation.landscapeRight {
            
            if containerView == nil {
                UIApplication.shared.keyWindow?.addSubview(presentView)
            }else {
                containerView?.addSubview(presentView)
            }
            
        }else if cur_deviceOrientation == UIDeviceOrientation.portrait {
            
            if containerView == nil {
                self.containerView?.addSubview(presentView)
            }else {
                containerView?.addSubview(presentView)
            }
            
        }
        presentView.insertSubview(playerController.playerView!, at: 0)

        let superW: CGFloat = CGFloat(Int(self.presentView.superview!.frame.width))
        let superH: CGFloat = CGFloat(Int(self.presentView.superview!.frame.height))
        let anchorX = superW * 0.5 / superH
        let anchorY: CGFloat = 0.5
        presentView.layer.anchorPoint = CGPoint(x: anchorX, y: anchorY)
        
        let duration =  isInit ? 0 : 0.4
        
        switch cur_deviceOrientation {
        case .landscapeLeft:
            self.presentView.transform = CGAffineTransform.identity
            UIApplication.shared.statusBarOrientation = UIInterfaceOrientation.landscapeRight
            UIView.animate(withDuration: duration) {
                self.presentView.frame = CGRect(x: 0, y: 0, width: superH, height: superW)
                self.presentView.transform = CGAffineTransform.init(rotationAngle: CGFloat(M_PI_2))
                self.playerController.playerView?.frame = CGRect(x: 0, y: 0, width: superH, height: superW)
                self.presentView.controlView.showLandScape()
            }
        case .landscapeRight:
            self.presentView.transform = CGAffineTransform.identity
            UIApplication.shared.statusBarOrientation = UIInterfaceOrientation.landscapeLeft
            let rotationTransform  = CGAffineTransform.init(rotationAngle: -CGFloat(M_PI_2))
            UIView.animate(withDuration: duration) {
                self.presentView.frame = CGRect(x: 0, y: 0, width: superH, height: superW)
                self.presentView.transform = rotationTransform.translatedBy(x: -(superH - superW), y: 0)
                self.playerController.playerView?.frame = CGRect(x: 0, y: 0, width: superH, height: superW)
                self.presentView.controlView.showLandScape()
            }
        case .portrait:
            UIApplication.shared.statusBarOrientation = UIInterfaceOrientation.portrait
            UIView.animate(withDuration: duration) {
                self.presentView.transform = CGAffineTransform.identity
                self.presentView.frame = CGRect(x: 0, y: 0, width: superW, height: superH)
                self.playerController.playerView?.frame = CGRect(x: 0, y: 0, width: superW, height: superH)
                self.presentView.controlView.showProtrait()
            }
            
        default:
            print(deviceOrientation.rawValue)
        }
        
        return true
    }
}



extension NJVideoPlayerManager: NJPlayerControllerDelegate {
    
}

/// 播放完成
extension NJVideoPlayerManager: NJPlayerControllerPlaybackFinishDelegate {
    @objc public func playerController(playbackFinish playerController: NJPlayerController, playbackEnded contentURLString: String) {
        self.delegate?.playerController?(playbackFinish: playerController, playbackEnded: contentURLString)
        self.presentView.controlView.playing = false
    }
    @objc public func  playerController(playbackFinish playerController: NJPlayerController, playbackError contentURLString: String) {
        self.delegate?.playerController?(playbackFinish: playerController, playbackError: contentURLString)
        self.presentView.controlView.playing = false
    }
    @objc public func  playerController(playbackFinish playerController: NJPlayerController, userExited contentURLString: String) {
        self.delegate?.playerController?(playbackFinish: playerController, userExited: contentURLString)
        self.presentView.controlView.playing = false
    }
}
/// 加载状态
extension NJVideoPlayerManager: NJPlayerControllerLoadStateDelegate {
    @objc public func  playerController(loadState playerController: NJPlayerController, unKnown contentURLString: String) {
        self.delegate?.playerController?(loadState: playerController, unKnown: contentURLString)
        self.presentView.controlView.isLoading = false
    }
    @objc public func  playerController(loadState playerController: NJPlayerController, playable contentURLString: String){
        self.delegate?.playerController?(loadState: playerController, playable: contentURLString)
        self.presentView.controlView.isLoading = false
    }
    @objc public func  playerController(loadState playerController: NJPlayerController, playthroughOK contentURLString: String){
        self.delegate?.playerController?(loadState: playerController, playthroughOK: contentURLString)
        self.presentView.controlView.isLoading = false
    }
    @objc public func  playerController(loadState playerController: NJPlayerController, stalled contentURLString: String){
        self.delegate?.playerController?(loadState: playerController, stalled: contentURLString)
        self.presentView.controlView.isLoading = true
    }
}

/// 播放器状态
extension NJVideoPlayerManager: NJPlayerControllerPlaybackStateStateDelegate {
    @objc public func  playerController(playbackState playerController: NJPlayerController, stopped contentURLString: String){
        self.delegate?.playerController?(playbackState: playerController, stopped: contentURLString)
        self.presentView.controlView.playing = false
    }
    @objc public func  playerController(playbackState playerController: NJPlayerController, playing contentURLString: String){
        self.delegate?.playerController?(playbackState: playerController, playing: contentURLString)
        self.presentView.controlView.playing = true
    }
    @objc public func  playerController(playbackState playerController: NJPlayerController, paused contentURLString: String){
        self.delegate?.playerController?(playbackState: playerController, paused: contentURLString)
        self.presentView.controlView.playing = false
    }
    @objc public func  playerController(playbackState playerController: NJPlayerController, interrupted contentURLString: String){
        self.delegate?.playerController?(playbackState: playerController, interrupted: contentURLString)
        self.presentView.controlView.playing = false
    }
    @objc public func  playerController(playbackState playerController: NJPlayerController, seekingForward contentURLString: String){
        self.delegate?.playerController?(playbackState: playerController, seekingForward: contentURLString)
        
        self.presentView.controlView.playing = false
    }
    @objc public func  playerController(playbackState playerController: NJPlayerController, seekingBackward contentURLString: String) {
        self.delegate?.playerController?(playbackState: playerController, seekingBackward: contentURLString)
        self.presentView.controlView.playing = false
    }
}

extension NJVideoPlayerManager: NJPresentViewDelegate {
    @objc func controlView(playClick controlView: NJControlView){
        if !self.playerController.isPlaying {
            self.playerController.play()
        }
    }
    @objc func controlView(pauseClick controlView: NJControlView) {
        if self.playerController.isPlaying {
            self.playerController.pause()
        }
    }
    @objc func controlView(gobackLayout controlView: NJControlView) {
        layoutViews(containerView: self.containerView, deviceOrientation: UIDeviceOrientation.portrait)
    }
    @objc func controlView(fullScreen controlView: NJControlView) {
        layoutViews(deviceOrientation: UIDeviceOrientation.landscapeLeft)
    }
}

