//
//  VideoPlayback.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 7/29/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class VideoPlayback: UIViewController {
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    var previewing = true
    @IBOutlet var previewLabel: UILabel!
    
    var videoURL: URL!
    //connect this to your uiview in storyboard
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = videoView.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        videoView.layer.insertSublayer(avPlayerLayer, at: 0)
        self.navigationController?.navigationBar.isHidden = false
        view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: videoURL as URL)
        LatestVideoURL.pathString = videoURL.absoluteString
        avPlayer.replaceCurrentItem(with: playerItem)
        
        let button1 = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(useVideo)) // action:#selector(Class.MethodName) for swift 3
        button1.title = "Use Video"
        self.navigationItem.rightBarButtonItem  = button1
        
        if previewing {
            
        } else {
            previewLabel.isHidden = true
            let closeButton = UIButton(frame: CGRect(x: self.view.bounds.width - 34, y: 54, width: 24, height: 24))
            
            closeButton.setImage(UIImage(named: "closeIcon"), for: .normal)
            closeButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
            closeButton.tintColor = UIColor.black
            
            self.view.addSubview(closeButton)
        }
        
        avPlayer.play()
    }
    
    @objc func useVideo() {
//        saveVideo(url: videoURL)
//       view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: AddMemoryViewController.self) {
                _ =  self.navigationController!.popToViewController(controller, animated: true)
                
                break
            }
        }
    }
    
//    func saveVideo(url: URL) {
//        let filename = "testName2.mp4"
//        
//        let uploadTask = Storage.storage().reference().child("comment-videos").child(filename).putFile(from: url, metadata: nil, completion:  { (metadata, error) in
//            if error != nil {
//                print("failed video upload:", error as Any)
//                return
//            } else {
//                for controller in self.navigationController!.viewControllers as Array {
//                    if controller.isKind(of: AddMemoryViewController.self) {
//                        _ =  self.navigationController!.popToViewController(controller, animated: true)
//                        break
//                    }
//                }
//            }
//        })
//        progressLabel.isHidden = false
//        progressView.isHidden = false
//        uploadTask.observe(.progress) { (snapshot) in
//            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
//                / Double(snapshot.progress!.totalUnitCount)
//            
//            self.progressView.progress = 0.0
//            self.progress.completedUnitCount = 0
//            self.progress.completedUnitCount = Int64(Int(percentComplete))
//        self.progressView.setProgress(Float(self.progress.fractionCompleted), animated: true)
//
//        }
//    }
    
    @objc  func closeModal() {
        self.dismiss(animated: true, completion: {})
    }
}
