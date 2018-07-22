//
//  NJLandScapeControlView.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/7/21.
//

import UIKit

protocol NJLandScapeControlViewDelegate {
    func landScapeControlView(play landScapeControlView: NJLandScapeControlView) -> Void
    func landScapeControlView(pause landScapeControlView: NJLandScapeControlView) -> Void
}

class NJLandScapeControlView: UIView {
    
    private lazy var controlTopView: NJControlTopView = {[weak self] in
        let controlTopView = NJControlTopView()
        controlTopView.delegate = self
        self?.addSubview(controlTopView)
        return controlTopView
        }()
    
    // MARK:- common ui
    private lazy var playBtn: UIButton = {[weak self] in
        let btn = UIButton(type: UIButtonType.custom)
        btn.setBackgroundImage(UIImage.njPL_image(name: "new_allPause_44x44_", bundleClass: NJProtraitControlView.self), for: .selected)
        btn.setBackgroundImage(UIImage.njPL_image(name: "new_allPlay_44x44_", bundleClass: NJProtraitControlView.self), for: .normal)
        btn.addTarget(self, action: #selector(playClick(btn:)), for: .touchUpInside)
        self?.addSubview(btn)
        return btn;
        }()
    
    // MARK:- delegate
    public var landScapeControlViewDelegate: NJLandScapeControlViewDelegate?
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        controlTopView.bounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: 80)
        playBtn.bounds = CGRect(x: 0, y: 0, width: 44, height: 44)
        playBtn.center = self.center
    }
}

// MARK:- UI
extension NJLandScapeControlView {
    private func setupUIOnce() {
        self.backgroundColor = UIColor.clear
    }
}

// MARK:- control
extension NJLandScapeControlView {
    func show() -> Void {
        
    }
    func hide() -> Void {
        
    }
}

// MARK:- NJControlTopViewDelegate
extension NJLandScapeControlView: NJControlTopViewDelegate {
    func controlTopView(goProtrait controlTopView: NJControlTopView) -> Void {
        
    }
    func controlTopViewIsProtrait(controlTopView: NJControlTopView) -> Bool {
        return false
    }
}

// MARK:- action
extension NJLandScapeControlView {
    @objc private func playClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        if btn.isSelected {
            landScapeControlViewDelegate?.landScapeControlView(play: self)
        }else {
            landScapeControlViewDelegate?.landScapeControlView(pause: self)
        }
    }
}


