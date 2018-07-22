//
//  NJProtraitControlView.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/7/21.
//

import UIKit

protocol NJProtraitControlViewDelegate {
    func protraitControlView(play protraitControlView: NJProtraitControlView) -> Void
    func protraitControlView(pause protraitControlView: NJProtraitControlView) -> Void
}

class NJProtraitControlView: UIView {
    
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
    public var protraitControlViewDelegate: NJProtraitControlViewDelegate?
    
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
        controlTopView.bounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: 40)
        playBtn.bounds = CGRect(x: 0, y: 0, width: 44, height: 44)
        playBtn.center = self.center
    }
}

// MARK:- UI
extension NJProtraitControlView {
    private func setupUIOnce() {
        self.backgroundColor = UIColor.clear
    }
}

// MARK:- control
extension NJProtraitControlView {
    func show() -> Void {
        
    }
    func hide() -> Void {
        
    }
}


// MARK:- NJControlTopViewDelegate
extension NJProtraitControlView: NJControlTopViewDelegate {
    func controlTopView(goProtrait controlTopView: NJControlTopView) -> Void {
        
    }
    func controlTopViewIsProtrait(controlTopView: NJControlTopView) -> Bool {
        return true
    }
}

// MARK:- action
extension NJProtraitControlView {
    @objc private func playClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        if btn.isSelected {
            protraitControlViewDelegate?.protraitControlView(play: self)
        }else {
            protraitControlViewDelegate?.protraitControlView(pause: self)
        }
    }
}

