//
//  NJLandScapeControlView.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/7/21.
//

import UIKit

protocol NJLandScapeControlViewDelegate: NSObjectProtocol {
    func landScapeControlView(gobackLayout landScapeControlView: NJLandScapeControlView) -> Void
}

class NJLandScapeControlView: UIView {
    
    private lazy var controlTopView: NJControlTopView = {[weak self] in
        let controlTopView = NJControlTopView()
        controlTopView.delegate = self
        self?.addSubview(controlTopView)
        return controlTopView
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
        controlTopView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 80)
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
    func controlTopView(backClick controlTopView: NJControlTopView) {
        landScapeControlViewDelegate?.landScapeControlView(gobackLayout: self)
    }
    func controlTopViewIsShowBackBtn(controlTopView: NJControlTopView) -> Bool {
        return true
    }
}


