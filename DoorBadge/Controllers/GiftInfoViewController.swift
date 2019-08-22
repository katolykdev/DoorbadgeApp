//
//  GiftInfoViewController.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 5/29/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import Firebase

class GiftInfoViewController: UIViewController, ModalTransitionListener {
    
    let db = Firestore.firestore()
    
    var indexPathRowNumber: Int = 0
    
    let defaults = UserDefaults.standard
    
    let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.isPagingEnabled = true
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 360)
        return scroll
    }()
    
    @IBOutlet var giftDescriptionLabel: UILabel!
    
    var imageArray: [String] = []

    var giftId = ""
    var eventId = ""
    var giftTitle: String = ""
    var giftDescription: String = ""
    var giftGiver: String = ""
    
    var giftMainImage = ""
    var giftSecondaryImages: [String] = []
  
    var giftFacilityId = ""
    var giftThankYouSent: Bool = false
    
    var imagesArray: [String] = []
    
    var logInType = ""
    
    var thankYouWasSent: Bool = false
    
    @IBOutlet weak var thankYouWasSentView: UIView!
    
    @IBOutlet weak var sentIcon: UIImageView!
    var primaryImageURL = ""
    
    @IBOutlet weak var subHeaderLabel: UILabel!
    
    @IBOutlet weak var giftTitleLabel: UILabel!
    @IBOutlet weak var giftGiverLabel: UILabel!
    @IBOutlet weak var sentUnsentButton: UIButton!
    
    @IBOutlet weak var thanks1: UILabel!
    @IBOutlet weak var thanks2: UIImageView!
    @IBOutlet weak var thanks3: UILabel!
    
    @IBOutlet weak var primaryImageView: UIImageView!
    
    @IBOutlet weak var scrollHostView: UIView!
    @IBAction func didTapSentUnsent(_ sender: Any) {
        
        if thankYouWasSent {
            
            thankYouWasSent = false
          
            sentUnsentButton.setTitle("Mark As Sent", for: .normal)
            thankYouWasSentView.isHidden = true
            let docRef = db.collection("events").document(eventId)
                
            let eventRef = docRef.collection("gifts").document(giftId)
            
            eventRef.updateData(["thankYouSent" : false])
            
            EventGifts.gifts[indexPathRowNumber].thankYouSent = false
            
            defaults.set("true", forKey: "thanksFirst")
        } else {
            thankYouWasSent = true
           
            sentUnsentButton.setTitle("Mark As Not Sent", for: .normal)
            thankYouWasSentView.isHidden = false
            
            let docRef = db.collection("events").document(eventId)
            
            let eventRef = docRef.collection("gifts").document(giftId)
            
            eventRef.updateData(["thankYouSent" : true])
            
            EventGifts.gifts[indexPathRowNumber].thankYouSent = true
      
            defaults.set("false", forKey: "thanksFirst")
        }
    }
    
    func setupImages(_ images: [String]){
        print("did run setupImages")
        for i in 0..<images.count {
            
            let imageView = UIImageView()

            imageView.sd_setImage(with: URL(string: imagesArray[i])) { (image, error, cache, url) in
                
            }

            let xPosition = UIScreen.main.bounds.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            imageView.contentMode = .scaleAspectFit
            
            scrollView.contentSize.width = scrollView.frame.width * CGFloat(i + 1)
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 10.0
            scrollView.addSubview(imageView)
            scrollView.delegate = self as? UIScrollViewDelegate
        }
    }
    
//    func setupImages(_ images: [String]){
//        print("did run setupImages")
//        for i in 0..<images.count {
//
//            let imageView = UIImageView()
//            //Reference Event Images folder in Firebase
//            let imageStorageRef = Storage.storage().reference().child("gift-images").child("events").child("\(eventId)").child("gifts")
//            var newImageThumbRef: StorageReference?
//            //Reference & name new image in Firebase
//
//            newImageThumbRef = imageStorageRef.child("\(images[i])")
//            if let thumbnail = UIImage(named: "photoIcon") {
//                imageView.sd_setImageWithReferenceWithFade(reference: newImageThumbRef!, placeholder: thumbnail)
//            }
//
//            print("\(images[i])")
//
//            let xPosition = UIScreen.main.bounds.width * CGFloat(i)
//            imageView.frame = CGRect(x: xPosition, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
//            imageView.contentMode = .scaleAspectFit
//
//            scrollView.contentSize.width = scrollView.frame.width * CGFloat(i + 1)
//            scrollView.minimumZoomScale = 1.0
//            scrollView.maximumZoomScale = 10.0
//            scrollView.addSubview(imageView)
//            scrollView.delegate = self as? UIScrollViewDelegate
//
//        }
//
//    }
    
    func popoverDismissed() {
        self.navigationController?.dismiss(animated: true, completion: nil)
        
        if let index = EventGifts.gifts.index(where: {$0.giftId == giftId}) {
            let gift = EventGifts.gifts[index]
            
            print(gift)
            
            self.giftTitleLabel.text = gift.title
           
            self.giftDescriptionLabel.text = gift.description
            if gift.giver != "" {
                self.giftGiverLabel.text = "From: \(gift.giver)"
            }
            self.giftMainImage = gift.mainImage
            self.giftSecondaryImages = gift.secondaryImages
            self.eventId = gift.eventId
            self.giftFacilityId = gift.facilityId
            self.giftThankYouSent = gift.thankYouSent
            self.giftId = gift.giftId
            
            
            SDImageCache.shared.removeImageFromDisk(forKey: self.giftId)
            SDImageCache.shared.removeImageFromMemory(forKey: self.giftId)
            
            SDImageCache.shared.removeImageFromDisk(forKey: "\(self.giftId)-2")
            SDImageCache.shared.removeImageFromMemory(forKey: "\(self.giftId)-2")
            
            SDImageCache.shared.removeImageFromDisk(forKey: "\(self.giftId)-3")
            SDImageCache.shared.removeImageFromMemory(forKey: "\(self.giftId)-3")
            
            self.imagesArray = []
            
            if gift.mainImage != "" {
                
                self.imagesArray.append("\(gift.mainImage)")
                
                if self.giftSecondaryImages.count == 0 {
                    
                    for image in self.imagesArray {
                        print("from count 0 : \(image)")
                    }
                    
                    self.setupImages(self.imagesArray)
                    
                } else if self.giftSecondaryImages.count == 1 {
                    
                    self.imagesArray.append("\(gift.secondaryImages[0])")
                    
                    for image in self.imagesArray {
                        print("from count 1 : \(image)")
                    }
                    self.setupImages(self.imagesArray)
                    
                } else if self.giftSecondaryImages.count == 2 {
                    
                    self.imagesArray.append("\(gift.secondaryImages[0])")
                    self.imagesArray.append("\(gift.secondaryImages[1])")
                    
                    for image in self.imagesArray {
                        print("from count 2 : \(image)")
                    }
                    self.setupImages(self.imagesArray)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ModalTransitionMediator.instance.setListener(listener: self)
        if defaults.string(forKey: "logInType") == "family" {
            
        } else {
            sentUnsentButton.isHidden = true
            thankYouWasSentView.isHidden = true
            thanks1.isHidden = true
            thanks2.isHidden = true
            thanks3.isHidden = true
            
            let button1 = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(editGifttModal))
            button1.title = "Edit Gift"
            self.navigationItem.rightBarButtonItem  = button1
        }
            let giftRef = Firestore.firestore().collection("events").document(eventId).collection("gifts").document(giftId)
            
            giftRef.getDocument { (document, error) in
                if let gift = document.flatMap({
                    $0.data().flatMap({ (data) in
                        return Gift(dictionary: data)
                    })
                }) {
                    
                    self.giftTitle = gift.title
                    
                    self.giftDescription = gift.description
                    self.giftGiver = gift.giver
                    self.giftMainImage = gift.mainImage
                    self.giftSecondaryImages = gift.secondaryImages
                    self.eventId = gift.eventId
                    self.giftFacilityId = gift.facilityId
                    self.giftThankYouSent = gift.thankYouSent
                    self.giftId = document!.documentID
                    
                    SDImageCache.shared.removeImageFromDisk(forKey: self.giftId)
                    SDImageCache.shared.removeImageFromMemory(forKey: self.giftId)
                    
                    SDImageCache.shared.removeImageFromDisk(forKey: "\(self.giftId)-2")
                    SDImageCache.shared.removeImageFromMemory(forKey: "\(self.giftId)-2")
                    
                    SDImageCache.shared.removeImageFromDisk(forKey: "\(self.giftId)-3")
                    SDImageCache.shared.removeImageFromMemory(forKey: "\(self.giftId)-3")
                    
                    self.imagesArray = []
                    
                    if gift.mainImage != "" {
                        
                        self.imagesArray.append("\(gift.mainImage)")
                        
                        if self.giftSecondaryImages.count == 0 {
                            
                            for image in self.imagesArray {
                                print("from count 0 : \(image)")
                            }
                            
                            self.setupImages(self.imagesArray)
                            
                        } else if self.giftSecondaryImages.count == 1 {
                            
                            self.imagesArray.append("\(gift.secondaryImages[0])")
                            
                            for image in self.imagesArray {
                                print("from count 1 : \(image)")
                            }
                            self.setupImages(self.imagesArray)
                            
                        } else if self.giftSecondaryImages.count == 2 {
                            
                            self.imagesArray.append("\(gift.secondaryImages[0])")
                            self.imagesArray.append("\(gift.secondaryImages[1])")
                            
                            for image in self.imagesArray {
                                print("from count 2 : \(image)")
                            }
                            self.setupImages(self.imagesArray)
                            
                        }
                    }

//                    //Reference Event Images folder in Firebase
//                    let imageStorageRef = Storage.storage().reference().child("gift-images").child("events").child("\(self.eventId)").child("gifts")
//
//                    //Reference & name new image in Firebase
//                    let newImageThumbRef = imageStorageRef.child("\(self.giftId)")
                    
                }
            }
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        
//        let eventRef = db.collection("events").document(eventId).collection("gifts").document("\(giftId)")
       
        subHeaderLabel.text = "Gift Information"
        subHeaderLabel.addCharacterSpacing(kernValue: 1.15)
        
        giftTitleLabel.text = giftTitle
        giftTitleLabel.addCharacterSpacing(kernValue: 1.10)
        giftGiverLabel.text = giftGiver
        giftGiverLabel.addCharacterSpacing(kernValue: 1.10)
        giftDescriptionLabel.text = giftDescription
        giftDescriptionLabel.addCharacterSpacing(kernValue: 1.10)
        
        sentUnsentButton.layer.cornerRadius = 5
        
        if thankYouWasSent {
            sentUnsentButton.setTitle("Mark As Not Sent", for: .normal)
            thankYouWasSentView.isHidden = false
        } else {
            sentUnsentButton.setTitle("Mark As Sent", for: .normal)
            thankYouWasSentView.isHidden = true
        }
        
        scrollHostView.addSubview(scrollView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
            if let index = EventGifts.gifts.index(where: {$0.giftId == giftId}) {
                let gift = EventGifts.gifts[index]
                
                print(gift)

                SDImageCache.shared.removeImageFromDisk(forKey: self.giftId)
                SDImageCache.shared.removeImageFromMemory(forKey: self.giftId)
                
                SDImageCache.shared.removeImageFromDisk(forKey: "\(self.giftId)-2")
                SDImageCache.shared.removeImageFromMemory(forKey: "\(self.giftId)-2")
                
                SDImageCache.shared.removeImageFromDisk(forKey: "\(self.giftId)-3")
                SDImageCache.shared.removeImageFromMemory(forKey: "\(self.giftId)-3")
                
                self.imagesArray = []
                
                if gift.mainImage != "" {
                    
                    self.imagesArray.append("\(gift.mainImage)")
                    
                    if self.giftSecondaryImages.count == 0 {
                        
                        for image in self.imagesArray {
                            print("from count 0 : \(image)")
                        }
                        
                        self.setupImages(self.imagesArray)
                        
                    } else if self.giftSecondaryImages.count == 1 {
                        
                        self.imagesArray.append("\(gift.secondaryImages[0])")
                        
                        for image in self.imagesArray {
                            print("from count 1 : \(image)")
                        }
                        self.setupImages(self.imagesArray)
                        
                    } else if self.giftSecondaryImages.count == 2 {
                        
                        self.imagesArray.append("\(gift.secondaryImages[0])")
                        self.imagesArray.append("\(gift.secondaryImages[1])")
                        
                        for image in self.imagesArray {
                            print("from count 2 : \(image)")
                        }
                        self.setupImages(self.imagesArray)
                    }
                }
            }
    }
    
    @objc func editGifttModal(sender: UIButton!) {
        performSegue(withIdentifier: "editGiftModal", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "editGiftModal" {
            
            if let editGiftVC = segue.destination as? DoorBadgeAddGiftViewController {
                
                editGiftVC.editingGift = true
                editGiftVC.giftTitle = giftTitle
                editGiftVC.giftDescription = giftDescription
                editGiftVC.giftGiver = giftGiver
                editGiftVC.giftMainImage = giftMainImage
                editGiftVC.giftSecondaryImages = giftSecondaryImages
                editGiftVC.giftEventId = eventId
                editGiftVC.giftFacilityId = giftFacilityId
                editGiftVC.giftThankYouSent = giftThankYouSent
                editGiftVC.giftGiftID = giftId
                
                let nextPageBack = "Gift"
                let backItem = UIBarButtonItem()
                backItem.title = nextPageBack
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
}
