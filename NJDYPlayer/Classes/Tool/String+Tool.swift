//
//  ViewController.swift
//  NJDYPlayer
//
//  Created by NJHu on 2018/7/14.
//

import UIKit

extension String {
    
    public func urlEncoding() -> String? {
        let characters = "`#%^{}\"[]|\\<> "
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.init(charactersIn: characters).inverted)
    }
}
