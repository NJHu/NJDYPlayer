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
        let fullScreenBtn = UIButton(type: UIButton.ButtonType.custom)
        fullScreenBtn.setImage(UIImage.njPL_image(name: "ZFPlayer_fullscreen", bundleClass: NJProtraitControlView.self), for: .normal)
        fullScreenBtn.addTarget(self, action: #selector(fullScreenCick(btn:)), for: .touchUpInside)
        self?.controlBottomView.addSubview(fullScreenBtn)
        return fullScreenBtn;
        }()

    private lazy var playBtn: UIButton = {[weak self] in
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setBackgroundImage(UIImage.njPL_image(name: "new_allPause_44x44_", bundleClass: NJProtraitControlView.self), for: .selected)
        btn.setBackgroundImage(UIImage.njPL_image(name: "new_allPlay_44x44_", bundleClass: NJProtraitControlView.self), for: .normal)
        btn.addTarget(self, action: #selector(playOrPause(btn:)), for: .touchUpInside)
        self?.addSubview(btn)
        return btn;
        }()
    
    private lazy var isShowRecord: NSObject = NSObject()
    
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
        let selfHeight: CGFloat = self.frame.size.height
        let selfWidth: CGFloat = self.frame.size.width
        
        playBtn.bounds = CGRect(x: 0, y: 0, width: minWidth, height: minWidth)
        playBtn.center = CGPoint(x: selfWidth * 0.5, y: selfHeight * 0.5)
        
        controlTopView.frame = CGRect(x: 0, y: 0, width: selfWidth, height: controlTopViewHeight)
        controlBottomView.frame = CGRect(x: 0, y: selfHeight - controlTopViewHeight, width: selfWidth, height: controlTopViewHeight)
        
        fullScreenBtn.frame = CGRect(x: selfWidth - minWidth - margin, y: 0, width: minWidth, height: controlTopViewHeight)
        progressTimeView.frame = CGRect(x: 0, y: (controlTopViewHeight - progressHeight) * 0.5, width: selfWidth - minWidth - margin, height: progressHeight)
        
        self.playBtn.alpha = 1
        self.afterHide()
    }
}

// MARK:- UI
extension NJProtraitControlView {
    private func setupUIOnce() {
        self.backgroundColor = UIColor.clear
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("tabControlView")))
        self.clipsToBounds = true
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
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
        let controlTopViewHeight: CGFloat = 40
        let selfHeight: CGFloat = self.frame.size.height
        
        UIView.animate(withDuration: 0.3, animations: {
            self.controlTopView.frame.origin = CGPoint(x: 0, y: -controlTopViewHeight)
            self.controlBottomView.frame.origin = CGPoint(x: 0, y: selfHeight)
            self.playBtn.alpha = 0
        });
    }
    func show() -> Void {
        let selfHeight: CGFloat = self.frame.size.height
        let controlTopViewHeight: CGFloat = 40
        
        UIView.animate(withDuration: 0.3, animations: {
            self.controlTopView.frame.origin = CGPoint(x: 0, y: 0)
            self.controlBottomView.frame.origin = CGPoint(x: 0, y: selfHeight - controlTopViewHeight)
            self.playBtn.alpha = 1
        }) { (isFinished) in
        
            self.afterHide()
        };
    }
    func afterHide() -> Void {
        
        self.isShowRecord = NSObject()
        let curObj = self.isShowRecord
        
        let tinyDelay = DispatchTime.now() + Double(Int64(5 * Float(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: tinyDelay) {
            if curObj != self.isShowRecord {
                return
            }
            self.hide()
        }
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


