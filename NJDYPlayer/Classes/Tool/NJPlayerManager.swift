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
        presentView.bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
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
        playerController.shutdown()
    }
}

// MARK:- layoutViews
extension NJPlayerManager {
    private func layoutViews(containerView: UIView?, deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation) -> Bool {
        guard playerController.playerView != nil && containerView != nil else {
            presentView.removeFromSuperview()
            return false
        }
        containerView?.addSubview(presentView)
        presentView.insertSubview(playerController.playerView!, at: 0)
        
        UIApplication.shared.statusBarOrientation = UIInterfaceOrientation(rawValue: deviceOrientation.rawValue)!
        
        switch deviceOrientation {
        case .landscapeLeft, .landscapeRight:
            print(deviceOrientation)
        case .portrait:
           print(deviceOrientation)
        default:
            print(deviceOrientation)
        }
        
        return true
    }
}

// MARK:- UIDeviceOrientationDidChange
extension NJPlayerManager {
    @objc private func handleDeviceOrientationChange() {
        let orientation = UIDevice.current.orientation
//        UIDeviceOrientation;
        /*
         case unknown
         
         case portrait // Device oriented vertically, home button on the bottom
         
         case portraitUpsideDown // Device oriented vertically, home button on the top
         
         case landscapeLeft // Device oriented horizontally, home button on the right
         
         case landscapeRight // Device oriented horizontally, home button on the left
         
         case faceUp // Device oriented flat, face up
         
         case faceDown // Device oriented flat, face down
         */
//        UIInterfaceOrientation;
        /*
         case unknown
         
         case portrait
         
         case portraitUpsideDown
         
         case landscapeLeft
         
         case landscapeRight*/
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            layoutViews(containerView: UIApplication.shared.keyWindow)
        case .portrait:
            layoutViews(containerView: self.containerView)
        default:
            print(orientation)
        }
    }
}

extension NJPlayerManager: NJPlayerControllerDelegate {
    
}

extension NJPlayerManager: NJPresentViewDelegate {
    
}
