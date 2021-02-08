//
//  ViewController.swift
//  RtspClient
//
//  Created by Teocci on 18/05/16.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var ipInput: UITextField!
    @IBOutlet weak var portInput: UITextField!
    @IBOutlet weak var msgOutput: UILabel!
    @IBOutlet weak var greenLed: UIImageView!
    @IBOutlet weak var yellowLed: UIImageView!
    @IBOutlet weak var redLed: UIImageView!
    
    var video1: RTSPPlayer!
    var video2: RTSPPlayer!
    var videoSetupOnce = false
    
    var client = NetworkConnectivity(host: "", port: 0)
    let emptyBboxRect: [CGRect] = [CGRect(x: 0, y: 0, width: 0, height: 0)]
//    var bboxRect: [Double] = [0, 0, 0, 0]
    
    @IBAction func connectBtn(_ sender: UIButton) {
        if !videoSetupOnce {
//            videoSetup()
            videoSetupOnce = true
        }
        initClient(host: self.ipInput.text ?? "localhost", port: Int((self.portInput.text! as NSString).intValue))
    }
    @IBAction func disconnectBtn(_ sender: UIButton) {
        stopClient()
    }
    
    func initClient(host: String, port: Int) {
        self.client.updateAddress(host: host, port: port)
        self.client.stop()
        self.client.setup()
    }
    
    func stopClient() {
        self.client.stop()
    }
    
    func videoSetup()
    {
        /// Lab: 44
        /// Pool: 40,41,42,50
        video1 = RTSPPlayer(video: "rtsp://192.168.50.44:554/user=admin&password=Hkumb155&channel=1&stream=0.rsp", usesTcp: true)
        
        if video1 != nil {
            video1.outputWidth = Int32(imageView1.bounds.width)
            video1.outputHeight = Int32(imageView1.bounds.height)
            video1.seekTime(0.0)
            
            let timer1 = Timer.scheduledTimer(timeInterval: 1.0/30, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
              timer1.fire()
        }

//        video2 = RTSPPlayer(video: "rtsp://192.168.50.44:554/user=admin&password=Hkumb155&channel=1&stream=0.rsp", usesTcp: true)
//
//        if video2 != nil {
//            video2.outputWidth = Int32(imageView2.bounds.width)
//            video2.outputHeight = Int32(imageView2.bounds.height)
//            video2.seekTime(0.0)
//
//            let timer2 = Timer.scheduledTimer(timeInterval: 1.0/50, target: self, selector: #selector(ViewController.update2), userInfo: nil, repeats: true)
//              timer2.fire()
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.client.networkStatusDelegate = self
    }
    
    @objc func update(timer: Timer) {
        if(!video1.stepFrame()){
            timer.invalidate()
            video1.closeAudio()
        }
//        imageView1.image = video1.currentImage
        imageView1.image = drawBbox(img: video1.currentImage, bboxRect: self.emptyBboxRect)
    }
    
    @objc func update2(timer2: Timer) {

        if(!video2.stepFrame()){
            timer2.invalidate()
            video2.closeAudio()
        }
        imageView2.image = video2.currentImage
    }
    
    func drawBbox(img: UIImage, bboxRect: [CGRect]) -> UIImage
    {
        let imgSize = img.size
        
        UIGraphicsBeginImageContextWithOptions(imgSize, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        img.draw(at: CGPoint.zero)
        context?.setLineWidth(5.0)
        UIColor.purple.set()
        for rect in bboxRect {
            context?.addRect(rect)
            context?.strokePath()
        }
        let newImg = UIGraphicsGetImageFromCurrentImageContext() ?? img
        UIGraphicsEndImageContext()
        return newImg
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: NetworkConnectivityDelegate {
    func networkStatusChanged(online: Bool, connectivityStatus: String, msg: String) {
        DispatchQueue.main.async {
            self.msgOutput.text = msg
            if msg != "" {
                var boxCnt: Int = 0
                if (msg != "0") {
                    let bbox = msg.components(separatedBy: ", ")
                    var bboxRect: [CGRect] = []
                    boxCnt = bbox.count / 4
                    for i in 1...boxCnt {
                        let box: CGRect = CGRect(x: Int(bbox[4*(i-1)])! * Int(self.imageView1.bounds.width) / 960, y: Int(bbox[1+4*(i-1)])! * Int(self.imageView1.bounds.height) / 540, width: Int(bbox[2+4*(i-1)])! * Int(self.imageView1.bounds.width) / 960, height: Int(bbox[3+4*(i-1)])! * Int(self.imageView1.bounds.height) / 540)
                        bboxRect.append(box)
                    }
                    self.imageView1.layer.borderColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor
                    self.imageView1.layer.borderWidth = 5
//                    self.greenLed.image = UIImage(named: "greenoff")
//                    self.redLed.image = UIImage(named: "redon")
//                    self.yellowLed.image = UIImage(named: "yellowoff")
                    self.imageView1.image = self.drawBbox(img: UIImage(named: "hkulogo")!, bboxRect: bboxRect)
                    
                } else {
                    self.imageView1.layer.borderColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1).cgColor
                    self.imageView1.layer.borderWidth = 5
//                    self.greenLed.image = UIImage(named: "greenon.png")
//                    self.redLed.image = UIImage(named: "redoff")
//                    self.yellowLed.image = UIImage(named: "yellowoff")
                    self.imageView1.image = self.drawBbox(img: UIImage(named: "hkulogo")!, bboxRect: self.emptyBboxRect)
                }
            }
        }
    }
}
