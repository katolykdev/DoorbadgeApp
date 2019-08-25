//
//  MemoryBookViewController.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 7/9/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import AVFoundation

class MemoryBookViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var event: Event!
    let defaults = UserDefaults.standard
    var comments: [Memory] = []
    var buttonRow = 0
    @IBOutlet weak var memoryBookTableView: UITableView!
    func getMemories(){
        let eventRef = Firestore.firestore().collection("events").document("\(event.eventId)")
            
        let commentsRef = eventRef.collection("comments")
        
        commentsRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    let comment = Memory(dictionary: document.data())
                    
//                    self.comments.append(comment!)
                    MemoryBookEvent.comments.append(comment!)
                    MemoryBookEvent.comments.sort(by: {
                        
                            return $1.date < $0.date
                    })
                 
                    self.memoryBookTableView.reloadData()
                }
            }
        }
    }
    
    let blackBackground = UIView()
    let zoomImageView = UIImageView()
    let videoPlayer = VideoPlayback()
    var statusImageView: UIButton?
    var player = AVPlayer()
    var playerLayer = AVPlayerLayer()
    let topView = UIView()
    
    func animateImageView(statusImageView: UIButton, media: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
        self.statusImageView = statusImageView
        
        if let startingFrame = statusImageView.superview?.convert(statusImageView.frame, to: nil) {
        
            if media == "photo" {
            
                statusImageView.alpha = 0
                
                self.blackBackground.frame = self.view.frame
                self.blackBackground.backgroundColor = UIColor.black
                self.blackBackground.alpha = 0
                self.view.addSubview(self.blackBackground)
                
                self.zoomImageView.backgroundColor = UIColor.black
                self.zoomImageView.frame = startingFrame
                self.zoomImageView.isUserInteractionEnabled = true
                self.zoomImageView.contentMode = .scaleAspectFit
                
                if MemoryBookEvent.comments[self.buttonRow].image != "" {
                    if let fullImageURL = MemoryBookEvent.comments[self.buttonRow].image?.replacingOccurrences(of: "?", with: "-full?") {
                        self.zoomImageView.sd_setImage(with: URL(string: fullImageURL))
                    }
                }
                
                self.view.addSubview(self.zoomImageView)
                 self.zoomImageView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(self.zoomOut)))
                
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.zoomOut))
                self.zoomImageView.addGestureRecognizer(tapRecognizer)
                
                UIView.animate(withDuration: 0.25) {
                    
                    let height = (self.view.frame.width / startingFrame.width) * startingFrame.height
                    
                    let y = self.view.frame.height / 2 - height / 2
                    
                    self.zoomImageView.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height)
                    
                    self.blackBackground.alpha = 1
                }
            } else {
                self.blackBackground.frame = startingFrame
                self.blackBackground.backgroundColor = UIColor.black
                self.blackBackground.alpha = 0
                self.view.addSubview(self.blackBackground)
                
                self.player = AVPlayer(url: URL(string: MemoryBookEvent.comments[self.buttonRow].video!)!)
                self.playerLayer = AVPlayerLayer(player: self.player)
                let height = (self.view.frame.width / startingFrame.width) * startingFrame.height
                
                let y = self.view.frame.height / 2 - height / 2
                self.playerLayer.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height)
                self.view.layer.addSublayer(self.playerLayer)
                self.player.play()
                
                
                self.topView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.topView.backgroundColor = UIColor.clear
                self.topView.isUserInteractionEnabled = true
                self.view.addSubview(self.topView)

                UIView.animate(withDuration: 0.25) {
                    let height = (self.view.frame.width / startingFrame.width) * startingFrame.height

                    let y = self.view.frame.height / 2 - height / 2

                    self.blackBackground.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)

                    self.blackBackground.alpha = 1
                    
                    self.topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                    self.view.bringSubviewToFront(self.topView)
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.closeVideo))
                    self.topView.addGestureRecognizer(tapGesture)
                }
            }
        }
        })
    }
    
    @objc func zoomOut() {
        if let startingFrame = statusImageView!.superview?.convert(statusImageView!.frame, to: nil) {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.zoomImageView.frame = startingFrame
                self.blackBackground.alpha = 0
                }, completion: { (didComplete) -> Void in
                    self.zoomImageView.removeFromSuperview()
                    self.blackBackground.removeFromSuperview()
                    
                    self.statusImageView?.alpha = 1
            })
        }
    }
    
    @objc func closeVideo() {
        if let startingFrame = statusImageView!.superview?.convert(statusImageView!.frame, to: nil) {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.blackBackground.frame = startingFrame
                self.topView.frame = startingFrame
                self.blackBackground.alpha = 0
                self.playerLayer.frame = startingFrame
            }, completion: { (didComplete) -> Void in
                self.playerLayer.removeFromSuperlayer()
                self.blackBackground.removeFromSuperview()
                self.topView.removeFromSuperview()
                self.player.replaceCurrentItem(with: nil)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MemoryBookEvent.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "memoryBookCommentCell", for: indexPath) as? memoryBookCommentCell else {
            fatalError("Not a Teaser Cell")
        }
        
        let memory: Memory = MemoryBookEvent.comments[indexPath.row]
        cell.memoryBookController = self
        
        if memory.date != nil {
            
            let dateNumber = Double(memory.date) / 1000
            
            let date = NSDate(timeIntervalSince1970: dateNumber)
            
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .medium
            
            let myString = formatter.string(from: date as Date)
            
            cell.memoryDate.text = myString
        }
        
        cell.memoryName.text = memory.name
        cell.memoryText.text = memory.memory
        cell.memoryPhotoButton.tag = indexPath.row
        cell.memoryPhotoButton.addTarget(self, action: #selector(buttonClicked), for: UIControl.Event.touchUpInside)
        cell.memoryVideoButton.tag = indexPath.row
        cell.memoryVideoButton.addTarget(self, action: #selector(buttonClicked), for: UIControl.Event.touchUpInside)
        if let imageDownloadURL = memory.image {
        
            if imageDownloadURL != "" {
                cell.memoryPhotoButton.isHidden = false
                cell.memoryPhotoLabel.isHidden = false
                
                cell.memoryPhotoButton.sd_setBackgroundImage(with: URL(string:
                    imageDownloadURL), for:
                    UIControl.State.normal, placeholderImage: UIImage(named:
                        "default_profile"), options: SDWebImageOptions(rawValue: 0)) { (image,
                            error, cache, url) in
                            
                }
                
                cell.yourobj = {
                    
                }
            } else {
                cell.memoryPhotoButton.isHidden = true
                cell.memoryPhotoLabel.isHidden = true
                cell.stackview.removeArrangedSubview(cell.photoStackView)
                cell.stackview.addArrangedSubview(cell.photoStackView)
            }
        }
        if let videoDownloadURL = memory.videoThumbnail {
            if videoDownloadURL != "" {
          
                cell.memoryVideoButton.isHidden = false
                cell.memoryVideoLabel.isHidden = false
                cell.memoryVideoButton.sd_setBackgroundImage(with: URL(string:
                    videoDownloadURL), for:
                    UIControl.State.normal, placeholderImage: UIImage(named:
                        "default_profile"), options: SDWebImageOptions(rawValue: 0)) { (image,
                            error, cache, url) in
                }
                
                cell.yourobj = {
                    
                }
            } else {
                cell.memoryVideoButton.isHidden = true
                cell.memoryVideoLabel.isHidden = true
            }
        }

        if (memory.image == "") && (memory.videoThumbnail == "")   {
                cell.memoryBookStackViewHeight.constant = 0
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 536
    }
    
    @objc func buttonClicked(sender:UIButton) {
        buttonRow = sender.tag
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 240
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as? memoryBookHeaderCell else {
            fatalError("Not a Header Cell")
        }

        if let event = MemoryBookEvent.activeMemoryBook {

            cell.memoryBookName.text = "\(event.eventFirstName) \(event.eventLastName)"
            cell.memoryBookDates.text = "\(event.dateOfBirth) - \(event.dateOfDeath)"

            let imageDownloadURL = event.image

            if imageDownloadURL != "" {
                cell.memoryBookImageView.sd_setImage(with: URL(string: event.image))
            } else {
                cell.memoryBookImageView.image = nil
            }
        }

        // This is where you would change section header content
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVideoFromThumbnail" {
            if let vidVC = segue.destination as? VideoPlayback {
            
                vidVC.videoURL = URL(string: MemoryBookEvent.comments[buttonRow].video ?? "")
                vidVC.previewing = false
            }
        }
    }
    
    override func viewDidLoad() {
        MemoryBookEvent.comments = []

        memoryBookTableView.register(UINib(nibName: "memoryBookHeaderCell", bundle: nil), forCellReuseIdentifier: "headerCell")
        memoryBookTableView.register(UINib(nibName: "memoryBookCommentCell", bundle: nil), forCellReuseIdentifier: "memoryBookCommentCell")
        
        let button1 = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(popMemoryModal)) // action:#selector(Class.MethodName) for swift 3
        button1.title = "Share Memory"
        self.navigationItem.rightBarButtonItem  = button1
        button1.tintColor = UIColor.black
        
        memoryBookTableView.rowHeight = UITableView.automaticDimension
        memoryBookTableView.estimatedRowHeight = 44
        
        event = MemoryBookEvent.activeMemoryBook
        getMemories()
    }
    
    @objc func popMemoryModal(sender: UIButton!)  {
        defaults.set("popped", forKey: "didPopModal")
        performSegue(withIdentifier: "showAddMemoryView", sender:
            self)
        if MemoryBookEvent.comments.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                self.memoryBookTableView.scrollToTop()
            }
        }
    }
    
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.memoryBookTableView.reloadData()
        
//        if defaults.string(forKey: "didPopModal") == "popped" {
        
            MemoryBookEvent.comments.sort(by: {
                
                return $1.date < $0.date
            })
        
//            self.memoryBookTableView.scrollToTop()
        
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                // your code here
//
//                let index = IndexPath(row: MemoryBookEvent.comments.count - 1, section: 0)
//                self.memoryBookTableView.scrollToRow(at: index, at: .bottom, animated: true)
//
//            }
//            self.defaults.set("unpopped", forKey: "didPopModal")
//        } else {
//
//
//        }
        
        
//        if MemoryBookEvent.comments.count > 1 {
//            memoryBookTableView.scrollToTop()
//        }
    }
}

extension UITableView {
    func scrollToTop() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}
//extension UIViewController : UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        if touch.view!.superview!.superclass! .isSubclass(of: UIButton.self) {
//            return false
//        }
//        return true
//    }
//}
