//
//  ViewController.swift
//  NJDYPlayer
//
//  Created by njhu on 06/20/2018.
//  Copyright (c) 2018 njhu. All rights reserved.
//

import UIKit
import IJKMediaFramework
import NJDYPlayer

class ViewController: UIViewController {

    @IBOutlet weak var vcPlayContainerView: UIView!
    
    public var videoUrl = "http://tb-video.bdstatic.com/videocp/12045395_f9f87b84aaf4ff1fee62742f2d39687f.mp4"
    lazy var player : NJPlayerController = NJPlayerController(containerView: vcPlayContainerView)
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

    @IBAction func playVideo(_ sender: Any) {

    }
    @IBAction func pauseVideo(_ sender: Any) {

    }
    
    @IBAction func nextPage(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

