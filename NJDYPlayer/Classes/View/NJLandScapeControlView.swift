//
//  NJLandScapeControlView.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/7/21.
//

import UIKit

@objc protocol NJLandScapeControlViewDelegate: NSObjectProtocol {
    @objc optional func landScapeControlView(gobackLayout landScapeControlView: NJLandScapeControlView) -> Void
    @objc optional  func landScapeControlView(play landScapeControlView: NJLandScapeControlView) -> Void
    @objc optional func landScapeControlView(pause landScapeControlView: NJLandScapeControlView) -> Void
}

class NJLandScapeControlView: UIView {
    
    private lazy var controlTopView: NJControlTopView = {[weak self] in
        let controlTopView = NJControlTopView()
        controlTopView.delegate = self
        self?.addSubview(controlTopView)
        return controlTopView
        }()
    
    private lazy var controlBottomView: UIView = {[weak self] in
        let controlBottomView = UIView()
        self?.addSubview(controlBottomView)
        controlBottomView.layer.contents = UIImage.njPL_image(name: "ZFPlayer_bottom_shadow", bundleClass: NJLandScapeControlView.self)?.cgImage
        return controlBottomView
        }()
    
    lazy var progressTimeView: NJProgressTimeView = {[weak self] in
        let progressTimeView = NJProgressTimeView()
        progressTimeView.delegate = self
        self?.controlBottomView.addSubview(progressTimeView)
        return progressTimeView
        }()
    
    private lazy var playBtn: UIButton = {[weak self] in
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setImage(UIImage.njPL_image(name: "ZFPlayer_pause", bundleClass: NJProtraitControlView.self), for: .selected)
        btn.setImage(UIImage.njPL_image(name: "ZFPlayer_play", bundleClass: NJProtraitControlView.self), for: .normal)
        btn.addTarget(self, action: #selector(playOrPause(btn:)), for: .touchUpInside)
        self?.controlBottomView.addSubview(btn)
        return btn;
        }()
    
    // MARK:- delegate
    weak public var landScapeControlViewDelegate: NJLandScapeControlViewDelegate?
    
    var title: String? {
        willSet {
            let aTitle = newValue ?? ""
            controlTopView.title = aTitle
        }
    }
    
    var playing: Bool = true {
        didSet {
            playBtn.isSelected = playing
        }
    }
    
    private lazy var isShowRecord: NSObject = NSObject()
    
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
        let controlHeight: CGFloat = 80
        let controlBottomHeight: CGFloat = 40
        let selfHeight: CGFloat = self.frame.size.height
        let selfWidth: CGFloat = self.frame.size.width
        let playBtnWidth: CGFloat = 44
        let margin: CGFloat = 10
        let progressHeight: CGFloat = 34
        
        progressTimeView.frame = CGRect(x: margin + playBtnWidth + margin, y: (controlBottomHeight - progressHeight) * 0.5, width: selfWidth - (margin + playBtnWidth + margin + margin), height: progressHeight)
        playBtn.frame = CGRect(x: margin, y: (controlBottomHeight - playBtnWidth) * 0.5, width: playBtnWidth, height: playBtnWidth)
        
        self.controlTopView.frame = CGRect(x: 0, y: 0, width: selfWidth, height: controlHeight)
        self.controlBottomView.frame = CGRect(x: 0, y: selfHeight - controlBottomHeight, width: selfWidth, height: controlBottomHeight)
        self.playBtn.alpha = 1
        self.afterHide()
    }
}

// MARK:- UI
extension NJLandScapeControlView {
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
extension NJLandScapeControlView {
    @objc func playOrPause(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        if btn.isSelected {
            landScapeControlViewDelegate?.landScapeControlView?(play: self)
        }else {
            landScapeControlViewDelegate?.landScapeControlView?(pause: self)
        }
    }
}

// MARK:- control
extension NJLandScapeControlView {
    @objc func tabControlView() {
        if self.playBtn.alpha < 1 {
            self.show()
        }else {
            self.hide()
        }
    }
    
    func hide() -> Void {
        let controlHeight: CGFloat = 80
        let selfHeight: CGFloat = self.frame.size.height
        
        UIView.animate(withDuration: 0.3, animations: {
            self.controlTopView.frame.origin = CGPoint(x: 0, y: -controlHeight)
            self.controlBottomView.frame.origin = CGPoint(x: 0, y: selfHeight)
            self.playBtn.alpha = 0
        });
    }
    func show() -> Void {
        let controlBottomHeight: CGFloat = 40
        let selfHeight: CGFloat = self.frame.size.height
        
        UIView.animate(withDuration: 0.3, animations: {
            self.controlTopView.frame.origin = CGPoint(x: 0, y: 0)
            self.controlBottomView.frame.origin = CGPoint(x: 0, y: selfHeight - controlBottomHeight)
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
extension NJLandScapeControlView: NJControlTopViewDelegate {
    func controlTopView(backClick controlTopView: NJControlTopView) {
        landScapeControlViewDelegate?.landScapeControlView?(gobackLayout: self)
    }
    func controlTopViewIsShowBackBtn(controlTopView: NJControlTopView) -> Bool {
        return true
    }
}

extension NJLandScapeControlView: NJProgressTimeViewDelegate {
    
}


