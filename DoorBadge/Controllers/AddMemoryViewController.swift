//
//  AddMemoryViewController.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 7/14/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore
import AVFoundation

class AddMemoryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var videoButton: UIButton!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    let eventRef = Firestore.firestore().collection("events")
    
    let currentEventId = MemoryBookEvent.activeMemoryBook?.eventId
    
    var vidThumbDone = ""
    
    let urlstring = LatestVideoURL.pathString
    
    let url = URL(string: LatestVideoURL.pathString)
    
    var memoryDictionary: [String: Any] = [
        "date": "",
        "image": "",
        "memory":"",
        "name":"",
        "video":"",
        "videoThumbnail":""
    ]
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var submitButton: LoadingButton!
    
    @IBAction func closeModal(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
    
    @IBAction func videoButtonDidPress(_ sender: UIButton) {
        sender.pulsate()
        view.endEditing(true)
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.2, execute: {
            self.performSegue(withIdentifier: "showVideoCam", sender: self)
        })
    }
    
    func scaleImage(image:UIImage, view:UIImageView, customWidth: CGFloat?) -> UIImage {
        let oldWidth = image.size.width
        let oldHeight = image.size.height
        var scaleFactor:CGFloat
        var newHeight:CGFloat
        var newWidth:CGFloat
        
        if let customWidth = customWidth {
            
            let viewWidth:CGFloat = customWidth * 3
            
            if oldWidth > oldHeight {
                scaleFactor = oldHeight/oldWidth
                newHeight = viewWidth * scaleFactor
                newWidth = viewWidth
            } else {
                scaleFactor = oldHeight/oldWidth
                newHeight = viewWidth * scaleFactor
                newWidth = viewWidth
            }
        } else {
            let viewWidth:CGFloat = view.bounds.width * 3
            
            if oldWidth > oldHeight {
                scaleFactor = oldWidth/oldHeight
                newHeight = viewWidth * scaleFactor
                newWidth = viewWidth
            } else {
                scaleFactor = oldHeight/oldWidth
                newHeight = viewWidth * scaleFactor
                newWidth = viewWidth
            }
        }
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func saveVideo(url: URL, memoryID: String) {
        let filename = memoryID
        self.videoButton.setImage(nil, for: .normal)
        let vidUploadTask = Storage.storage().reference().child("comment-videos").child(filename).putFile(from: url, metadata: nil, completion:  { (metadata, error) in
            if error != nil {
                print("failed video upload:", error as Any)
                return
            } else {

                //Reference Event Images folder in Firebase
                let vidStorageRef = self.storage.reference().child("comment-videos")
                
                //Reference & name new vid in Firebase
                let newVidRef = vidStorageRef.child(memoryID)
                        //On success, get new image download URL
                        newVidRef.downloadURL(completion: { (url, error) in
                            
                            if let error = error {
                                print(error)
                            } else {
                                //Set download image URL to variable as a String
                                let newVidURL = url?.absoluteString ?? ""
                          
                                //Add Vid URL String to Memory in Firebase
                                self.eventRef.document(self.currentEventId!).collection("comments").document(memoryID).updateData(["video" : newVidURL])
                                
                                self.memoryDictionary.updateValue(newVidURL, forKey: "video")

                                //Because this is based on date as the unique identifier, if 2 comments submitted at the same time, won't work as expected
                            }
                        })
                self.dismiss(animated: true, completion: {
                    
                })
            }
        })
   
        vidUploadTask.observe(.progress) { (snapshot) in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            
            self.videoButton.setTitle("\(percentComplete.roundToInt())%", for: .normal)
            
            if percentComplete.roundToInt() == 100 {
                DispatchQueue.main.asyncAfter(deadline:.now() + 1.0, execute: {
                    self.videoButton.setTitle("", for: .normal)
                    self.videoButton.setImage(UIImage(named: "sentIcon"), for: .normal)
                    
                    DispatchQueue.main.asyncAfter(deadline:.now() + 1.0, execute: {
                        if self.photoButton.image(for: .normal) == UIImage(named: "videoIcon") || self.photoButton.image(for: .normal) == UIImage(named: "sentIcon") {
                            self.dismiss(animated: true, completion: {
                                
                            })
                        }
                    })
                })
            }
        }
    }
    
    @IBAction func submitMemory(_ sender: Any) {
        submitButton.isEnabled = false
        submitButton.showLoading()
        let date = NSDate().timeIntervalSince1970 * 1000
        //getValues
        memoryDictionary.updateValue(round(date), forKey: "date")
        memoryDictionary.updateValue("", forKey: "image")
        memoryDictionary.updateValue(messageTextField.text, forKey: "memory")
        memoryDictionary.updateValue(nameTextField.text, forKey: "name")
        
        let newMemory: Memory!
        if let newMemory = Memory(dictionary: memoryDictionary) {
            MemoryBookEvent.comments.append(newMemory)
        }
        
        //getEvent
        var memoriesRef: DocumentReference? = nil
        memoriesRef = eventRef.document(currentEventId!).collection("comments").addDocument(data: memoryDictionary) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                
                let memoryId = memoriesRef?.documentID
                
                //Reference Facility in Firebase
                let eventRef = self.db.collection("events").document(self.currentEventId!)
                
                let commentsRef = eventRef.collection("comments").document("\(memoryId!)")

                commentsRef.getDocument { (document, error) in
                    if let thisMemory = document.flatMap({$0.data().flatMap({ (data) in return Memory(dictionary: data)})}) {
                        MemoryBookEvent.comments.append(thisMemory)
                        
                    }
                }
                if self.photoButton.image(for: .normal) != UIImage(named: "photoIcon") {
                    //CREATE IMAGE THUMB, IMAGE
                    //IMAGE THUMB
                    
                    //Get selected Image from ImageView   //Get Data from Image
                    guard let imageThumb = self.photoButton.image(for: .normal)
                        else {
                            print("Something went wrong")
                            return
                    }
                    let newImageThumb = self.scaleImage(image: imageThumb, view: self.photoButton.imageView!, customWidth: 100)
                    let newImageFull = self.scaleImage(image: imageThumb, view: self.photoButton.imageView!, customWidth: 320)
                    
                    guard let dataThumb = newImageThumb.jpegData(compressionQuality: 0.3)
                        else {
                            print("Something went wrong")
                            return
                    }
                    
                    guard let dataFull = newImageFull.jpegData(compressionQuality: 0.4)
                        else {
                            print("Something went wrong")
                            return
                    }
                    
                    //Reference Event Images folder in Firebase
                    let imageStorageRef = self.storage.reference().child("comment-images")
                    
                    //Reference & name new image in Firebase
                    let newImageThumbRef = imageStorageRef.child(memoryId!)
                    let newImageFullRef = imageStorageRef.child("\(memoryId!)-full")
                    
                    //Empty image URL
                    var newImageThumbURL = ""
                    var newImageFullURL = ""
                    self.photoButton.setImage(nil, for: .normal)
                    //Add Image data to firebase Storage
                    newImageThumbRef.putData(dataThumb).observe(.success, handler:
                        { (snapshot) in
                            
                            //On success, get new image download URL
                            newImageThumbRef.downloadURL(completion: { (url, error) in
                                if let error = error {
                                    print(error)
                                } else {
                                    
                                    //Set download image URL to variable as a String
                                    newImageThumbURL = url?.absoluteString ?? ""
                                    
                                    //Add Image URL String to Memory in Firebase
                                    self.eventRef.document(self.currentEventId!).collection("comments").document(memoryId!).updateData(["image" : newImageThumbURL])
                                    
                                    self.memoryDictionary.updateValue(newImageThumbURL, forKey: "image")
                                    
                                    //Because this is based on date as the unique identifier, if 2 comments submitted at the same time, won't work as expected
                                    MemoryBookEvent.comments = MemoryBookEvent.comments.map{
                                        var mutableMemory = $0
                                        if $0.date == Int(round(date)) {
                                            mutableMemory.image = newImageThumbURL
                                        }
                                        return mutableMemory
                                    }
                                }
                            })
                    })
                    
                    newImageFullRef.putData(dataFull).observe(.progress, handler:
                        { (snapshot) in
                            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                                / Double(snapshot.progress!.totalUnitCount)
                          
                            
                            self.photoButton.setTitle("\(percentComplete.roundToInt())%", for: .normal)
                            if percentComplete.roundToInt() == 100 {
                                DispatchQueue.main.asyncAfter(deadline:.now() + 1.0, execute: {
                                        self.photoButton.setTitle("", for: .normal)
//                                        self.photoButton.setImage(UIImage(named: "sentIcon"), for: .normal)
//                                    }
                                })
                            }
                    })
                    
                    newImageFullRef.putData(dataFull).observe(.success, handler:
                        { (snapshot) in
                          
                            DispatchQueue.main.asyncAfter(deadline:.now() + 1.5, execute: {
                                if self.photoButton.image(for: .normal) != UIImage(named: "sentIcon") {
                                    self.photoButton.setTitle("", for: .normal)
                                    self.photoButton.setImage(UIImage(named: "sentIcon"), for: .normal)
                                    DispatchQueue.main.asyncAfter(deadline:.now() + 1.0, execute: {
                                        
                                        if self.videoButton.image(for: .normal) == UIImage(named: "videoIcon") || self.videoButton.image(for: .normal) == UIImage(named: "sentIcon") {
                                            
                                            self.dismiss(animated: true, completion: {
                                                
                                            })
                                        }
                                    })
                                }
                            })
                    })
                }
                
                if self.videoButton.image(for: .normal) != UIImage(named: "videoIcon") {
                    
//                    let urlstring = LatestVideoURL.pathString
//
//                    if let url = URL(string: urlstring) {
//                        self.saveVideo(url: url, memoryID: memoryId!)

                        guard let vidThumb = self.videoButton.image(for: .normal)
                            else {
                                print("Something went wrong")
                                return
                        }
                        let newVidThumb = self.scaleImage(image: vidThumb, view: self.videoButton.imageView!, customWidth: 100)
                        
                        guard let dataVidThumb = newVidThumb.jpegData(compressionQuality: 0.3)
                            else {
                                print("Something went wrong")
                                return
                        }
                        
                        //Reference comment video thumbs Images folder in Firebase
                        let imageStorageRef = self.storage.reference().child("comment-video-thumbs")
                        
                        //Reference & name new image in Firebase
                        let newVidThumbRef = imageStorageRef.child(memoryId!)
                        
                        //Empty image URL
                        var newVidThumbURL = ""
                        
                        //Add Image data to firebase Storage
                        newVidThumbRef.putData(dataVidThumb).observe(.success, handler:
                            { (snapshot) in
                                
                                //On success, get new image download URL
                                newVidThumbRef.downloadURL(completion: { (url, error) in
                                    
                                    if let error = error {
                                        print(error)
                                    } else {

                                        //Set download image URL to variable as a String
                                        newVidThumbURL = url?.absoluteString ?? ""
                                        
                                        //Add Image URL String to Memory in Firebase
                                        self.eventRef.document(self.currentEventId!).collection("comments").document(memoryId!).updateData(["videoThumbnail" : newVidThumbURL])
                                        
                                            self.memoryDictionary.updateValue(newVidThumbURL, forKey: "videoThumbnail")
                                        
                                            MemoryBookEvent.comments = MemoryBookEvent.comments.map{
                                                var mutableMemory = $0
                                                if $0.date == Int(round(date)) {
                                                    mutableMemory.videoThumbnail = newVidThumbURL
                                                }
                                                return mutableMemory
                                            }
                                        
                                        let filename = memoryId
                                        self.videoButton.setImage(nil, for: .normal)
                                        
                                        let vidUploadTask = Storage.storage().reference().child("comment-videos").child(filename!).putFile(from: URL(string: LatestVideoURL.pathString)!, metadata: nil, completion:  { (metadata, error) in
                                            if error != nil {
                                                print("failed video upload:", error as Any)
                                                return
                                            } else {
                                                
                                                //Reference Event Images folder in Firebase
                                                let vidStorageRef = self.storage.reference().child("comment-videos")
                                                
                                                //Reference & name new vid in Firebase
                                                let newVidRef = vidStorageRef.child(memoryId!)
                                                //On success, get new image download URL
                                                newVidRef.downloadURL(completion: { (url, error) in
                                                    
                                                    if let error = error {
                                                        print(error)
                                                    } else {
                                                        
                                                        //Set download image URL to variable as a String
                                                        let newVidURL = url?.absoluteString ?? ""
                                                        
                                                        //Add Vid URL String to Memory in Firebase
                                                        self.eventRef.document(self.currentEventId!).collection("comments").document(memoryId!).updateData(["video" : newVidURL])
                                                        
                                                        self.memoryDictionary.updateValue(newVidURL, forKey: "video")
                                                        
                                                        //Because this is based on date as the unique identifier, if 2 comments submitted at the same time, won't work as expected
                                                        
                                                        MemoryBookEvent.comments = MemoryBookEvent.comments.map{
                                                            var mutableMemory = $0
                                                            if $0.date == Int(round(date)) {
                                                                mutableMemory.video = newVidURL
                                                            }
                                                            return mutableMemory
                                                        }
                                                    }
                                                })
                                                
                                                self.dismiss(animated: true, completion: {
                                                    
                                                })
                                            }
                                        })
                                        
                                        vidUploadTask.observe(.progress) { (snapshot) in
                                            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                                                / Double(snapshot.progress!.totalUnitCount)
                                         
                                            self.videoButton.setTitle("\(percentComplete.roundToInt())%", for: .normal)
                                            
                                            if percentComplete.roundToInt() == 100 {
                                                
                                                DispatchQueue.main.asyncAfter(deadline:.now() + 1.0, execute: {
                                                    
                                                    self.videoButton.setTitle("", for: .normal)
                                                    self.videoButton.setImage(UIImage(named: "sentIcon"), for: .normal)
                                                    
                                                    DispatchQueue.main.asyncAfter(deadline:.now() + 1.0, execute: {
                                                        
                                                        if (self.photoButton.image(for: .normal) == UIImage(named: "videoIcon")) || (self.photoButton.image(for: .normal) == UIImage(named: "sentIcon")) {
                                                            
                                                            self.dismiss(animated: true, completion: {
                                                                
                                                            })
                                                        }
                                                    })
                                                })
                                            }
                                        }
                                        
                                        vidUploadTask.observe(.success) { (snapshot) in
                                            DispatchQueue.main.asyncAfter(deadline:.now() + 1.5, execute: {
                                                if self.videoButton.image(for: .normal) != UIImage(named: "sentIcon") {
                                                    self.videoButton.setTitle("", for: .normal)
                                                    self.videoButton.setImage(UIImage(named: "sentIcon"), for: .normal)
                                                    DispatchQueue.main.asyncAfter(deadline:.now() + 1.0, execute: {
                                                        
                                                        if self.photoButton.image(for: .normal) == UIImage(named: "videoIcon") || self.photoButton.image(for: .normal) == UIImage(named: "sentIcon") {
                                                            
                                                            self.dismiss(animated: true, completion: {
                                                                
                                                            })
                                                        }
                                                    })
                                                }
                                            })
                                        }
                                    }
                                })
                        })
                } else if (self.videoButton.image(for: .normal) == UIImage(named: "videoIcon")) && (self.photoButton.image(for: .normal) == UIImage(named: "photoIcon"))  {

                    self.dismiss(animated: true, completion: {
                        
                    })
                }
                //////////////////////////////////////////////////////////////////////////////
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            photoButton.setImage(image, for: .normal)
            
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            //display error
            photoButton.setImage(image, for: .normal)
        }
        self.dismiss(animated: true, completion:  nil)
    }
    
    @IBAction func imagePickerDidTap(_ sender: UIButton) {
        sender.pulsate()
        view.endEditing(true)
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        image.allowsEditing = false
        
        self.present(image, animated: true)
        {
            //After is complete
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
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.isHidden = true
        if LatestVideoURL.pathString != "" {
            
            let urlstring = LatestVideoURL.pathString
            if let url = URL(string: urlstring) {
            
                videoButton.setImage(generateThumbnail(path: url), for: .normal)
            }
        }
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.tintColor = UIColor.black
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.viewTapped(gestureRecognizer:)))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddMemoryViewController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        
        if LatestVideoURL.pathString != "" {
            let urlstring = LatestVideoURL.pathString
            
            if let url = URL(string: urlstring) {
                videoButton.setImage(generateThumbnail(path: url), for: .normal)
            }
        }
    }
}

extension Double {
    func roundToInt() -> Int{
        return Int(Darwin.round(self))
    }
}
