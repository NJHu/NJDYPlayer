//
//  NJPresentView.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/7/22.
//

import UIKit

protocol NJPresentViewDelegate {

}

class NJPresentView: UIView {
    
    public lazy var controlView: NJControlView = {[weak self] in
        let controlView = NJControlView()
        return controlView
        }()
    
    var presentViewDelegate: NJPresentViewDelegate?
    
    private override init(frame: CGRect) {
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


extension NJPresentView {
    override func layoutSubviews() {
        super.layoutSubviews()
        controlView.frame = self.bounds
    }
    private func setupUIOnce() {
        self.backgroundColor = UIColor.black
    }
}
