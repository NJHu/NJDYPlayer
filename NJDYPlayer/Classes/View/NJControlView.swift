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
    
    // MARK:- common ui
    private lazy var playBtn: UIButton = {[weak self] in
        let btn = UIButton(type: UIButtonType.custom)
        btn.setBackgroundImage(UIImage.njPL_image(name: "new_allPause_44x44_", bundleClass: NJControlView.self), for: .selected)
        btn.setBackgroundImage(UIImage.njPL_image(name: "new_allPlay_44x44_", bundleClass: NJControlView.self), for: .normal)
        btn.addTarget(self, action: #selector(playOrPause(btn:)), for: .touchUpInside)
        self?.addSubview(btn)
        return btn;
        }()
    
    private lazy var loadingActivity: UIActivityIndicatorView = {
       let loadingActivity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        loadingActivity.hidesWhenStopped = true
        self.addSubview(loadingActivity)
        return loadingActivity
    }()
    
    var playing: Bool = true {
        didSet {
            playBtn.isSelected = playing
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
        playBtn.bounds = CGRect(x: 0, y: 0, width: 44, height: 44)
        playBtn.center = CGPoint(x: self.bounds.width * 0.5, y: self.bounds.height * 0.5)
        loadingActivity.center = CGPoint(x: self.frame.width * 0.5, y: self.frame.height * 0.5)
        insertSubview(loadingActivity, aboveSubview: playBtn)
    }
}

// MARK:- action
extension NJControlView: NJLandScapeControlViewDelegate, NJProtraitControlViewDelegate {
    @objc func playOrPause(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        if btn.isSelected {
            delegate?.controlView?(playClick: self)
        }else {
            delegate?.controlView?(pauseClick: self)
        }
    }
    func landScapeControlView(gobackLayout landScapeControlView: NJLandScapeControlView) -> Void {
        delegate?.controlView?(gobackLayout: self)
    }
    func protraitControlView(gobackLayout protraitControlView: NJProtraitControlView) -> Void {
        delegate?.controlView?(gobackLayout: self)
    }
}

// MARK:- action
extension NJControlView {
    func showProtrait() -> Void {
        protraitControlView.show()
        landScapeControlView.hide()
    }
    func showLandScape() -> Void {
        protraitControlView.hide()
        landScapeControlView.show()
    }
    func showCenterPlayBtn() {
        playBtn.isHidden = false
    }
    func hideCenterPlayBtn() {
        playBtn.isHidden = true
    }
}

