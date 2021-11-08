//
//  MonitorViewController.swift
//  RtspClient
//
//  Created by hkuit155 on 16/2/2021.
//  Copyright © 2021 Andres Rojas. All rights reserved.
//

import UIKit
import AVFoundation

class MonitorViewController: UIViewController {

    var client = NetworkConnectivity(host: Json.addressData.server_ip, port: Json.addressData.server_port)
    var video1: RTSPPlayer!
    var video2: RTSPPlayer!
    let emptyBboxRect: [CGRect] = [CGRect(x: 0, y: 0, width: 0, height: 0)]
    var coords = Coords()
    var normalCnt: Int = 0
    let lock = NSLock()
    var hasVideoSet = false
    let normalStd = 20
    let customCharSet: CharacterSet = CharacterSet(charactersIn: "}")
    let planeImg = #imageLiteral(resourceName: "pool")
    let radius: CGFloat = 25.0
    let alarmPlayer: AVAudioPlayer = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "alarm", withExtension: "mp3")!)
    
    
    @IBOutlet weak var cam1: UIImageView!
    @IBOutlet weak var cam2: UIImageView!
    @IBOutlet weak var cam3: UIImageView!
    @IBOutlet weak var cam4: UIImageView!
    @IBOutlet weak var cam1s: UIImageView!
    @IBOutlet weak var cam2s: UIImageView!
    @IBOutlet weak var cam3s: UIImageView!
    @IBOutlet weak var cam4s: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var plane: UIImageView!
    @IBOutlet weak var monitorPage: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBAction func changePage(_ sender: UIPageControl) {
        let point = CGPoint(x: monitorPage.bounds.width * CGFloat(sender.currentPage), y: 0)
        monitorPage.setContentOffset(point, animated: true)
        self.changeBorder(page: sender.currentPage)
    }
    @IBAction func changeToAllCams(_ sender: UIBarButtonItem) {
//        pageControl.currentPage = 4
//        monitorPage.setContentOffset(CGPoint(x: monitorPage.bounds.width * 4, y: 0), animated: true)
//        self.changeBorder(page: 4)
        self.client.stop()
    }
    @IBAction func RefreshConnection(_ sender: UIBarButtonItem) {
        // MARK: 1. Server Connection 2. Camera Connection
        self.client.updateAddress(host: Json.addressData.server_ip, port: Json.addressData.server_port)
        self.client.stop()
        self.client.setup()
        if !self.hasVideoSet {
            videoSetup()
            self.hasVideoSet = false
        }
    }
    
    @IBAction func StopAlarm(_ sender: Any) {
        self.client.sendReset()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.client.networkStatusDelegate = self
        
        self.cam1.image = #imageLiteral(resourceName: "Cam1")
        self.cam2.image = #imageLiteral(resourceName: "Cam2")
        self.cam3.image = #imageLiteral(resourceName: "Cam3")
        self.cam4.image = #imageLiteral(resourceName: "Cam4")
        self.cam1s.image = #imageLiteral(resourceName: "Cam1")
        self.cam2s.image = #imageLiteral(resourceName: "Cam2")
        self.cam3s.image = #imageLiteral(resourceName: "Cam3")
        self.cam4s.image = #imageLiteral(resourceName: "Cam4")
        label1.layer.borderWidth = 3.0
        label1.layer.borderColor = UIColor.green.cgColor
        label2.layer.borderWidth = 3.0
        label3.layer.borderWidth = 3.0
        label4.layer.borderWidth = 3.0
        
        self.monitorPage.showsHorizontalScrollIndicator = false
        self.monitorPage.showsVerticalScrollIndicator = false
        self.monitorPage.bounces = true
        
        self.alarmPlayer.numberOfLoops = -1
        
        Json.readJson()
        
    } // viewDidLoad
    
    // MARK: - self functions
    
    func changeBorder(page: Int) {
        switch page {
        case 0:
            label1.layer.borderColor = UIColor.green.cgColor
            label2.layer.borderColor = UIColor.yellow.cgColor
            label3.layer.borderColor = UIColor.yellow.cgColor
            label4.layer.borderColor = UIColor.yellow.cgColor
        case 1:
            label1.layer.borderColor = UIColor.yellow.cgColor
            label2.layer.borderColor = UIColor.green.cgColor
            label3.layer.borderColor = UIColor.yellow.cgColor
            label4.layer.borderColor = UIColor.yellow.cgColor
        case 2:
            label1.layer.borderColor = UIColor.yellow.cgColor
            label2.layer.borderColor = UIColor.yellow.cgColor
            label3.layer.borderColor = UIColor.green.cgColor
            label4.layer.borderColor = UIColor.yellow.cgColor
        case 3:
            label1.layer.borderColor = UIColor.yellow.cgColor
            label2.layer.borderColor = UIColor.yellow.cgColor
            label3.layer.borderColor = UIColor.yellow.cgColor
            label4.layer.borderColor = UIColor.green.cgColor
        case 4:
            label1.layer.borderColor = UIColor.green.cgColor
            label2.layer.borderColor = UIColor.green.cgColor
            label3.layer.borderColor = UIColor.green.cgColor
            label4.layer.borderColor = UIColor.green.cgColor
        default:
            label1.layer.borderColor = UIColor.black.cgColor
            label2.layer.borderColor = UIColor.black.cgColor
            label3.layer.borderColor = UIColor.black.cgColor
            label4.layer.borderColor = UIColor.black.cgColor
        }
    } // changeBorder
    
    @objc func update(timer: Timer) {
        if(!video1.stepFrame()){
            timer.invalidate()
            video1.closeAudio()
        }
        
        if video1.currentImage != nil {
            self.lock.lock()
            cam1.image = drawBbox2(img: video1.currentImage, bboxRect: self.coords.camBbox[0])
            cam1s.image = cam1.image
            
            self.lock.unlock()
        }
    }
    @objc func update2(timer: Timer) {
        if(!video2.stepFrame()){
            timer.invalidate()
            video2.closeAudio()
        }

        if video2.currentImage != nil {
            self.lock.lock()
            cam2.image = drawBbox2(img: video2.currentImage, bboxRect: self.coords.camBbox[1])
            cam2s.image = cam2.image
            self.lock.unlock()
        }
    }
    
    func videoSetup() {
        DispatchQueue.global().async {
            var stopwatch = StopWatch()
            print("Connecting camera ...")
            
            stopwatch.startCount()
            self.video1 = RTSPPlayer(video: Json.addressData.cam_urls[0], usesTcp: true)

            
            if self.video1 != nil {
                print(stopwatch.intermediateResult())
                DispatchQueue.main.async {
                    self.video1.outputWidth = Int32(self.cam1.bounds.width)
                    self.video1.outputHeight = Int32(self.cam1.bounds.height)
                    self.video1.seekTime(0.0)
                    let timer1 = Timer.scheduledTimer(timeInterval: 1.0/30, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
                      timer1.fire()
                    stopwatch.endCount()
                    print(stopwatch.result())
                }
            }
        }
        DispatchQueue.global().async {
            print("Connecting camera...")
            print(Json.addressData.cam_urls[1])
            self.video2 = RTSPPlayer(video: Json.addressData.cam_urls[1], usesTcp: true)
            if self.video2 != nil {
                DispatchQueue.main.async {
                    self.video2.outputWidth = Int32(self.cam2.bounds.width)
                    self.video2.outputHeight = Int32(self.cam2.bounds.height)
                    self.video2.seekTime(0.1)
                    let timer2 = Timer.scheduledTimer(timeInterval: 1.0/30, target: self, selector: #selector(self.update2), userInfo: nil, repeats: true)
                      timer2.fire()
                }
            }
        }
    }
    
    func drawBbox2(img:UIImage, bboxRect: [CGRect]) -> UIImage {
        if (bboxRect.count == 0) {
            return img
        }
        let renderer = UIGraphicsImageRenderer(size: img.size)
        let result = renderer.image { ctx in
            ctx.cgContext.setStrokeColor(UIColor.red.cgColor)
            ctx.cgContext.setLineWidth(5.0)
            ctx.cgContext.concatenate(.flippingVerticaly(img.size.height))
            ctx.cgContext.draw(img.cgImage!, in: CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height))
            for rect in bboxRect {
                ctx.cgContext.concatenate(.flippingVerticaly(img.size.height))
                ctx.cgContext.addRect(rect)
                ctx.cgContext.drawPath(using: .stroke)
            }
        }
        return result
    }
    
    func drawPlane2(locs: [Int]) {
        if (locs[0] == -1) {
            self.plane.image = self.planeImg
            return
        }
        let imgSize = self.planeImg.size
        let width: CGFloat = self.planeImg.size.width / 12
        let height: CGFloat = self.planeImg.size.height / 4

        let renderer = UIGraphicsImageRenderer(size: imgSize)
        let result = renderer.image { ctx in
            ctx.cgContext.concatenate(.flippingVerticaly(imgSize.height))
            ctx.cgContext.draw(self.planeImg.cgImage!, in: CGRect(x: 0, y: 0, width: imgSize.width, height: imgSize.height))
            for div in locs {
                ctx.cgContext.concatenate(.flippingVerticaly(imgSize.height))
                let offsetX = CGFloat(div % 12)
                let offsetY = CGFloat(floor(Double(div/12)))
                let x = offsetX * width + width/2 - self.radius
                let y = offsetY * height + height/2 - self.radius
                let dotRect = CGRect(x: x, y: y, width: self.radius, height: self.radius)
                ctx.cgContext.addEllipse(in: dotRect)
                ctx.cgContext.drawPath(using: .fill)
            }
        }
        self.plane.image = result
        return
    }
    
    func drawBbox(img: UIImage, bboxRect: [CGRect]) -> UIImage
    {
//        return autoreleasepool{() -> UIImage in
            if (bboxRect.count == 0) {
                return img
            }
            let imgSize = img.size
            UIGraphicsBeginImageContextWithOptions(imgSize, false, 1.0)
            let context = UIGraphicsGetCurrentContext()
            img.draw(at: CGPoint.zero)
            context?.setLineWidth(5.0)
            UIColor.red.set()
            
            for rect in bboxRect {
                context?.addRect(rect)
                context?.strokePath()
            }
//            var newImg:UIImage = img
//            autoreleasepool{
                let newImg = UIGraphicsGetImageFromCurrentImageContext() ?? img
//            }
            
            UIGraphicsEndImageContext()
            return newImg
//        }
    }
    
    func drawPlane(locs: [Int]) {
        let img = self.planeImg
        
        if (locs[0] == -1) {
            self.plane.image = self.planeImg
            return
        }
        
        let imgSize = self.planeImg.size
        let width: CGFloat = self.planeImg.size.width / 12
        let height: CGFloat = self.planeImg.size.height / 4
        
        UIGraphicsBeginImageContextWithOptions(imgSize, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        
        img.draw(at: CGPoint.zero)
//        context?.setStrokeColor(UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor)
        context?.setFillColor(UIColor.red.cgColor)
        for div in locs {
            let offsetX = CGFloat(div % 12)
            let offsetY = CGFloat(floor(Double(div/12)))
//            print("offsetX: \(offsetX), offsetY: \(offsetY)")
            let x = offsetX * width + width/2 - self.radius
            let y = offsetY * height + height/2 - self.radius
            let dotRect = CGRect(x: x, y: y, width: self.radius, height: self.radius)
            context?.fillEllipse(in: dotRect)
        }
        
        let newImg = UIGraphicsGetImageFromCurrentImageContext() ?? img
        UIGraphicsEndImageContext()
        
        self.plane.image = newImg
    }
    
    func playAlarm() {
        if (!self.alarmPlayer.isPlaying) {
//            print("sound play")
            self.alarmPlayer.play()
        }
    }
    func pauseAlarm() {
        if (self.alarmPlayer.isPlaying) {
//            print("sound paused")
            self.alarmPlayer.pause()
        }
    }
    
}

extension MonitorViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        pageControl.currentPage = page
        self.changeBorder(page: page)
    }
} // UIScrollViewDelegate

extension MonitorViewController: NetworkConnectivityDelegate {
    func networkStatusChanged(online: Bool, connectivityStatus: String, msg: String) {
        DispatchQueue.main.async {
            if (msg != "") {
                print(msg)
//                print("msg.count: ", msg.count)
//                print(msg)
                if (msg != "{}" && msg.count <= 8000) {
                    self.coords.extractCoords(msg: msg, x: Double(self.cam1.bounds.width), y: Double(self.cam1.bounds.height))
                    self.drawPlane2(locs: self.coords.camLoc)
                    self.playAlarm()
                    self.normalCnt = 0
                } else {
//                    print("no drowning")
                    self.normalCnt += 1
                    if (self.normalCnt == self.normalStd) {
                        self.coords.camBbox = [[],[],[],[]]
                        self.coords.camLoc = [-1]
                        self.drawPlane2(locs: self.coords.camLoc)
                        self.normalCnt = 0
                        self.pauseAlarm()
                    }
                    
                }
            } else {
                self.normalCnt += 1
                if (self.normalCnt == self.normalStd) {
                    self.coords.camBbox = [[],[],[],[]]
                    self.coords.camLoc = [-1]
                    self.drawPlane2(locs: self.coords.camLoc)
                    self.normalCnt = 0
                    self.pauseAlarm()
                }
            }
        }
    }
}

extension CGAffineTransform {
    static func flippingVerticaly(_ height: CGFloat) -> CGAffineTransform {
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -height)
        return transform
    }
}
