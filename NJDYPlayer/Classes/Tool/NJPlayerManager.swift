//
//  NJPlayerManager.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/7/22.
//

import UIKit

public class NJPlayerManager: NSObject {
    public static let sharedManager: NJPlayerManager = NJPlayerManager()
    private lazy var  playerController = {[weak self] in
        return NJPlayerController(delegate: self)
        }()
    private lazy var presentView: NJPresentView = {[weak self] in
        let presentView = NJPresentView()
        presentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentView.presentViewDelegate = self
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
        self.containerView = containerView
        layoutViews(containerView: self.containerView)
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
    private func layoutViews(containerView: UIView?) {
        containerView?.addSubview(presentView)
        UIView.animate(withDuration: 0.2) {
            self.presentView.frame = self.presentView.superview?.bounds ?? CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        playerController.playerView?.frame = presentView.bounds
        if playerController.playerView != nil {
            presentView.insertSubview(playerController.playerView!, at: 0)
        }
    }
}

// MARK:- UIDeviceOrientationDidChange
extension NJPlayerManager {
    @objc private func handleDeviceOrientationChange() {
        let orientation = UIDevice.current.orientation
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
