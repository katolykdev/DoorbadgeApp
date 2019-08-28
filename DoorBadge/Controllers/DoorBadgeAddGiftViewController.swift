//
//  DoorBadgeAddGiftViewController.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 5/22/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore
import SDWebImage

class DoorBadgeAddGiftViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate
{
    var editingGift: Bool = false
    var gift: Gift!
    var secondaryImages: [String] = []
    var currentEventId = ""
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    @IBOutlet var scrollView: UIScrollView!
    var existingGift: Gift!
    
    var imageButtonTapped: Int = 0
   
     var logInType = LoggedIn.accountType
    
    @IBOutlet var addGiftHeadingLabel: UILabel!
    
    let currentUser = Auth.auth().currentUser
    
    let eventRef = Firestore.firestore().collection("events")
    
    var count = 0
    
    var imageViews: [UIImageView] = []
    
    var pickedImageView = ""
    
    var finalMainImage = ""
    
    var finalSecondary: [String] = []
    
    var mainImageExists = true
    var secondaryImagesExistCount = 0
    
    @IBOutlet weak var giftTitleTextField: UITextField!
    
    @IBOutlet weak var giftDescriptionTextField: UITextField!
    
    @IBOutlet weak var giftGiverTextField: UITextField!
    
    @IBOutlet var submitButton: LoadingButton!
    
    var giftTitle = ""
    var giftDescription = ""
    var giftGiver = ""
    var giftMainImage = ""
    var giftSecondaryImages: [String] = []
    var giftEventId = ""
    var giftFacilityId = ""
    var giftThankYouSent: Bool = false
    var giftGiftID = ""
    
    var giftDictionary: [String: Any] = [
        "title": "",
        "description": "",
        "giver":"",
        "mainImage":"",
        "secondaryImages": [],
        "eventId": "",
        "facilityId": "",
        "thankYouSent": false,
        "giftId": ""
    ]
    
    @IBAction func addEventModalCloseDidTap() {
        self.dismiss(animated: true, completion: {})
    }
    
    @IBOutlet var imageButton1: UIButton!
    @IBOutlet var imageButton2: UIButton!
    @IBOutlet var imageButton3: UIButton!
    
   func takePhoto(_ sender: UIImageView) {
//        if count < imageViews.count {
//            //present UiimagePicker
//            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
        
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
               
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
//            }
//        } else {
//            // alert no more pictures allowed
//
//        }
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
                scaleFactor = oldWidth/oldHeight
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            switch imageButtonTapped {
            case 1:
                self.imageButton1.setImage(pickedImage, for: .normal)
            case 2:
                self.imageButton2.setImage(pickedImage, for: .normal)
            case 3:
                self.imageButton3.setImage(pickedImage, for: .normal)
            default:
                break
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadImageDidTap(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        image.allowsEditing = false
        
        self.present(image, animated: true)
        {
            //After is complete
        }
    }
    
    override func viewDidLoad() {
//        let eventRef = db.collection("events")
//        var giftsRef = eventRef.document(currentEventId).collection("gifts")
        
        print("\(currentEventId)")
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.tintColor = UIColor.black
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.viewTapped(gestureRecognizer:)))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        gift = Gift(dictionary: giftDictionary)
        
        // Gift Title
        
        giftTitleTextField.leftViewMode = .always
        giftTitleTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        giftTitleTextField.delegate = self
        giftTitleTextField.tag = 1
        giftTitleTextField.setBottomBorder()
        
        // Gift Description
        
        giftDescriptionTextField.leftViewMode = .always
        giftDescriptionTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        giftDescriptionTextField.delegate = self
        giftDescriptionTextField.tag = 2
        giftDescriptionTextField.setBottomBorder()
        
        // Gift Giver
        
        giftGiverTextField.leftViewMode = .always
        giftGiverTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        giftGiverTextField.delegate = self
        giftGiverTextField.tag = 3
        giftGiverTextField.setBottomBorder()
        
//        imageViews = [showImageView, showImageView2, showImageView3]
        
        if editingGift {
            addGiftHeadingLabel.text = "EDIT GIFT"
            giftTitleTextField.text = giftTitle
            
            giftDescriptionTextField.text = giftDescription
            giftGiverTextField.text = giftGiver
            
            if giftMainImage != "" {
                
                self.imageButton1!.sd_setImage(with: URL(string: giftMainImage), for: .normal) { (image, err, cache, url) in
                }
            }
            print(giftSecondaryImages.count)
            
            if giftSecondaryImages.count == 0 {
                
            } else if giftSecondaryImages.count == 1 {
                self.imageButton2!.sd_setImage(with: URL(string: giftSecondaryImages[0]), for: .normal) { (image, err, cache, url) in
                }
            } else if giftSecondaryImages.count == 2 {
                for url in giftSecondaryImages {
                    print("url:\(url)")
                }
                self.imageButton2!.sd_setImage(with: URL(string: giftSecondaryImages[0]), for: .normal) { (image, err, cache, url) in
                }
                self.imageButton3!.sd_setImage(with: URL(string: giftSecondaryImages[1]), for: .normal) { (image, err, cache, url) in
                }
            }
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DoorBadgeAddGiftViewController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            registerNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
            unregisterNotifications()
//        ModalTransitionMediator.instance.sendPopoverDismissed(modelChanged: true)
        
        if presentedViewController is UIImagePickerController {
            
        } else {
            ModalTransitionMediator.instance.sendPopoverDismissed(modelChanged: true)
        }
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        scrollView.contentInset.bottom = 0
    }
    
    @objc private func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }
    
    @objc private func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset.bottom = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
            SDImageCache.shared.removeImageFromDisk(forKey: self.giftGiftID)
            SDImageCache.shared.removeImageFromMemory(forKey: self.giftGiftID)
      
            SDImageCache.shared.removeImageFromDisk(forKey: "\(self.giftGiftID)-2")
            SDImageCache.shared.removeImageFromMemory(forKey: "\(self.giftGiftID)-2")

            SDImageCache.shared.removeImageFromDisk(forKey: "\(self.giftGiftID)-3")
            SDImageCache.shared.removeImageFromMemory(forKey: "\(self.giftGiftID)-3")
    }
    @IBAction func imageOneDidTap(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
        imageButtonTapped = 1
    }
    
    @IBAction func imageTwoDidTap(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
        imageButtonTapped = 2
    }
    
    @IBAction func imageThreeDidTap(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
        imageButtonTapped = 3
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @IBAction func submitGift(_ sender: UIButton) {
        print("pressed submit")
        submitButton.isEnabled = false
        submitButton.showLoading()
        if let currentUser = Auth.auth().currentUser {
            print("is authorized")
            giftDictionary.updateValue(currentUser.uid, forKey: "facilityId")
            giftDictionary.updateValue(currentEventId, forKey: "eventId")
            
            giftDictionary.updateValue(giftTitleTextField.text ?? "", forKey: "title")
            giftDictionary.updateValue(giftDescriptionTextField.text ?? "", forKey: "description")
            giftDictionary.updateValue(giftGiverTextField.text ?? "", forKey: "giver")
            
            var giftsRef: DocumentReference? = nil
            
            if editingGift == true {
              db.collection("events").document("\(giftEventId)").collection("gifts").document("\(giftGiftID)").setData([
                    
                    "title": giftTitleTextField.text ?? "",
                    "description": giftDescriptionTextField.text ?? "",
                    "giver": giftGiverTextField.text ?? ""

                    ], merge: true) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                        }
                }

                ///////////////////////////////////////////////////
                /////////////////MAIN IMAGE////////////////////////
                /////////////////////////////////////////////////////
               
                    //Write New Image
                    //Get selected Image from ImageView   //Get Data from Image
                    guard let imageThumb = self.imageButton1.currentImage
                        else {
                            print("Something went wrong")
                            return
                    }
                    let newImageThumb = self.scaleImage(image: imageThumb, view: self.imageButton1.imageView!, customWidth: 343.0)
                    guard let dataThumb = newImageThumb.jpegData(compressionQuality: 0.4)
                        else {
                            print("Something went wrong")
                            return
                    }

                    //Reference Event Images folder in Firebase
                    let imageStorageRef = Storage.storage().reference().child("gift-images").child("events").child(self.giftEventId).child("gifts")
                    
                    //Reference & name new image in Firebase
                    let newImageThumbRef = imageStorageRef.child(giftGiftID)
                
                    newImageThumbRef.delete { (error) in
                        if error != nil {
                        } else {
                            //Empty image URL
                            var newImageThumbURL = ""
                            
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
                                            self.finalMainImage = newImageThumbURL
                                            self.db.collection("events").document("\(self.giftEventId)").collection("gifts").document("\(self.giftGiftID)").updateData(["mainImage" : newImageThumbURL])
                                            
                                            SDImageCache.shared.removeImageFromDisk(forKey: self.giftGiftID)
                                            SDImageCache.shared.removeImageFromMemory(forKey: self.giftGiftID)
                                            
                                            /////////////////////////////////////////////////////////
                                            //////////// IMAGE 2 ////////////////////////////////////
                                            ////////////////////////////////////////////////////////
                                            
                                            guard let image2Thumb = self.imageButton2.currentImage
                                                else {
                                                    print("Something went wrong")
                                                    return
                                            }
                                            
                                            let newImage2Thumb = self.scaleImage(image: image2Thumb, view: self.imageButton2.imageView!, customWidth: 343.0)
                                            
                                            guard let data2Thumb = newImage2Thumb.jpegData(compressionQuality: 0.4)
                                                else {
                                                    print("Something went wrong")
                                                    return
                                            }
                                            
                                            //Reference Event Images folder in Firebase
                                            let imageStorageRef = Storage.storage().reference().child("gift-images").child("events").child(self.giftEventId).child("gifts")
                                            
                                            //Reference & name new image in Firebase
                                            let newImage2ThumbRef = imageStorageRef.child("\(self.giftGiftID)-2")
                                            
                                            //Empty image URL
                                            var newImage2ThumbURL = ""
                                            
                                            newImage2ThumbRef.delete { (error) in
                                                if error != nil {
                                                } else {
                                            
                                                    //Add Image data to firebase Storage
                                                    newImage2ThumbRef.putData(data2Thumb).observe(.success, handler:
                                                        { (snapshot) in
                                                            
                                                            //On success, get new image download URL
                                                            newImage2ThumbRef.downloadURL(completion: { (url, error) in
                                                                
                                                                if let error = error {
                                                                    print(error)
                                                                } else {
                                                                    
                                                                    //Set download image URL to variable as a String
                                                                    newImage2ThumbURL = url?.absoluteString ?? ""
                                                                    self.finalSecondary.append(newImage2ThumbURL)
                                                                    
                                                                    //                                    self.db.collection("events").document("\(self.giftEventId)").collection("gifts").document("\(self.giftGiftID)").updateData(["secondaryImages" : FieldValue. newImage2ThumbURL])
                                                                    
                                                                    SDImageCache.shared.removeImageFromDisk(forKey: "\(self.giftGiftID)-2")
                                                                    SDImageCache.shared.removeImageFromMemory(forKey: "\(self.giftGiftID)-2")
                                                                    
                                                                    /////////////////////////////////////////////////////////
                                                                    //////////// IMAGE 3 ////////////////////////////////////
                                                                    ////////////////////////////////////////////////////////
                                                                    
                                                                    guard let image3Thumb = self.imageButton3.currentImage
                                                                        else {
                                                                            print("Something went wrong")
                                                                            return
                                                                    }
                                                                    
                                                                    let newImage3Thumb = self.scaleImage(image: image3Thumb, view: self.imageButton3.imageView!, customWidth: 343.0)
                                                                    
                                                                    guard let data3Thumb = newImage3Thumb.jpegData(compressionQuality: 0.4)
                                                                        else {
                                                                            print("Something went wrong")
                                                                            return
                                                                    }
                                                                    
                                                                    //Reference Event Images folder in Firebase
                                                                    let imageStorageRef = Storage.storage().reference().child("gift-images").child("events").child(self.giftEventId).child("gifts")
                                                                    
                                                                    //Reference & name new image in Firebase
                                                                    let newImage3ThumbRef = imageStorageRef.child("\(self.giftGiftID)-3")
                                                                    
                                                                    //Empty image URL
                                                                    var newImage3ThumbURL = ""
                                                                    
                                                                    newImage3ThumbRef.delete { (error) in
                                                                        if error != nil {
                                                                        } else {
                                                                    
                                                                            //Add Image data to firebase Storage
                                                                            newImage3ThumbRef.putData(data3Thumb).observe(.success, handler:
                                                                                { (snapshot) in
                                                                                    
                                                                                    //On success, get new image download URL
                                                                                    newImage3ThumbRef.downloadURL(completion: { (url, error) in
                                                                                        
                                                                                        if let error = error {
                                                                                            print(error)
                                                                                        } else {
                                                                                            
                                                                                            //Set download image URL to variable as a String
                                                                                            newImage3ThumbURL = url?.absoluteString ?? ""
                                                                                            self.finalSecondary.append(newImage3ThumbURL)
                                                                                            self.db.collection("events").document("\(self.giftEventId)").collection("gifts").document("\(self.giftGiftID)").updateData(["secondaryImages" : self.finalSecondary])
                                                                                          
                                                                                            SDImageCache.shared.removeImageFromDisk(forKey: "\(self.giftGiftID)-3")
                                                                                            SDImageCache.shared.removeImageFromMemory(forKey: "\(self.giftGiftID)-3")
                                                                                     
                                                                                            let newLocalGift = Gift(
                                                                                                title: self.giftTitleTextField.text ?? "",
                                                                                                description: self.giftDescriptionTextField.text ?? "",
                                                                                                giver: self.giftGiverTextField.text ?? "",
                                                                                                eventId: self.giftEventId,
                                                                                                facilityId: self.giftFacilityId,
                                                                                                thankYouSent: self.giftThankYouSent,
                                                                                                mainImage: self.finalMainImage,
                                                                                                secondaryImages: self.finalSecondary,
                                                                                                giftId: self.giftGiftID
                                                                                            )
                                                                                            
                                                                                            if let index = EventGifts.gifts.index(where: {$0.giftId  == newLocalGift.giftId}) {
                                                                                                EventGifts.gifts[index] = newLocalGift
                                                                                            }
                                                                                            
                                                                                            print("success")
                                                                                            self.dismiss(animated: true, completion: {
                                                                                                
                                                                                            })
                                                                                            
                                                                                        }
                                                                                    })
                                                                            })
                                                                }
                                                                    }
                                                                }
                                                            })
                                                    })
                                                }
                                            }
                                        }
                                    })
                            })
                        }
                }
            } else {  //Adding a new gift
                print("have doc, bout to submit")
               
                giftsRef = eventRef.document("\(self.currentEventId)").collection("gifts").addDocument(data: giftDictionary) { err in
                
                    if let err = err {
                        
                        print("Error adding document: \(err)")
                        
                    } else {
                        print("no error yet")
                        //Get Gift ID from Firebase
                        let giftId = giftsRef!.documentID
                        print(giftId)
                        self.giftDictionary.updateValue(giftId, forKey: "giftId")
                      
    //                    let giftRef = self.eventRef.document(giftId)
                        //Add Event ID to Event in Firebase
                        giftsRef?.updateData(["giftId" : giftId])
                        
                        //Get selected Image from ImageView   //Get Data from Image
                        guard let imageThumb = self.imageButton1.currentImage
                            else {
                                print("Something went wrong")
                                return
                        }

                        let newImageThumb = self.scaleImage(image: imageThumb, view: self.imageButton1.imageView!, customWidth: 343.0)

                        guard let dataThumb = newImageThumb.jpegData(compressionQuality: 0.4)
                            else {
                                print("Something went wrong")
                                return
                        }

                        //Reference Event Images folder in Firebase
                        let imageStorageRef = Storage.storage().reference().child("gift-images").child("events").child(self.currentEventId).child("gifts")

                        //Reference & name new image in Firebase
                        let newImageThumbRef = imageStorageRef.child(giftId)
                    
                        //Empty image URL
                        var newImageThumbURL = ""

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

                                        giftsRef?.updateData(["mainImage" : "\(newImageThumbURL)"])

                                        self.giftDictionary.updateValue(newImageThumbURL, forKey: "mainImage")

                                        //Get selected Image from ImageView   //Get Data from Image
                                        guard let imageThumb = self.imageButton2.currentImage
                                            else {
                                                print("Something went wrong")
                                                return
                                        }
                                        
                                        let newImageThumb = self.scaleImage(image: imageThumb, view: self.imageButton2.imageView!, customWidth: 343.0)
                                       
                                        
                                        guard let dataThumb = newImageThumb.jpegData(compressionQuality: 0.4)
                                            else {
                                                print("Something went wrong")
                                                return
                                        }
                                        
                                        //Reference Event Images folder in Firebase
                                        let imageStorageRef = Storage.storage().reference().child("gift-images").child("events").child(self.currentEventId).child("gifts")
                                        
                                        //Reference & name new image in Firebase
                                        let newImageThumbRef = imageStorageRef.child("\(giftId)-2")
                                       
                                        //Empty image URL
                                        var newImageThumbURL = ""
                              
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
                                                        
                                                        self.finalSecondary.append(newImageThumbURL)
                                                        
                                                        //Get selected Image from ImageView   //Get Data from Image
                                                        guard let imageThumb = self.imageButton3.currentImage
                                                            else {
                                                                print("Something went wrong")
                                                                return
                                                        }
                                                        
                                                        let newImageThumb = self.scaleImage(image: imageThumb, view: self.imageButton3.imageView!, customWidth: 343.0)
                                                        
                                                        guard let dataThumb = newImageThumb.jpegData(compressionQuality: 0.4)
                                                            else {
                                                                print("Something went wrong")
                                                                return
                                                        }
                                                       
                                                        //Reference Event Images folder in Firebase
                                                        let imageStorageRef = Storage.storage().reference().child("gift-images").child("events").child(self.currentEventId).child("gifts")
                                                        
                                                        //Reference & name new image in Firebase
                                                        let newImageThumbRef = imageStorageRef.child("\(giftId)-3")
                                                        
                                                        //Empty image URL
                                                        var newImageThumbURL = ""
                                                        //                        var newImageFullURL = ""
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
                                                                        self.secondaryImages.append(newImageThumbURL)
                                                                        giftsRef?.updateData(["secondaryImages" : self.secondaryImages])
                                                                        
                                                                        self.giftDictionary.updateValue(self.secondaryImages, forKey: "secondaryImages")

                                                                            giftsRef!.getDocument { (document, error) in
                                                                                if let gift = document.flatMap({$0.data().flatMap({ (data) in return Gift(dictionary: data)})}) {
                                                                                    EventGifts.gifts.append(gift)
                                                                                    self.dismiss(animated: true, completion: {
                                                                                        
                                                                                    })
                                                                                }
                                                                            }
                                                                        
                                                                            print("success")
                                                                        
                                                                            if let presenter = self.presentingViewController as? EventInfoViewController {
                                                                                presenter.submittedGift = true
                                                                            }
                                                                    }
                                                                })
                                                    })
                                                }
                                                })
                                        })
                                    }
                                })
                        })
                    }
                }
            }
        }
    }
}
