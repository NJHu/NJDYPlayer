//
//  NJCommonView.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/7/22.
//

import UIKit

protocol NJControlTopViewDelegate {
    func controlTopView(goProtrait controlTopView: NJControlTopView) -> Void
    func controlTopViewIsProtrait(controlTopView: NJControlTopView) -> Bool
}

class NJControlTopView: UIView {
    
    private lazy var bgImageView = UIImageView(image: UIImage.njPL_image(name: "ZFPlayer_top_shadow", bundleClass: NJControlTopView.self))
    
    private lazy var backBtn: UIButton = {[weak self] in
        let btn = UIButton(type: UIButtonType.custom)
        btn.setImage(UIImage.njPL_image(name: "ZFPlayer_back_full", bundleClass: NJProtraitControlView.self), for: .normal)
        btn.addTarget(self, action: #selector(goProtrait(btn:)), for: .touchUpInside)
        return btn;
        }()
    
    private lazy var titleLabel: UILabel = {[weak self] in
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        return titleLabel;
        }()
    
    public var title: String? {
        willSet {
            self.titleLabel.text = newValue
        }
    }
    
    var delegate: NJControlTopViewDelegate?
    
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
        bgImageView.frame = self.bounds
        backBtn.frame = CGRect(x: 20, y: 0, width: 44, height: self.bounds.size.height)
        backBtn.isHidden = delegate?.controlTopViewIsProtrait(controlTopView: self) ?? false
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(x: 10 +  (backBtn.isHidden ? 0 : backBtn.frame.maxX), y: (self.bounds.height - titleLabel.bounds.height) * 0.5, width: titleLabel.bounds.width, height: titleLabel.bounds.height)
    }
    
    private func setupUI() {
        self.addSubview(bgImageView)
        self.addSubview(backBtn)
        backBtn.isHidden = true
        self.addSubview(titleLabel)
    }
    @objc func goProtrait(btn: UIButton) {
        delegate?.controlTopView(goProtrait: self)
    }
}



















































































