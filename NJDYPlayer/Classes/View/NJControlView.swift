//
//  NJControlView.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/7/21.
//

import UIKit

//    @objc optional func  playerController(playbackFinish playerController: NJPlayerController, userExited contentURLString: String)


class NJControlView: UIView {
    
    // MARK:- controlView
    private lazy var protraitControlView: NJProtraitControlView = {[weak self] in
        let protraitControlView = NJProtraitControlView()
        self?.addSubview(protraitControlView)
        return protraitControlView;
        }()
    private lazy var landScapeControlView: NJLandScapeControlView = {[weak self] in
        let landScapeControlView = NJLandScapeControlView()
        self?.addSubview(landScapeControlView)
        return landScapeControlView;
        }()
    
    public var isProtrait: Bool = true {
        willSet {
            if newValue {
                protraitControlView.show()
                landScapeControlView.hide()
            }else {
                protraitControlView.hide()
                landScapeControlView.show()
            }
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
    
}

extension NJControlView {
    func setupUIOnce() {
        self.backgroundColor = UIColor.clear
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        landScapeControlView.frame = self.bounds
        protraitControlView.frame = self.bounds
    }
}


