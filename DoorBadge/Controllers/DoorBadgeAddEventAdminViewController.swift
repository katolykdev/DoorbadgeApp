//
//  DoorBadgeAddEventAdminViewController.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 4/28/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//


import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore
import SDWebImage


class DoorBadgeAddEventAdminViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var editingEvent: Bool = false
    var event: Event!
    
    var finalAge = ""
    var userExists = false
    var existingEvent: Event!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    let currentUser = Auth.auth().currentUser
    
    let eventRef = Firestore.firestore().collection("events")
    
    let modesOfContact = ["Phone", "Email"]
    
    var eventDictionary: [String : Any] = [
        "facilityId": "",
        "eventId": "",
        "eventCode":"",
        "primaryUserId": "",
        
        "primaryUserEmail": "",
        
        "type": "",
        
        "title" : "",
        "description" : "",
        "date": "99999999",
        "location": "",
        "eventFirstName": "",
        "eventLastName": "",
        "dateOfBirth": "",
        "dateOfDeath":"",
        "age": "",
        "image": "",
        
        "familyFirstName": "",
        "familyLastName": "",
        "familyAddress": "",
        "familyZip": "",
        "familyPhone": "",
        "familyModeOfContact": "",
        
        "isOpen": true
    ]
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var submitEvent: LoadingButton!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cameraRollButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var eventDetailsView: UIView!
    
    @IBOutlet weak var eventDetailsHeight: NSLayoutConstraint!
    
    @IBOutlet weak var primaryEmailTextField: UITextField!
    
    @IBOutlet weak var eventTitleTextField: UITextField!
    
    @IBOutlet weak var eventDescriptionTextField: UITextField!
    
    @IBOutlet weak var eventDateTextField: UITextField!
    
    @IBOutlet weak var eventLocationTextField: UITextField!
    
    @IBOutlet weak var eventFirstName: UITextField!
    
    @IBOutlet weak var eventLastName: UITextField!
    @IBOutlet weak var eventDateOfBirth: UITextField!
    @IBOutlet weak var eventDateOfDeath: UITextField!
    @IBOutlet weak var eventAge: UITextField!
    @IBOutlet weak var dateInputField: UITextField!
    
    @IBOutlet weak var familyDetailsView: UIView!
    
    @IBOutlet weak var familyDetailsHeight: NSLayoutConstraint!
    
    @IBOutlet weak var familyDetailsLastName: UITextField!
    @IBOutlet weak var familyDetailsFirstName: UITextField!
    @IBOutlet weak var familyDetailsAddress: UITextField!
    @IBOutlet weak var familyDetailsZipCode: UITextField!
    @IBOutlet weak var familyDetailsPhoneNumber: UITextField!
    @IBOutlet weak var familyDetailsContactMode: UITextField!
    
    @IBOutlet weak var imageComponentContainer: UIView!
    
    @IBOutlet weak var uploadedImageView: UIImageView!
    
    @IBOutlet var eventHeadingLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            registerNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
            unregisterNotifications()
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
                newHeight = viewWidth
                newWidth = viewWidth * scaleFactor
            } else {
                scaleFactor = oldHeight/oldWidth
                newHeight = viewWidth * scaleFactor
                newWidth = viewWidth
            }
        } else {
            let viewWidth:CGFloat = view.bounds.width * 3
            
            if oldWidth > oldHeight {
                scaleFactor = oldWidth/oldHeight
                newHeight = viewWidth
                newWidth = viewWidth * scaleFactor
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
    
    @IBAction func submitEvent(_ sender: Any) {
        submitEvent.showLoading()
        
        if let currentUser = Auth.auth().currentUser {
            eventDictionary.updateValue(currentUser.uid, forKey: "facilityId")
            eventDictionary.updateValue(primaryEmailTextField.text ?? "", forKey: "primaryUserEmail")

            eventDictionary.updateValue(eventTitleTextField.text ?? "", forKey: "title")
            eventDictionary.updateValue(eventDescriptionTextField.text ?? "", forKey: "description")
            if eventDateTextField.text == "" {
                eventDictionary.updateValue("99999999", forKey: "date")
            } else {
                eventDictionary.updateValue(eventDateTextField.text ?? "", forKey: "date")
            }

            eventDictionary.updateValue(eventLocationTextField.text ??  "", forKey: "location")
            eventDictionary.updateValue(eventFirstName.text ?? "", forKey: "eventFirstName")
            eventDictionary.updateValue(eventLastName.text ?? "", forKey: "eventLastName")
            eventDictionary.updateValue(eventDateOfBirth.text ?? "", forKey: "dateOfBirth")
            eventDictionary.updateValue(eventDateOfDeath.text ?? "", forKey: "dateOfDeath")
            eventDictionary.updateValue("0", forKey: "age")
            
            eventDictionary.updateValue(familyDetailsFirstName.text ?? "", forKey: "familyFirstName")
            eventDictionary.updateValue(familyDetailsLastName.text ?? "", forKey: "familyLastName")
            eventDictionary.updateValue(familyDetailsAddress.text ?? "", forKey: "familyAddress")
            eventDictionary.updateValue(familyDetailsZipCode.text ?? "", forKey: "familyZip")
            eventDictionary.updateValue(familyDetailsPhoneNumber.text ?? "", forKey: "familyPhone")
            eventDictionary.updateValue(familyDetailsContactMode.text ?? "", forKey: "familyModeOfContact")

            var ref: DocumentReference? = nil
            
            if isEditing == true {
                db.collection("events").document(existingEvent!.eventId).setData([
                    "date": eventDateTextField.text ?? "",
                    "dateOfBirth": eventDateOfBirth.text ?? "",
                    "dateOfDeath": eventDateOfDeath.text ?? "",
                    "description": eventDescriptionTextField.text ?? "",
                    "eventFirstName": eventFirstName.text ?? "",
                    "eventLastName": eventLastName.text ?? "",
                    "familyAddress": familyDetailsAddress.text ?? "",
                    "familyFirstName": familyDetailsFirstName.text ?? "",
                    "familyLastName": familyDetailsLastName.text ?? "",
                    "familyModeOfContact": familyDetailsContactMode.text ?? "",
                    "familyZip": familyDetailsZipCode.text ?? "",
                    "familyPhone": familyDetailsPhoneNumber.text ?? "",
                    "location": eventLocationTextField.text ??  "",
                    "title": eventTitleTextField.text ?? "",
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                      
                    }
                }
                
                //If new image selected on Edit
                if self.uploadedImageView.image != UIImage(named: "photoIcon") {
                    
                    //If image did NOT exist before
                    if existingEvent.image == "" {
                       print("no current image")
                        //Get selected Image from ImageView   //Get Data from Image
                        guard let imageThumb = self.uploadedImageView.image, let imageFull = self.uploadedImageView.image
                            else {
                                print("Something went wrong")
                                return
                        }
                        
                        let newImageThumb = self.scaleImage(image: imageThumb, view: self.uploadedImageView, customWidth: nil)
                        let newImageFull = self.scaleImage(image: imageFull, view: self.uploadedImageView, customWidth: 320.0)
                        
                        guard let dataThumb = newImageThumb.jpegData(compressionQuality: 0.3)
                            else {
                                print("Something went wrong")
                                return
                        }
                        
                        guard let dataFull = newImageFull.jpegData(compressionQuality: 0.5)
                            else {
                                print("Something went wrong")
                                return
                        }
                        
                        //Reference Event Images folder in Firebase
                        let imageStorageRef = Storage.storage().reference().child("event-images")
                        
                        //Reference & name new image in Firebase
                        let newImageThumbRef = imageStorageRef.child(existingEvent.eventId)
                        let newImageFullRef = imageStorageRef.child("\(existingEvent.eventId)-full")
                        
                        //Empty image URL
                        var newImageThumbURL = ""
                        var newImageFullURL = ""
                        
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
                                        
                                        //Add Image URL String to Event in Firebase
                                        self.db.collection("events").document(self.existingEvent!.eventId).updateData(["image" : newImageThumbURL])
                                        
                                        FacilityEvents.currentEvents = FacilityEvents.currentEvents.map{
                                            var mutableEvent = $0
                                            if $0.eventId == self.existingEvent.eventId {
                                                mutableEvent.image = newImageThumbURL
                                           
                                            }
                                            return mutableEvent
                                        }
                                        
                                        //Dismiss Add Event Modal
//                                        self.dismiss(animated: true, completion: {
//                                            print("edited and dismissed")
//                                        })
                                    }
                                })
                                print("success")
                        })
                        newImageFullRef.putData(dataFull).observe(.success, handler:
                            { (snapshot) in
                                
                                //On success, get new image download URL
                                newImageFullRef.downloadURL(completion: { (url, error) in
                                    if let error = error {
                                        print(error)
                                    } else {
                                        //Set download image URL to variable as a String
                                        newImageFullURL = url?.absoluteString ?? ""
                                        
                                        //Add Image URL String to Event in Firebase
                                        self.db.collection("events").document(self.existingEvent!.eventId).updateData(["image" : newImageFullURL])
                                        
                                        
                                        FacilityEvents.currentEvents = FacilityEvents.currentEvents.map{
                                            var mutableEvent = $0
                                            if $0.eventId == self.existingEvent.eventId {
                                                mutableEvent.image = newImageFullURL
                                            }
                                            return mutableEvent
                                        }
                                        
                                        print("no image - image added - edited and dismissed")
                                        let newLocalEvent = Event(
                                            age: self.existingEvent.age,
                                            date: self.eventDateTextField.text ?? "",
                                            dateOfBirth: self.eventDateOfBirth.text ?? "",
                                            dateOfDeath: self.eventDateOfDeath.text ?? "",
                                            eventFirstName: self.eventFirstName.text ?? "",
                                            eventLastName: self.eventLastName.text ?? "",
                                            description: self.eventDescriptionTextField.text ?? "",
                                            eventId: self.existingEvent.eventId,
                                            eventCode: self.existingEvent.eventCode,
                                            facilityId: self.existingEvent.facilityId,
                                            familyAddress: self.familyDetailsAddress.text ?? "",
                                            familyFirstName: self.familyDetailsFirstName.text ?? "",
                                            familyLastName: self.familyDetailsLastName.text ?? "",
                                            familyModeOfContact: self.familyDetailsContactMode.text ?? "",
                                            familyPhone: self.familyDetailsPhoneNumber.text ?? "",
                                            familyZip: self.familyDetailsZipCode.text ?? "",
                                            image: newImageFullURL,
                                            location: self.eventLocationTextField.text ??  "",
                                            primaryUserEmail: self.existingEvent.primaryUserEmail,
                                            primaryUserId: self.existingEvent.primaryUserId,
                                            title: self.eventTitleTextField.text ?? "",
                                            type: self.existingEvent.type,
                                            isOpen: self.existingEvent.isOpen
                                        )
                                        
                                        print("first:\(newLocalEvent)")
                                        
                                        if self.existingEvent.isOpen {
                                            if let index = FacilityEvents.currentEvents.index(where: {$0.eventCode == newLocalEvent.eventCode}) {
                                                FacilityEvents.currentEvents[index] = newLocalEvent
                                                print("image existed - image added - edited and dismissed")
                                                
                                                self.dismiss(animated: true, completion: {
                                                    print(FacilityEvents.currentEvents[index].eventFirstName)
                                                })
                                            }
                                        } else {
                                            if let index = FacilityEvents.pastEvents.index(where: {$0.eventCode == newLocalEvent.eventCode}) {
                                                FacilityEvents.pastEvents[index] = newLocalEvent
                                                print("image existed - image added - edited and dismissed")
                                                print(FacilityEvents.pastEvents[index].eventFirstName)
                                                
                                                self.dismiss(animated: true, completion: {
                                                    print(FacilityEvents.currentEvents[index].eventFirstName)
                                                })
                                            }
                                        }
                                        print("success full")
                                    }
                                })
                                print("success")
                        })
                    } else {
                        //image already existed
                            print("image existed")
                        SDImageCache.shared.removeImageFromDisk(forKey: existingEvent.image)
                        SDImageCache.shared.removeImageFromMemory(forKey: existingEvent.image)
                      
                        //remove old images
                        let storageRef = self.storage.reference()
                        let thumbRef = storageRef.child("event-images").child(existingEvent.eventId)
                        let fullRef = storageRef.child("event-images").child("\(existingEvent.eventId)-full")
                    
                        thumbRef.delete { (error) in
                            if error != nil {
                                
                            } else {
                                print("thumb removed")
                            }
                        }
                    
                        fullRef.delete { (error) in
                            if error != nil {
                                
                            } else {
                                print("full removed")
                                //Get selected Image from ImageView   //Get Data from Image
                                guard let imageThumb = self.uploadedImageView.image, let imageFull = self.uploadedImageView.image
                                    else {
                                        print("Something went wrong")
                                        return
                                }
                                
                                let newImageThumb = self.scaleImage(image: imageThumb, view: self.uploadedImageView, customWidth: nil)
                                let newImageFull = self.scaleImage(image: imageFull, view: self.uploadedImageView, customWidth: 320.0)
                                
                                guard let dataThumb = newImageThumb.jpegData(compressionQuality: 0.3)
                                    else {
                                        print("Something went wrong")
                                        return
                                }
                                
                                guard let dataFull = newImageFull.jpegData(compressionQuality: 0.5)
                                    else {
                                        print("Something went wrong")
                                        return
                                }
                                
                                //Reference Event Images folder in Firebase
                                let imageStorageRef = Storage.storage().reference().child("event-images")
                                
                                //Reference & name new image in Firebase
                                let newImageThumbRef = imageStorageRef.child(self.existingEvent.eventId)
                                let newImageFullRef = imageStorageRef.child("\(self.existingEvent.eventId)-full")
                                
                                //Add Image data to firebase Storage
                                newImageThumbRef.putData(dataThumb).observe(.success, handler:
                                    { (snapshot) in
                                        print("success thumb")
                                })
                                newImageFullRef.putData(dataFull).observe(.success, handler:
                                    { (snapshot) in
                                        let newLocalEvent = Event(
                                            age: self.existingEvent.age,
                                            date: self.eventDateTextField.text ?? "",
                                            dateOfBirth: self.eventDateOfBirth.text ?? "",
                                            dateOfDeath: self.eventDateOfDeath.text ?? "",
                                            eventFirstName: self.eventFirstName.text ?? "",
                                            eventLastName: self.eventLastName.text ?? "",
                                            description: self.eventDescriptionTextField.text ?? "",
                                            eventId: self.existingEvent.eventId,
                                            eventCode: self.existingEvent.eventCode,
                                            facilityId: self.existingEvent.facilityId,
                                            familyAddress: self.familyDetailsAddress.text ?? "",
                                            familyFirstName: self.familyDetailsFirstName.text ?? "",
                                            familyLastName: self.familyDetailsLastName.text ?? "",
                                            familyModeOfContact: self.familyDetailsContactMode.text ?? "",
                                            familyPhone: self.familyDetailsPhoneNumber.text ?? "",
                                            familyZip: self.familyDetailsZipCode.text ?? "",
                                            image: self.existingEvent.image,
                                            location: self.eventLocationTextField.text ??  "",
                                            primaryUserEmail: self.existingEvent.primaryUserEmail,
                                            primaryUserId: self.existingEvent.primaryUserId,
                                            title: self.eventTitleTextField.text ?? "",
                                            type: self.existingEvent.type,
                                            isOpen: self.existingEvent.isOpen
                                        )
                                        
                                        print("first:\(newLocalEvent)")
                                        
                                        if self.existingEvent.isOpen {
                                            if let index = FacilityEvents.currentEvents.index(where: {$0.eventCode == newLocalEvent.eventCode}) {
                                                FacilityEvents.currentEvents[index] = newLocalEvent
                                                print("image existed - image added - edited and dismissed")
                                                
                                                self.dismiss(animated: true, completion: {
                                                    print(FacilityEvents.currentEvents[index].eventFirstName)
                                                })
                                            }
                                        } else {
                                            if let index = FacilityEvents.pastEvents.index(where: {$0.eventCode == newLocalEvent.eventCode}) {
                                                FacilityEvents.pastEvents[index] = newLocalEvent
                                                print("image existed - image added - edited and dismissed")
                                                print(FacilityEvents.pastEvents[index].eventFirstName)
                                                
                                                self.dismiss(animated: true, completion: {
                                                    print(FacilityEvents.currentEvents[index].eventFirstName)
                                                })
                                            }
                                        }
                                        print("success full")
                                })
                            }
                        }
                    } //End of image already existed or not
                } else { //End of if new image is selected
                    let newLocalEvent = Event(
                        age: self.existingEvent.age,
                        date: self.eventDateTextField.text ?? "",
                        dateOfBirth: self.eventDateOfBirth.text ?? "",
                        dateOfDeath: self.eventDateOfDeath.text ?? "",
                        eventFirstName: self.eventFirstName.text ?? "",
                        eventLastName: self.eventLastName.text ?? "",
                        description: self.eventDescriptionTextField.text ?? "",
                        eventId: self.existingEvent.eventId,
                        eventCode: self.existingEvent.eventCode,
                        facilityId: self.existingEvent.facilityId,
                        familyAddress: self.familyDetailsAddress.text ?? "",
                        familyFirstName: self.familyDetailsFirstName.text ?? "",
                        familyLastName: self.familyDetailsLastName.text ?? "",
                        familyModeOfContact: self.familyDetailsContactMode.text ?? "",
                        familyPhone: self.familyDetailsPhoneNumber.text ?? "",
                        familyZip: self.familyDetailsZipCode.text ?? "",
                        image: self.existingEvent.image,
                        location: self.eventLocationTextField.text ??  "",
                        primaryUserEmail: self.existingEvent.primaryUserEmail,
                        primaryUserId: self.existingEvent.primaryUserId,
                        title: self.eventTitleTextField.text ?? "",
                        type: self.existingEvent.type,
                        isOpen: self.existingEvent.isOpen
                    )
                    
                    print("first:\(newLocalEvent)")
                    
                    if self.existingEvent.isOpen {
                        if let index = FacilityEvents.currentEvents.index(where: {$0.eventCode == newLocalEvent.eventCode}) {
                            FacilityEvents.currentEvents[index] = newLocalEvent
                            print("image existed - image added - edited and dismissed")
                            
                            self.dismiss(animated: true, completion: {
                                
                                print(FacilityEvents.currentEvents[index].eventFirstName)
                                
                            })
                        }
                    } else {
                        if let index = FacilityEvents.pastEvents.index(where: {$0.eventCode == newLocalEvent.eventCode}) {
                            FacilityEvents.pastEvents[index] = newLocalEvent
                            print("image existed - image added - edited and dismissed")
                            print(FacilityEvents.pastEvents[index].eventFirstName)
                            
                            self.dismiss(animated: true, completion: {
                                print(FacilityEvents.currentEvents[index].eventFirstName)
                            })
                        }
                    }
                    print("success full")
                }
            } else { //Is not editing, is creating
                ref = db.collection("events").addDocument(data: eventDictionary) { err in
                    
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        //CREATE EVENT
                        
                        //Get Event ID from Firebase
                        let eventId = ref!.documentID

                        //Reference Facility in Firebase
                        let facilityRef = self.db.collection("facilities").document(currentUser.uid)
                        //Add Event ID to Event in Firebase
                        facilityRef.updateData(["events" : FieldValue.arrayUnion([eventId])])
                        //Reference Event in Firebase
                        let eventRef = self.db.collection("events").document(eventId)
                        //Add Event ID to Event in Firebase
                        eventRef.updateData(["eventId" : eventId])
                        
    //                    //Add Event ID to local Event Dictionary
    //                    self.eventDictionary.updateValue(eventId, forKey: "eventId")
                        
                        //Create Event Code
                        let eventCode = eventId.prefix(6)
                        let finalEventCode = eventCode.uppercased()
                        
                        //Add Event Code to Event in Firebase
                        eventRef.updateData(["eventCode" : finalEventCode])
                        
    //                    //Add Event Code to local Event Dictionary
    //                    self.eventDictionary.updateValue(eventCode, forKey: "eventCode")
                        
                        eventRef.getDocument { (document, error) in
                            if let event = document.flatMap({$0.data().flatMap({ (data) in return Event(dictionary: data)})}) {
                                FacilityEvents.currentEvents.append(event)
                            }

                        //If image is not default Icon
                        if self.uploadedImageView.image != UIImage(named: "photoIcon") {

                            //Get selected Image from ImageView   //Get Data from Image
                            guard let imageThumb = self.uploadedImageView.image, let imageFull = self.uploadedImageView.image
                                else {
                                    print("Something went wrong")
                                    return
                            }
                            
                            let newImageThumb = self.scaleImage(image: imageThumb, view: self.uploadedImageView, customWidth: nil)
                            let newImageFull = self.scaleImage(image: imageFull, view: self.uploadedImageView, customWidth: 190.0)
                            
                            guard let dataThumb = newImageThumb.jpegData(compressionQuality: 0.3)
                                else {
                                    print("Something went wrong")
                                    return
                            }
                            
                            guard let dataFull = newImageFull.jpegData(compressionQuality: 0.5)
                                else {
                                    print("Something went wrong")
                                    return
                            }

                            //Reference Event Images folder in Firebase
                            let imageStorageRef = Storage.storage().reference().child("event-images")

                            //Reference & name new image in Firebase
                            let newImageThumbRef = imageStorageRef.child(eventId)
                            let newImageFullRef = imageStorageRef.child("\(eventId)-full")

                            //Empty image URL
                            var newImageThumbURL = ""
                            var newImageFullURL = ""

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

                                            //Add Image URL String to Event in Firebase
                                            eventRef.updateData(["image" : newImageThumbURL])
                                            
                                            FacilityEvents.currentEvents = FacilityEvents.currentEvents.map{
                                                var mutableEvent = $0
                                                if $0.eventId == eventId {
                                                    mutableEvent.image = newImageThumbURL
                                                }
                                                return mutableEvent
                                            }
                                            
                                            //Dismiss Add Event Modal
                                            self.dismiss(animated: true, completion: {

                                            })
                                        }
                                    })
                                    print("success")
                            })
                            newImageFullRef.putData(dataFull).observe(.success, handler:
                                { (snapshot) in
                                    
                                    //On success, get new image download URL
                                    newImageFullRef.downloadURL(completion: { (url, error) in
                                        if let error = error {
                                            print(error)
                                        } else {
                                            //Set download image URL to variable as a String
                                            newImageFullURL = url?.absoluteString ?? ""
     
                                            //Add Image URL String to Event in Firebase
                                            eventRef.updateData(["image" : newImageFullURL])
      
                                            FacilityEvents.currentEvents = FacilityEvents.currentEvents.map{
                                                var mutableEvent = $0
                                                if $0.eventId == eventId {
                                                    mutableEvent.image = newImageFullURL
                                                }
                                                return mutableEvent
                                            }
                                            
                                            //Dismiss Add Event Modal
    //                                        self.dismiss(animated: true, completion: {
    //
    //                                        })
                                        }
                                    })
                                    print("success")
                            })
                        } else {
                            //Dismiss Add Event Modal
                            self.dismiss(animated: true, completion: {
                                
                            })
                        }

                        /////////////////////////
                        // CREATE PRIMARY USER //
                        /////////////////////////
                        
                        //Set Username and Temporary password
                        let primaryEmail = self.primaryEmailTextField.text!
                            
                        let userRef = self.db.collection("users").whereField("email", isEqualTo: primaryEmail)
                            userRef.getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    if querySnapshot!.documents.count == 0 {
                                        let password = "tempPassword"
                                        
                                        //Create second app
                                        if let secondaryApp = FirebaseApp.app(name: "CreatingUsersApp") {
                                            let secondaryAppAuth = Auth.auth(app: secondaryApp)
                                            
                                            //////////////////////////////////
                                            // CREATE USER IN SECONDARY APP //
                                            //////////////////////////////////
                                            
                                            secondaryAppAuth.createUser(withEmail: primaryEmail, password: password) { (user, error) in
                                                if error != nil {
                                                    print(error!)
                                                } else {
                                                    ///////////////////////////////////////////
                                                    // ADD NEW USER TO EVENT AS PRIMARY USER //
                                                    ///////////////////////////////////////////
                                                    
                                                    if let primaryId = secondaryAppAuth.currentUser?.uid {
                                                        
                                                        //Add Primary User ID to Event in Firebase
                                                        self.db.collection("events").document(eventId).updateData(["primaryUserId" : primaryId])
                                                        
                                                        //Add Primary User ID to Event locally
                                                        self.eventDictionary.updateValue(primaryId, forKey: "primaryUserId")
                                                        
                                                        //Add Primary Email and Event ID to User in Firebase
                                                        self.db.collection("users").document(primaryId).setData([
                                                            "email": primaryEmail,
                                                            "events": [ eventId ]
                                                            ])
                                                        
                                                        Auth.auth().sendPasswordReset(withEmail: primaryEmail, completion: { (error) in
                                                            //Make sure you execute the following code on the main queue
                                                            DispatchQueue.main.async {
                                                                //Use "if let" to access the error, if it is non-nil
                                                                if let error = error {
                                                                    
                                                                } else {
                                                                    try! secondaryAppAuth.signOut()
                                                                }
                                                            }
                                                        })
                                                        ///////////////////////
                                                        // SIGN OUT NEW USER //
                                                        ///////////////////////
                                                        //                                try! secondaryAppAuth.signOut()
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        addEventToUser: for document in querySnapshot!.documents {
                                            
                                            //Add Primary User ID to Event in Firebase
                                            self.db.collection("events").document(eventId).updateData(["primaryUserId" : document.documentID])
                                            
                                            //Add Primary User ID to Event locally
                                            self.eventDictionary.updateValue(document.documentID, forKey: "primaryUserId")
                                            
                                            //Add Primary Email and Event ID to User in Firebase
                                            self.db.collection("users").document(document.documentID).updateData(["events" : FieldValue.arrayUnion([eventId])])
                                            break  addEventToUser
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
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
    
    @IBAction func fromWebsiteDidTap(_ sender: Any) {
        performSegue(withIdentifier: "toWebView", sender: Any?.self)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            uploadedImageView.image = image
            uploadedImageView.contentMode = .scaleAspectFit
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //display error
            uploadedImageView.image = image
            uploadedImageView.contentMode = .scaleAspectFit
        }
        self.dismiss(animated: true, completion:  nil)
    }
    
    private var datePicker: UIDatePicker?
    private var dateBirthPicker: UIDatePicker?
    private var dateDeathPicker: UIDatePicker?
    private var modeOfContactPicker: UIPickerView?
    
    var birthDay: Date!
    var deathDay: Date!
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload")
        if isEditing == false {
        
            event = Event(dictionary: eventDictionary)
            eventHeadingLabel.text = "ADD EVENT"
        } else {
            eventHeadingLabel.text = "EDIT EVENT"
            primaryEmailTextField.text = existingEvent.primaryUserEmail
            primaryEmailTextField.isUserInteractionEnabled = false
            primaryEmailTextField.textColor = UIColor.lightGray
            
            eventTitleTextField.text = existingEvent.title
            eventDescriptionTextField.text = existingEvent.description
            eventDateTextField.text = existingEvent.date
            eventLocationTextField.text = existingEvent.location
            eventFirstName.text = existingEvent.eventFirstName
            eventLastName.text = existingEvent.eventLastName
            eventDateOfBirth.text = existingEvent.dateOfBirth
            eventDateOfDeath.text = existingEvent.dateOfDeath
            familyDetailsFirstName.text = existingEvent.familyFirstName
            familyDetailsLastName.text = existingEvent.familyLastName
            familyDetailsAddress.text = existingEvent.familyAddress
            familyDetailsZipCode.text = existingEvent.familyZip
            familyDetailsPhoneNumber.text = existingEvent.familyPhone
            familyDetailsContactMode.text = existingEvent.familyModeOfContact
        }
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.tintColor = UIColor.black
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.viewTapped(gestureRecognizer:)))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(DoorBadgeAddEventAdminViewController.dateChanged(datePicker:)), for: .valueChanged)
        dateInputField.inputView = datePicker
        
        dateBirthPicker = UIDatePicker()
        dateBirthPicker?.datePickerMode = .date
        dateBirthPicker?.addTarget(self, action: #selector(DoorBadgeAddEventAdminViewController.dateBirthChanged(datePicker:)), for: .valueChanged)
        eventDateOfBirth.inputView = dateBirthPicker
        
        dateDeathPicker = UIDatePicker()
        dateDeathPicker?.datePickerMode = .date
        dateDeathPicker?.addTarget(self, action: #selector(DoorBadgeAddEventAdminViewController.dateDeathChanged(datePicker:)), for: .valueChanged)
        eventDateOfDeath.inputView = dateDeathPicker
        
        modeOfContactPicker = UIPickerView()
        
        modeOfContactPicker?.delegate = self
        modeOfContactPicker?.dataSource = self
        familyDetailsContactMode.inputView = modeOfContactPicker
        
        ////////////////////////
        // REQUIRED/////////////
        ////////////////////////
        
        //Primary Email Address
        
        primaryEmailTextField.leftViewMode = .always
        primaryEmailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        primaryEmailTextField.delegate = self
        primaryEmailTextField.tag = 0
        primaryEmailTextField.setBottomBorder()
        primaryEmailTextField.inputAccessoryView = toolBar
        
        ///////////////////////
        // EVENT FIELDS////////
        ///////////////////////
        
        // Event Title
        
        eventTitleTextField.leftViewMode = .always
        eventTitleTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        eventTitleTextField.delegate = self
        eventTitleTextField.tag = 1
        eventTitleTextField.setBottomBorder()
        eventTitleTextField.inputAccessoryView = toolBar
        
        // Event Description
        
        eventDescriptionTextField.leftViewMode = .always
        eventDescriptionTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        eventDescriptionTextField.delegate = self
        eventDescriptionTextField.tag = 2
        eventDescriptionTextField.setBottomBorder()
        eventDescriptionTextField.inputAccessoryView = toolBar
        
        // Event Date
        
        eventDateTextField.leftViewMode = .always
        eventDateTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        eventDateTextField.delegate = self
        eventDateTextField.tag = 3
        eventDateTextField.setBottomBorder()
        
        let pickerToolBar = UIToolbar().ToolbarPicker(mySelect: #selector(self.dismissPicker))
        
        eventDateTextField.inputAccessoryView = pickerToolBar
        
        // Event Location
        
        eventLocationTextField.leftViewMode = .always
        eventLocationTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        eventLocationTextField.delegate = self
        eventLocationTextField.tag = 4
        eventLocationTextField.setBottomBorder()
        eventLocationTextField.inputAccessoryView = toolBar
        
        // Name of Deceased
        
        eventFirstName.leftViewMode = .always
        eventFirstName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        eventFirstName.delegate = self
        eventFirstName.tag = 5
        eventFirstName.setBottomBorder()
        eventLastName.inputAccessoryView = toolBar
        
        eventLastName.leftViewMode = .always
        eventLastName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        eventLastName.delegate = self
        eventLastName.tag = 5
        eventLastName.setBottomBorder()
        eventLastName.inputAccessoryView = toolBar
        
        // Date of Birth
        
        eventDateOfBirth.leftViewMode = .always
        eventDateOfBirth.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        eventDateOfBirth.delegate = self
        eventDateOfBirth.tag = 6
        eventDateOfBirth.setBottomBorder()

        eventDateOfBirth.inputAccessoryView = pickerToolBar
        
        // Date of Death
        
        eventDateOfDeath.leftViewMode = .always
        eventDateOfDeath.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        eventDateOfDeath.delegate = self
        eventDateOfDeath.tag = 7
        eventDateOfDeath.setBottomBorder()

        eventDateOfDeath.inputAccessoryView = pickerToolBar

        ///////////////////////
        // FAMILY FIELDS//////
        //////////////////////

        // Family First Name
        
        familyDetailsFirstName.leftViewMode = .always
        familyDetailsFirstName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        familyDetailsFirstName.delegate = self
        familyDetailsFirstName.tag = 8
        familyDetailsFirstName.setBottomBorder()
        familyDetailsFirstName.inputAccessoryView = toolBar
        
        // Family Last Name
        
        familyDetailsLastName.leftViewMode = .always
        familyDetailsLastName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        familyDetailsLastName.delegate = self
        familyDetailsLastName.tag = 9
        familyDetailsLastName.setBottomBorder()
        familyDetailsLastName.inputAccessoryView = toolBar
        
        // Family Address
        
        familyDetailsAddress.leftViewMode = .always
        familyDetailsAddress.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        familyDetailsAddress.delegate = self
        familyDetailsAddress.tag = 10
        familyDetailsAddress.setBottomBorder()
        familyDetailsLastName.inputAccessoryView = toolBar
        
        // Family Zip

        familyDetailsZipCode.leftViewMode = .always
        familyDetailsZipCode.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        familyDetailsZipCode.delegate = self
        familyDetailsZipCode.tag = 11
        familyDetailsZipCode.setBottomBorder()
        familyDetailsZipCode.inputAccessoryView = toolBar
        
        //Family Phone
        
        familyDetailsPhoneNumber.leftViewMode = .always
        familyDetailsPhoneNumber.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        familyDetailsPhoneNumber.delegate = self
        familyDetailsPhoneNumber.tag = 12
        familyDetailsPhoneNumber.setBottomBorder()
        familyDetailsPhoneNumber.inputAccessoryView = toolBar
        
        //Family Contact Mode
        
        familyDetailsContactMode.leftViewMode = .always
        familyDetailsContactMode.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        familyDetailsContactMode.delegate = self
        familyDetailsContactMode.tag = 13
        familyDetailsContactMode.setBottomBorder()
        familyDetailsContactMode.inputAccessoryView = pickerToolBar
        pickerToolBar.tintColor = UIColor.black

        eventDetailsHeight.constant = 30
        familyDetailsHeight.constant = 30
 
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DoorBadgeAddEventAdminViewController.viewTapped(gestureRecognizer:)))

        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateInputField.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func dateBirthChanged(datePicker: UIDatePicker) {
        dateFormatter.dateFormat = "MM/dd/yyyy"
        eventDateOfBirth.text = dateFormatter.string(from: datePicker.date)
        birthDay = datePicker.date
        
        if let deathday = deathDay {
            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: birthDay, to: deathday)
            let age = ageComponents.year!
            eventAge.text = String(age)
            if age >= 0 {
                finalAge = String(age)
            } else {
                let alert = UIAlertController(title: "Check Your Dates", message: "Date of Birth must be before Date of Death", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                 finalAge = "dna"
            }
        }
    }
    
    @objc func dateDeathChanged(datePicker: UIDatePicker) {
        dateFormatter.dateFormat = "MM/dd/yyyy"
        eventDateOfDeath.text = dateFormatter.string(from: datePicker.date)
        deathDay = datePicker.date
        
        if let birthday = birthDay {
            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: birthday, to: deathDay)
            let age = ageComponents.year!
            if age >= 0 {
//                eventAge.text = String(age)
                finalAge = String(age)
            } else {
//                eventAge.text = "n/a"
                finalAge = "dna"
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return modesOfContact.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return modesOfContact[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        familyDetailsContactMode.text = modesOfContact[row]
    }
    
    @IBAction func eventsHeaderDidTap(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            if self.eventDetailsHeight.constant == 1012 {
                self.eventDetailsHeight.constant = 30
                if self.familyDetailsHeight.constant == 728 {
                    self.familyDetailsHeight.constant = 30
                }
            } else {
                self.eventDetailsHeight.constant = 1012
                if self.familyDetailsHeight.constant == 728 {
                    self.familyDetailsHeight.constant = 30
                }
                                let bottomOffset = CGPoint(x: 0, y: 118)
                                self.scrollView.setContentOffset(bottomOffset, animated: true)
            }
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func familyHeaderDidTap(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            if self.familyDetailsHeight.constant == 728 {
                self.familyDetailsHeight.constant = 30
                if self.eventDetailsHeight.constant == 1012 {
                    self.eventDetailsHeight.constant = 30
                }
            } else if self.familyDetailsHeight.constant == 30 && self.eventDetailsHeight.constant == 1012 {
                self.familyDetailsHeight.constant = 728
                self.eventDetailsHeight.constant = 30
                let bottomOffset = CGPoint(x: 0, y: 450)
                self.scrollView.setContentOffset(bottomOffset, animated: true)
            } else {
                self.familyDetailsHeight.constant = 728
                if self.eventDetailsHeight.constant == 1012 {
                    self.eventDetailsHeight.constant = 30
                }
                let bottomOffset = CGPoint(x: 0, y: 170)
                self.scrollView.setContentOffset(bottomOffset, animated: true)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func addEventModalCloseDidTap() {
        self.dismiss(animated: true, completion: {})
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
}

extension UIButton {
    open override var isHighlighted: Bool {
        didSet {
            super.isHighlighted = false
        }
    }
}

extension UIToolbar {
    func ToolbarPicker(mySelect : Selector) -> UIToolbar {
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
}

//extension UIImage {
//    enum JPEGQuality: CGFloat {
//        case lowest  = 0
//        case low     = 0.25
//        case medium  = 0.5
//        case high    = 0.75
//        case highest = 1
//    }
//
//    /// Returns the data for the specified image in JPEG format.
//    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
//    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
//    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
//        return jpegData(compressionQuality: jpegQuality.rawValue)
//    }
//}
