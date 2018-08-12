//
//  NJProgressTimeView.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/8/12.
//

import UIKit

@objc protocol NJProgressTimeViewDelegate: NSObjectProtocol {
//    @objc optional func
}

class NJProgressTimeView: UIView {
    
    private lazy var currentTimeLabel: UILabel = {[weak self] in
       let currentTimeLabel = UILabel()
        currentTimeLabel.textColor = UIColor.white
        currentTimeLabel.font = UIFont.systemFont(ofSize: 12)
        currentTimeLabel.textAlignment = .center
        currentTimeLabel.text = 0.njPL_formarToProgerssTime()
        self?.addSubview(currentTimeLabel)
        return currentTimeLabel
    }()
    
    private lazy var endTimeLabel: UILabel = {[weak self] in
        let endTimeLabel = UILabel()
        endTimeLabel.textColor = UIColor.white
        endTimeLabel.font = UIFont.systemFont(ofSize: 12)
        endTimeLabel.textAlignment = .center
        endTimeLabel.text = 1.njPL_formarToProgerssTime()
        self?.addSubview(endTimeLabel)
        return endTimeLabel
        }()
    
    weak var delegate: NJProgressTimeViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let timeWidth: CGFloat = 70
        currentTimeLabel.frame = CGRect(x: 0, y: 0, width: timeWidth, height: self.bounds.height)
        endTimeLabel.frame = CGRect(x: self.bounds.width - timeWidth, y: 0, width: timeWidth, height: self.bounds.height)
    }
}

extension NJProgressTimeView {
    func setupUI() -> Void {
        
    }
}
