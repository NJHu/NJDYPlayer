//
//  NJControlView.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/7/21.
//

import UIKit

//    @objc optional func  playerController(playbackFinish playerController: NJPlayerController, userExited contentURLString: String)

/// 播放完成
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
        btn.setBackgroundImage(UIImage.njPL_image(name: "new_allPause_44x44_", bundleClass: NJProtraitControlView.self), for: .selected)
        btn.setBackgroundImage(UIImage.njPL_image(name: "new_allPlay_44x44_", bundleClass: NJProtraitControlView.self), for: .normal)
        btn.addTarget(self, action: #selector(playOrPause(btn:)), for: .touchUpInside)
        self?.addSubview(btn)
        return btn;
        }()
    
    var delegate: NJControlViewDelegate?
    
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
    func showProtrait() -> Void {
        protraitControlView.show()
        landScapeControlView.hide()
    }
    func showLandScape() -> Void {
        protraitControlView.hide()
        landScapeControlView.show()
    }
}

extension NJControlView {
    func setupUIOnce() {
        self.backgroundColor = UIColor.clear
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        landScapeControlView.frame = self.bounds
        protraitControlView.frame = self.bounds
        playBtn.bounds = CGRect(x: 0, y: 0, width: 44, height: 44)
        playBtn.center = CGPoint(x: self.bounds.width * 0.5, y: self.bounds.height * 0.5)
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


