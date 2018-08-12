//
//  ViewController.swift
//  NJDYPlayer
//
//  Created by NJHu on 2018/7/14.
//

import UIKit

extension String {
    
    func urlEncoding() -> String? {
        let characters = "`#%^{}\"[]|\\<> "
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.init(charactersIn: characters).inverted)
    }
}

extension Int {
    // 00:00
    func njPL_formarToProgerssTime() -> String {
        if self < 0 {
            return "00:00"
        }
        var time = ""
        let hour = self / 3600
        let min = (self - 3600 * hour) / 60
        let sec = (self - 3600 * hour) % 60
        if hour > 0 {
            time += String(format: "%02d:", hour)
        }
        time += String(format: "%02d:", min)
        time += String(format: "%02d", sec)
        return time
    }
}

extension Bundle {
    static func njPL_curBundle(class bundleOfClass: AnyClass?, bundleFile: String? = nil) -> Bundle {
        
        var bundle = bundleOfClass == nil ? Bundle.main : Bundle(for: bundleOfClass!)
        
        if let path = bundle.path(forResource: bundleFile, ofType: "bundle") {
            if let newBundle = Bundle.init(path: path) {
                bundle = newBundle
            }
        }
        
        return bundle
    }
}

extension UIImage {
    static func njPL_image(name: String, bundleClass: AnyClass?, bundleFile: String? = nil) -> UIImage? {
        var image: UIImage?
        
        let bundle = bundleClass == nil ? Bundle.main : Bundle(for: bundleClass!)
        
        image = self.init(named: name, in: bundle, compatibleWith: nil)
        
        if image == nil, let path = bundle.path(forResource: bundleFile, ofType: "bundle") {
            image = self.init(named: name, in: Bundle.init(path: path), compatibleWith: nil)
        }
        
        if image == nil && bundleClass != nil {
            let nameSpace = NSStringFromClass(bundleClass!).components(separatedBy: ".").first
            if let nameS = nameSpace,  let path = bundle.path(forResource: nameS, ofType: "bundle"){
                image = self.init(named: name, in: Bundle.init(path: path), compatibleWith: nil)
            }
        }
        
        return image
    }
}

extension UIApplication {
    
}
