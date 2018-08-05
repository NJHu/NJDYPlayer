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

public class NJVideoPlayerManager: NSObject {
    public static let sharedManager: NJVideoPlayerManager = NJVideoPlayerManager()
    private lazy var  playerController = {[weak self] in
        return NJPlayerController(delegate: self)
        }()
    private lazy var presentView: NJPresentView = {[weak self] in
        let presentView = NJPresentView()
        presentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        presentView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        return presentView
        }()
    private weak var  containerView: UIView?
    private var shouldAutorotate: Bool = true
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceOrientationChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
}



// MARK:- CALL
extension NJVideoPlayerManager {
    public func prepareToPlay(contentURLString: String, in containerView: UIView, shouldAutorotate: Bool = true) -> Error? {
        let error = self.playerController.prepareToPlay(contentURLString:contentURLString)
        guard error == nil && containerView != nil else {
            return error
        }
        self.containerView = containerView
        self.shouldAutorotate = shouldAutorotate
        if !layoutViews() {
            return NJPlayerManagerError.nilPlayer
        }
        
        return nil
    }
}

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
        layoutViews(containerView: self.containerView, deviceOrientation: UIDeviceOrientation.portrait)
        playerController.shutdown()
        self.containerView = nil;
        self.shouldAutorotate = true
    }
}

// MARK:- layoutViews
extension NJVideoPlayerManager {
    private func layoutViews(containerView: UIView? = nil, deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation) -> Bool {
        guard playerController.playerView != nil else {
            return false
        }
        guard  self.containerView != nil else {
            playerController.shutdown()
            presentView.removeFromSuperview()
            return false
        }
        
        var cur_deviceOrientation = deviceOrientation
        
        if !self.shouldAutorotate {
            cur_deviceOrientation = UIDeviceOrientation.portrait
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
            
        }else if cur_deviceOrientation == UIDeviceOrientation.faceUp || cur_deviceOrientation == UIDeviceOrientation.faceDown {
            
            if presentView.superview != nil {
                return true
            }
            
            cur_deviceOrientation = UIDeviceOrientation.portrait
            self.containerView?.addSubview(presentView)
            
        }else {
            
            cur_deviceOrientation = UIDeviceOrientation.portrait
            self.containerView?.addSubview(presentView)
            
        }
        
        if cur_deviceOrientation == UIDeviceOrientation.landscapeLeft && UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeRight {
            return true
        }
        
        if cur_deviceOrientation == UIDeviceOrientation.landscapeRight && UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeLeft {
            return true
        }
        
        
        presentView.insertSubview(playerController.playerView!, at: 0)
        let anchorX = (presentView.superview!.frame.width * 0.5 / presentView.superview!.frame.height)
        let anchorY: CGFloat = 0.5
        presentView.layer.anchorPoint = CGPoint(x: anchorX, y: anchorY)
        
        let superW: CGFloat = self.presentView.superview!.frame.width
        let superH: CGFloat = self.presentView.superview!.frame.height
        
        switch cur_deviceOrientation {
        case .landscapeLeft:
            self.presentView.transform = CGAffineTransform.identity
            UIApplication.shared.statusBarOrientation = UIInterfaceOrientation.landscapeRight
            UIView.animate(withDuration: 0.4) {
                self.presentView.frame = CGRect(x: 0, y: 0, width: superH, height: superW)
                self.presentView.transform = CGAffineTransform.init(rotationAngle: CGFloat(M_PI_2))
                self.playerController.playerView?.frame = CGRect(x: 0, y: 0, width: superH, height: superW)
            }
        case .landscapeRight:
            self.presentView.transform = CGAffineTransform.identity
            UIApplication.shared.statusBarOrientation = UIInterfaceOrientation.landscapeLeft
            let rotationTransform  = CGAffineTransform.init(rotationAngle: -CGFloat(M_PI_2))
            UIView.animate(withDuration: 0.4) {
                self.presentView.frame = CGRect(x: 0, y: 0, width: superH, height: superW)
                self.presentView.transform = rotationTransform.translatedBy(x: -(superH - superW), y: 0)
                self.playerController.playerView?.frame = CGRect(x: 0, y: 0, width: superH, height: superW)
            }
        case .portrait:
            UIApplication.shared.statusBarOrientation = UIInterfaceOrientation.portrait
            UIView.animate(withDuration: 0.4) {
                self.presentView.transform = CGAffineTransform.identity
                self.presentView.frame = CGRect(x: 0, y: 0, width: superW, height: superH)
                self.playerController.playerView?.frame = CGRect(x: 0, y: 0, width: superW, height: superH)
            }
            
        default:
            print(deviceOrientation.rawValue)
        }
        
        return true
    }
}

// MARK:- UIDeviceOrientationDidChange
extension NJVideoPlayerManager {
    @objc private func handleDeviceOrientationChange() {
        layoutViews()
    }
}

extension NJVideoPlayerManager: NJPlayerControllerDelegate {
    
}

