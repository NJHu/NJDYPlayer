//
//  NJPresentView.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/7/22.
//

import UIKit

@objc protocol NJPresentViewDelegate: NJControlViewDelegate {
    
}

class NJPresentView: UIView {
    
    public lazy var controlView: NJControlView = {[weak self] in
        let controlView = NJControlView()
        self?.addSubview(controlView)
        return controlView
        }()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIOnce()
    }
    
    weak var delegate: NJPresentViewDelegate? {
        willSet {
            controlView.delegate = newValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUIOnce()
    }
}


extension NJPresentView {
    override func layoutSubviews() {
        super.layoutSubviews()
        controlView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        self.bringSubviewToFront(controlView)
    }
    private func setupUIOnce() {
        self.backgroundColor = UIColor.black
    }
}
