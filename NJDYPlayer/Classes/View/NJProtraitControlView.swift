//
//  NJProtraitControlView.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/7/21.
//

import UIKit

protocol NJProtraitControlViewDelegate {
    func protraitControlView(gobackLayout protraitControlView: NJProtraitControlView) -> Void
}

class NJProtraitControlView: UIView {
    
    private lazy var controlTopView: NJControlTopView = {[weak self] in
        let controlTopView = NJControlTopView()
        controlTopView.delegate = self
        self?.addSubview(controlTopView)
        return controlTopView
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
        controlTopView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 40)
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
        self.isHidden = false
    }
    func hide() -> Void {
        self.isHidden = true
    }
}


// MARK:- NJControlTopViewDelegate
extension NJProtraitControlView: NJControlTopViewDelegate {
    func controlTopView(backClick controlTopView: NJControlTopView) {
        protraitControlViewDelegate?.protraitControlView(gobackLayout: self)
    }
    func controlTopViewIsShowBackBtn(controlTopView: NJControlTopView) -> Bool {
        return false
    }
}


