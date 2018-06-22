//
//  AppDelegate.swift
//  NJDYPlayer
//
//  Created by njhu on 06/20/2018.
//  Copyright (c) 2018 njhu. All rights reserved.
//

import UIKit

public class NJPlayerView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI()
    {
        
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
    }
}
