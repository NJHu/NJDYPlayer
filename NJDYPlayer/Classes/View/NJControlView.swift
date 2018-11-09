//
//  NJControlView.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/7/21.
//

import UIKit

/// 播放操作
@objc protocol NJControlViewDelegate: NSObjectProtocol {
    @objc optional func controlView(playClick controlView: NJControlView)
    @objc optional func controlView(pauseClick controlView: NJControlView)
    @objc optional func controlView(gobackLayout controlView: NJControlView)
    @objc optional func controlView(fullScreen controlView: NJControlView)
}


class NJControlView: UIView {
    
    // MARK:- controlView
    private lazy var protraitControlView: NJProtraitControlView = {[weak self] in
        let protraitControlView = NJProtraitControlView()
        self?.addSubview(protraitControlView)
        protraitControlView.protraitControlViewDelegate = self
        return protraitControlView;
        }()
    private lazy var landScapeControlView: NJLandScapeControlView = {[weak self] in
        let landScapeControlView = NJLandScapeControlView()
        self?.addSubview(landScapeControlView)
        landScapeControlView.landScapeControlViewDelegate = self
        return landScapeControlView;
        }()
    
    private lazy var loadingActivity: UIActivityIndicatorView = {
        let loadingActivity = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
        loadingActivity.hidesWhenStopped = true
        self.addSubview(loadingActivity)
        return loadingActivity
    }()
    
    var playing: Bool = true {
        didSet {
            protraitControlView.playing = playing
            landScapeControlView.playing = playing
        }
    }
    
    var isLoading: Bool = true {
        didSet {
            if isLoading {
                loadingActivity.startAnimating()
            }else {
                loadingActivity.stopAnimating()
            }
        }
    }
    
    var title: String? {
        willSet {
            let aTitle = newValue ?? ""
            landScapeControlView.title = aTitle
            protraitControlView.title = aTitle
        }
    }
    
    weak var delegate: NJControlViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIOnce()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUIOnce()
    }
}

extension NJControlView {
    private func setupUIOnce() {
        self.backgroundColor = UIColor.clear
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        landScapeControlView.frame = self.bounds
        protraitControlView.frame = self.bounds
        loadingActivity.center = CGPoint(x: self.frame.width * 0.5, y: self.frame.height * 0.5)
        bringSubviewToFront(loadingActivity)
    }
}

// MARK:- action
extension NJControlView: NJLandScapeControlViewDelegate, NJProtraitControlViewDelegate {
    func protraitControlView(play protraitControlView: NJProtraitControlView) -> Void {
        delegate?.controlView?(playClick: self)
    }
    func protraitControlView(pause protraitControlView: NJProtraitControlView) -> Void {
        delegate?.controlView?(pauseClick: self)
    }
    func protraitControlView(gobackLayout protraitControlView: NJProtraitControlView) -> Void {
        delegate?.controlView?(gobackLayout: self)
    }
    func protraitControlView(fullScreen protraitControlView: NJProtraitControlView) {
        delegate?.controlView?(fullScreen: self)
    }
    
    func landScapeControlView(gobackLayout landScapeControlView: NJLandScapeControlView) -> Void {
        delegate?.controlView?(gobackLayout: self)
    }
    func landScapeControlView(play landScapeControlView: NJLandScapeControlView) -> Void {
        delegate?.controlView?(playClick: self)
    }
    func landScapeControlView(pause landScapeControlView: NJLandScapeControlView) -> Void {
        delegate?.controlView?(pauseClick: self)
    }
}

// MARK:- action
extension NJControlView {
    func showProtrait() -> Void {
        protraitControlView.isHidden = false
        landScapeControlView.isHidden = true
    }
    func showLandScape() -> Void {
        protraitControlView.isHidden = true
        landScapeControlView.isHidden = false
    }
}

