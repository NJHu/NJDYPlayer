//
//  NJPlayerManager.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/7/22.
//

import UIKit

public enum NJPlayerManagerError: Error {
    case nilPlayer
}

public class NJPlayerManager: NSObject {
    public static let sharedManager: NJPlayerManager = NJPlayerManager()
    private lazy var  playerController = {[weak self] in
        return NJPlayerController(delegate: self)
        }()
    private lazy var presentView: NJPresentView = {[weak self] in
        let presentView = NJPresentView()
        presentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentView.presentViewDelegate = self
        presentView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        return presentView
        }()
    private weak var  containerView: UIView?
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceOrientationChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
}



// MARK:- CALL
extension NJPlayerManager {
    public func prepareToPlay(contentURLString: String, in containerView: UIView) -> Error? {
        let error = self.playerController.prepareToPlay(contentURLString:contentURLString)
        guard error == nil && containerView != nil else {
            return error
        }
        if !layoutViews(containerView: containerView) {
            return NJPlayerManagerError.nilPlayer
        }
        self.containerView = containerView
        return nil
    }
}

public extension NJPlayerManager {
    
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
    }
}

// MARK:- layoutViews
extension NJPlayerManager {
    private func layoutViews(containerView: UIView?, deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation) -> Bool {
        guard playerController.playerView != nil else {
            return false
        }
        guard  containerView != nil else {
            presentView.removeFromSuperview()
            return false
        }
        containerView?.addSubview(presentView)
        presentView.insertSubview(playerController.playerView!, at: 0)
        let anchorX = (presentView.superview!.frame.width * 0.5 / presentView.superview!.frame.height)
        let anchorY: CGFloat = 0.5
        presentView.layer.anchorPoint = CGPoint(x: anchorX, y: anchorY)
        
        switch deviceOrientation {
        case .landscapeLeft:
            UIApplication.shared.statusBarOrientation = UIInterfaceOrientation.landscapeRight
            UIView.animate(withDuration: 0.4) {
                self.presentView.frame = CGRect(x: 0, y: 0, width: self.presentView.superview!.frame.height, height: self.presentView.superview!.frame.width)
                self.playerController.playerView?.frame = CGRect(x: 0, y: 0, width: self.presentView.frame.width, height: self.presentView.frame.height)
                self.presentView.transform = CGAffineTransform.init(rotationAngle: CGFloat(M_PI_2))
            }
        case .landscapeRight:
            let rotationTransform  = CGAffineTransform.init(rotationAngle: -CGFloat(M_PI_2))
            UIApplication.shared.statusBarOrientation = UIInterfaceOrientation.landscapeLeft
            UIView.animate(withDuration: 0.4) {
                self.presentView.frame = CGRect(x: 0, y: 0, width: self.presentView.superview!.frame.height, height: self.presentView.superview!.frame.width)
                self.playerController.playerView?.frame = CGRect(x: 0, y: 0, width: self.presentView.frame.width, height: self.presentView.frame.height)
                self.presentView.transform = rotationTransform.translatedBy(x: -(self.presentView.superview!.frame.height - self.presentView.superview!.frame.width), y: 0)
            }
        default:
            UIApplication.shared.statusBarOrientation = UIInterfaceOrientation.portrait
            UIView.animate(withDuration: 0.4) {
                self.presentView.transform = CGAffineTransform.identity
                self.presentView.frame = CGRect(x: 0, y: 0, width: self.presentView.superview!.frame.width, height: self.presentView.superview!.frame.height)
                self.playerController.playerView?.frame = CGRect(x: 0, y: 0, width: self.presentView.frame.width, height: self.presentView.frame.height)
            }
        }
        
        return true
    }
}

// MARK:- UIDeviceOrientationDidChange
extension NJPlayerManager {
    @objc private func handleDeviceOrientationChange() {
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            layoutViews(containerView: UIApplication.shared.keyWindow)
        default:
            layoutViews(containerView: self.containerView)
        }
    }
}

extension NJPlayerManager: NJPlayerControllerDelegate {
    
}

extension NJPlayerManager: NJPresentViewDelegate {
    
}
