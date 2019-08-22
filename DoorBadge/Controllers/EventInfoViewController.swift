//
//  EventInfoViewController.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 5/27/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseUI
import MessageUI
import SDWebImage

class EventInfoViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    let storage = Storage.storage()
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var loveingMemoryLabel: UILabel!
    
    var event: Event!
    var deceasedNameLabelText = ""
    
    var dateToDateLabelText = ""
    
    var eventImageReferenceString = ""
    
    var eventTitleLabelText = ""
    
    var eventDateLabelText = ""
    
    var eventLocationText1 = ""
    
    var eventLocationText2 = ""
    
    var familyPrimaryNameLabelText = ""
    
    var familyAddressLabelText = ""
    
    var familyPhoneNumberLabelText = ""
    
    var familyEmailLabelText = ""
    
    var eventId = ""
    
    var submittedGift = false
    
    var eventIsOpen = true
    
    var logInType = ""
    
    @IBOutlet weak var deceasedNameLabel: UILabel!
    
    @IBOutlet weak var dateToDateLabel: UILabel!
    
    @IBOutlet weak var eventImageView: UIImageView!
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    
    @IBOutlet weak var eventDateLabel: UILabel!
    
    @IBOutlet weak var eventLocationLabel1: UILabel!
    
    @IBOutlet weak var eventLocationLabel2: UILabel!

    @IBOutlet weak var signMemoryBookButton: UIButton!
    
    @IBOutlet weak var familyPrimaryNameLabel: UILabel!
    
    @IBOutlet weak var familyAddressLabel: UILabel!
    
    @IBOutlet weak var markAsClosedButton: UIButton!
    
    @IBOutlet weak var mailButtonOutlet: UIButton!
    
    @IBOutlet var eventImageViewHeight: NSLayoutConstraint!
    
    @IBAction func mailButtonDidPress(_ sender: Any) {
        let mailComposeViewController = configureMailController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showMailError()
        }
    }
    
    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients([familyEmailLabelText])
        mailComposerVC.setSubject("Funeral Services")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func sendData(title: String) {
        self.eventTitleLabelText = title
        print(title)
    }
    
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email", preferredStyle: .alert)
        
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    func dialNumber(number : String) {
        if let url = URL(string: "tel://\(number)"),
            UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            // add error message here
        }
    }
    
    @IBAction func markAsClosedButtonPressed(_ sender: Any) {
        //IS OPEN OPEN OPEN OPEN OPEN OPEN OPEN OPEN
        
        if eventIsOpen == true {
            
            //MAKE CLOSED
            eventIsOpen = false
            
            //CHANGE BUTTON TITLE TO OPEN
            markAsClosedButton.setTitle("Mark As Open", for: .normal)
            
            //UPDATE DOC IN DATABASE
            let docRef = db.collection("events").document(eventId)
            docRef.updateData(["isOpen" : false])
         
            if logInType == "family" {
                
//                 EventGifts.gifts[indexPathRowNumber].updateValue(false, forKey: "thankYouSent")
//
                if let index = FamilyEvents.currentEvents.index(where: {$0.eventId == eventId}) {
                    
                    FamilyEvents.pastEvents.append(FamilyEvents.currentEvents[index])
                    
                    FamilyEvents.currentEvents.remove(at: index)
                    
                }
            
            } else {
                
                if let index = FacilityEvents.currentEvents.index(where: {$0.eventId == eventId}) {
                    
                    FacilityEvents.pastEvents.append(FacilityEvents.currentEvents[index])
                    
                    FacilityEvents.currentEvents.remove(at: index)
                    
                }

            }
//            EventGifts.gifts[indexPathRowNumber].updateValue(false, forKey: "thankYouSent")
            
        } else {
            
             //IS CLOSED CLOSED CLOSED CLOSED CLOSED CLOSED CLOSED
            
            //MAKE CLOSED
            eventIsOpen = true
            
            //CHANGE BUTTON TITLE TO OPEN
            markAsClosedButton.setTitle("Mark As Closed", for: .normal)
            
            //UPDATE DOC IN DATABASE
            let docRef = db.collection("events").document(eventId)
            docRef.updateData(["isOpen" : true])
            
            if logInType == "family" {
                
                //                 EventGifts.gifts[indexPathRowNumber].updateValue(false, forKey: "thankYouSent")
                //
                if let index = FamilyEvents.pastEvents.index(where: {$0.eventId == eventId}) {
                    
                    FamilyEvents.currentEvents.append(FamilyEvents.pastEvents[index])
                    
                    FamilyEvents.pastEvents.remove(at: index)
                    
                }
                
            } else {
                
                if let index = FacilityEvents.pastEvents.index(where: {$0.eventId == eventId}) {
                    
                    FacilityEvents.currentEvents.append(FacilityEvents.pastEvents[index])
                    
                    FacilityEvents.pastEvents.remove(at: index)
                    
                }
                
            }

        }
    
    }
    
    
    @IBOutlet weak var phoneButtonOutlet: UIButton!
    @IBAction func phoneButton(_ sender: Any) {
        if let number = phoneButtonOutlet.title(for: .normal) {
            if number.isValid(regex: .phone) {
               
                dialNumber(number: number)
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        let imageStorageRef = Storage.storage().reference().child("event-images")
//        let reference = imageStorageRef.child(eventImageReferenceString)
//
//        if let thumbnail: UIImage = UIImage(named: "photoIcon") {
//            eventImageView!.sd_setImage(with: URL(string: event.image))
//        }
        
        if logInType == "facility" {
            if let index = FacilityEvents.currentEvents.index(where: {$0.eventId == eventId}) {
            
                let thisEvent = FacilityEvents.currentEvents[index]
                
                deceasedNameLabel.text = "\(thisEvent.eventFirstName) \(thisEvent.eventLastName)"
                dateToDateLabel.text = "\(thisEvent.dateOfBirth) - \(thisEvent.dateOfDeath)".replacingOccurrences(of: "/", with: ".")
                eventTitleLabel.text = "\(thisEvent.title)"
                if thisEvent.date == "99999999" {
                    eventDateLabel.text = "Date: TBA"
                } else {
                    eventDateLabel.text = "\(thisEvent.date)".replacingOccurrences(of: "/", with: ".")
                }
               
                eventLocationLabel1.text = "\(thisEvent.location)"
                
                familyPrimaryNameLabel.text = "\(thisEvent.familyFirstName) \(thisEvent.familyLastName)"
                familyAddressLabel.text = "\(thisEvent.familyAddress)"
                phoneButtonOutlet.setTitle(thisEvent.familyPhone, for: .normal)
                mailButtonOutlet.setTitle(thisEvent.primaryUserEmail, for: .normal)
                 eventImageView!.sd_setImage(with: URL(string: thisEvent.image))
                
                print(FacilityEvents.currentEvents[index])
            
            
            }
            
        }
        
        
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(event)
        submittedGift = false
        if logInType == "facility" {
        let button1 = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(editEventModal))
        button1.title = "Edit Event"
        self.navigationItem.rightBarButtonItem  = button1
        }
        
        
        
        deceasedNameLabel.text = deceasedNameLabelText
        dateToDateLabel.text = dateToDateLabelText.replacingOccurrences(of: "/", with: ".")
        dateToDateLabel.addCharacterSpacing(kernValue: 1.15)
       
//        let imageStorageRef = Storage.storage().reference().child("event-images")
//        let reference = imageStorageRef.child(eventImageReferenceString)
//
//        if let thumbnail: UIImage = UIImage(named: "photoIcon") {
//            eventImageView.sd_setImageWithReferenceWithFade(reference: reference, placeholder: thumbnail)
//
//        }
        
        if logInType == "family" {
            
            markAsClosedButton.isHidden = true
            
        } else {
            
        }


        let screenSize = view.bounds.width
        
        eventImageViewHeight.constant = screenSize
//        eventImageView.contentMode = .scaleToFill
        
        eventTitleLabel.text = eventTitleLabelText
        eventTitleLabel.addCharacterSpacing(kernValue: 1.10)

        if eventDateLabelText == "99999999" {
            eventDateLabel.text = "Date: TBA"
            eventDateLabel.addCharacterSpacing(kernValue: 1.10)
        } else {
            eventDateLabel.text = eventDateLabelText.replacingOccurrences(of: "/", with: ".")
            eventDateLabel.addCharacterSpacing(kernValue: 1.10)
        }
        eventLocationLabel1.text = eventLocationText1
        eventLocationLabel1.addCharacterSpacing(kernValue: 1.10)
        eventLocationLabel2.text = eventLocationText2
        eventLocationLabel2.addCharacterSpacing(kernValue: 1.10)
        
        loveingMemoryLabel.addCharacterSpacing(kernValue: 1.15)
        
        signMemoryBookButton.layer.borderWidth = 2
        signMemoryBookButton.layer.cornerRadius = 5
        
        familyPrimaryNameLabel.text = familyPrimaryNameLabelText
        
        familyAddressLabel.text = familyAddressLabelText
        
        
        phoneButtonOutlet.setTitle(familyPhoneNumberLabelText, for: .normal)
        mailButtonOutlet.setTitle(familyEmailLabelText, for: .normal)
  
        
        phoneButtonOutlet.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        mailButtonOutlet.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
 
        
        if eventIsOpen {
            
            markAsClosedButton.setTitle("Mark As Closed", for: .normal)
            
        } else {
            
            markAsClosedButton.setTitle("Mark As Open", for: .normal)
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if submittedGift == true {
            self.navigationController?.popViewController(animated: true)
        }
       
        
    }
    
    @objc func editEventModal(sender: UIButton!) {
        
        performSegue(withIdentifier: "editEventModal", sender: self)
        
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editEventModal" {
            
            if let editEventVC = segue.destination as? DoorBadgeAddEventAdminViewController {
            

                
                editEventVC.isEditing = true
                
                editEventVC.existingEvent = event
                
                
                
                let nextPageBack = "Event"
                let backItem = UIBarButtonItem()
                backItem.title = nextPageBack
                navigationItem.backBarButtonItem = backItem
                
                
            }
            
        }
        
    }
    
    
}

extension UIImageView {
    
    public func sd_setImageWithReferenceWithFade(reference: StorageReference, placeholder: UIImage)
    {        self.sd_setImage(with: reference, placeholderImage: placeholder) { (image, err, cacheType, reference) in
        if let downLoadedImage = image
        {
            if cacheType == .none
            {
                self.alpha = 0
                UIView.transition(with: self, duration: 0.3, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                    self.image = downLoadedImage
                    self.alpha = 1
                }, completion: nil)
            }
        }
        else
        {
            self.image = placeholder
        }
        }
    }
}

extension String {
    
    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }
    
    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }
    
    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }
    
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    func makeACall() {
        if isValid(regex: .phone) {
            if let url = URL(string: "tel://\(self.onlyDigits())"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}





