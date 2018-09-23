//
//  NJPlayProgressView.swift
//  NJDYPlayer
//
//  Created by HuXuPeng on 2018/8/14.
//

import UIKit

class NJPlayProgressView: UIView {

    private lazy var dotView = UIView()
    private lazy var lineView = UIView()
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
    }
}

extension NJPlayProgressView
{
    private func setupUI() {
        addSubview(lineView)
        addSubview(dotView)
    }
}
