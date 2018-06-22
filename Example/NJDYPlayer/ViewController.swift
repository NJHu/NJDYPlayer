//
//  ViewController.swift
//  NJDYPlayer
//
//  Created by njhu on 06/20/2018.
//  Copyright (c) 2018 njhu. All rights reserved.
//

import UIKit
import IJKMediaFramework

class ViewController: UIViewController {

    @IBOutlet weak var vcPlayContainerView: UIView!
    
    public var videoUrl = "http://tb-video.bdstatic.com/videocp/12045395_f9f87b84aaf4ff1fee62742f2d39687f.mp4"
    lazy var player: IJKFFMoviePlayerController = IJKFFMoviePlayerController(contentURLString: videoUrl, with: IJKFFOptions.byDefault())
    override func viewDidLoad() {
        super.viewDidLoad()
        vcPlayContainerView.addSubview(player.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !player.isPlaying() {
            player.prepareToPlay()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        player.view.frame = vcPlayContainerView.bounds
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

