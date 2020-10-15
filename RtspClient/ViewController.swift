//
//  ViewController.swift
//  RtspClient
//
//  Created by Teocci on 18/05/16.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    var video: RTSPPlayer!
    var video2: RTSPPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        video = RTSPPlayer(video: "rtsp://192.168.50.40:554/user=admin&password=Hkumb155&channel=1&stream=0.rsp", usesTcp: true)
        video.outputWidth = Int32(imageView.bounds.width)
        video.outputHeight = Int32(imageView.bounds.height)
        video.seekTime(0.0)
        
        video2 = RTSPPlayer(video: "rtsp://192.168.50.41:554/user=admin&password=Hkumb155&channel=1&stream=0.rsp", usesTcp: true)
        
        video2.outputWidth = Int32(imageView2.bounds.width)
        video2.outputHeight = Int32(imageView2.bounds.height)
        video2.seekTime(0.0)
        
      let timer = Timer.scheduledTimer(timeInterval: 1.0/30, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        timer.fire()
      let timer2 = Timer.scheduledTimer(timeInterval: 1.0/50, target: self, selector: #selector(ViewController.update2), userInfo: nil, repeats: true)
        timer2.fire()
    }
    
    @objc func update(timer: Timer) {
        if(!video.stepFrame()){
            timer.invalidate()
            video.closeAudio()
        }

        imageView.image = video.currentImage
    }
    
    @objc func update2(timer2: Timer) {

        if(!video2.stepFrame()){
            timer2.invalidate()
            video2.closeAudio()
        }
        imageView2.image = video2.currentImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

