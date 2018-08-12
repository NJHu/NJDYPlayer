//
//  NJProtraitControlView.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/7/21.
//

import UIKit

@objc protocol NJProtraitControlViewDelegate: NSObjectProtocol {
    @objc optional func protraitControlView(gobackLayout protraitControlView: NJProtraitControlView) -> Void
    @objc optional  func protraitControlView(play protraitControlView: NJProtraitControlView) -> Void
    @objc optional func protraitControlView(pause protraitControlView: NJProtraitControlView) -> Void
    @objc optional func protraitControlView(fullScreen protraitControlView: NJProtraitControlView) -> Void
}

class NJProtraitControlView: UIView {
    
    private lazy var controlTopView: NJControlTopView = {[weak self] in
        let controlTopView = NJControlTopView()
        controlTopView.delegate = self
        self?.addSubview(controlTopView)
        return controlTopView
        }()
    
    private lazy var controlBottomView: UIView = {[weak self] in
        let controlBottomView = UIView()
        controlBottomView.layer.contents = UIImage.njPL_image(name: "ZFPlayer_bottom_shadow", bundleClass: NJProtraitControlView.self)?.cgImage
        self?.addSubview(controlBottomView)
        return controlBottomView
        }()
    
    lazy var progressTimeView: NJProgressTimeView = {[weak self] in
        let progressTimeView = NJProgressTimeView()
        progressTimeView.delegate = self
        self?.controlBottomView.addSubview(progressTimeView)
        return progressTimeView
        }()
    private lazy var fullScreenBtn: UIButton = {[weak self] in
        let fullScreenBtn = UIButton(type: UIButtonType.custom)
        fullScreenBtn.setImage(UIImage.njPL_image(name: "ZFPlayer_fullscreen", bundleClass: NJProtraitControlView.self), for: .selected)
        fullScreenBtn.setImage(UIImage.njPL_image(name: "ZFPlayer_fullscreen", bundleClass: NJProtraitControlView.self), for: .normal)
        fullScreenBtn.setImage(UIImage.njPL_image(name: "ZFPlayer_fullscreen", bundleClass: NJProtraitControlView.self), for: .highlighted)
        fullScreenBtn.addTarget(self, action: #selector(fullScreenCick(btn:)), for: .touchUpInside)
        self?.controlBottomView.addSubview(fullScreenBtn)
        return fullScreenBtn;
        }()

    private lazy var playBtn: UIButton = {[weak self] in
        let btn = UIButton(type: UIButtonType.custom)
        btn.setBackgroundImage(UIImage.njPL_image(name: "new_allPause_44x44_", bundleClass: NJProtraitControlView.self), for: .selected)
        btn.setBackgroundImage(UIImage.njPL_image(name: "new_allPlay_44x44_", bundleClass: NJProtraitControlView.self), for: .normal)
        btn.addTarget(self, action: #selector(playOrPause(btn:)), for: .touchUpInside)
        self?.addSubview(btn)
        return btn;
        }()
    
    var playing: Bool = true {
        didSet {
            playBtn.isSelected = playing
        }
    }
    
    // MARK:- delegate
   weak public var protraitControlViewDelegate: NJProtraitControlViewDelegate?
    
    var title: String? {
        willSet {
            let aTitle = newValue ?? ""
            controlTopView.title = aTitle
        }
    }
    
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
        
        let margin: CGFloat = 10
        let minWidth: CGFloat = 44;
        let progressHeight: CGFloat = 34
        let controlTopViewHeight: CGFloat = 40
        
        playBtn.bounds = CGRect(x: 0, y: 0, width: minWidth, height: minWidth)
        playBtn.center = CGPoint(x: self.bounds.width * 0.5, y: self.bounds.height * 0.5)

        self.controlTopView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: controlTopViewHeight)
        self.controlBottomView.frame = CGRect(x: 0, y: self.bounds.height - controlTopViewHeight, width: self.bounds.width, height: controlTopViewHeight)
        
        fullScreenBtn.frame = CGRect(x: controlBottomView.frame.width - minWidth - margin, y: 0, width: minWidth, height: controlBottomView.frame.height)
        progressTimeView.frame = CGRect(x: 0, y: (controlBottomView.frame.height - progressHeight) * 0.5, width: fullScreenBtn.frame.origin.x, height: progressHeight)
        
        self.playBtn.alpha = 1
    }
}

// MARK:- UI
extension NJProtraitControlView {
    private func setupUIOnce() {
        self.backgroundColor = UIColor.clear
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("tabControlView")))
        self.clipsToBounds = true
    }
}

// MARK:- action
extension NJProtraitControlView {
    @objc func playOrPause(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        if btn.isSelected {
            protraitControlViewDelegate?.protraitControlView?(play: self)
        }else {
            protraitControlViewDelegate?.protraitControlView?(pause: self)
        }
    }
    @objc func fullScreenCick(btn: UIButton) {
       protraitControlViewDelegate?.protraitControlView?(fullScreen: self)
    }
}

// MARK:- control
extension NJProtraitControlView {
    @objc func tabControlView() {
        if self.playBtn.alpha < 1 {
            self.show()
        }else {
            self.hide()
        }
    }
    
    func hide() -> Void {
        let margin: CGFloat = 10
        let minWidth: CGFloat = 44
        let progressHeight: CGFloat = 34
        let controlTopViewHeight: CGFloat = 40
        [UIView .animate(withDuration: 0.3, animations: {
            self.controlTopView.frame = CGRect(x: 0, y: -controlTopViewHeight, width: self.bounds.width, height: controlTopViewHeight)
            self.controlBottomView.frame = CGRect(x: 0, y: self.bounds.height, width: self.bounds.width, height: controlTopViewHeight)
            self.playBtn.alpha = 0
        })];
    }
    func show() -> Void {
        let margin: CGFloat = 10
        let minWidth: CGFloat = 44
        let progressHeight: CGFloat = 34
        let controlTopViewHeight: CGFloat = 40
        [UIView .animate(withDuration: 0.3, animations: {
            self.controlTopView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: controlTopViewHeight)
            self.controlBottomView.frame = CGRect(x: 0, y: self.bounds.height - controlTopViewHeight, width: self.bounds.width, height: controlTopViewHeight)
            self.playBtn.alpha = 1
        })];
    }
}


// MARK:- NJControlTopViewDelegate
extension NJProtraitControlView: NJControlTopViewDelegate {
    func controlTopView(backClick controlTopView: NJControlTopView) {
        protraitControlViewDelegate?.protraitControlView?(gobackLayout: self)
    }
    func controlTopViewIsShowBackBtn(controlTopView: NJControlTopView) -> Bool {
        return false
    }
}

// MARK:- NJProgressTimeViewDelegate
extension NJProtraitControlView: NJProgressTimeViewDelegate {

}


