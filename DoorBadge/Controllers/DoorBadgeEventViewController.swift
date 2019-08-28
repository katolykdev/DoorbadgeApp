//
//  DoorBadgeEventViewController.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 5/21/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import UIKit
import Firebase
import IHKeyboardAvoiding

class DoorBadgeEventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentFacility: Facility!
    
    var indexToPass = 0
    var firstAndLastName = ""
    var dateToDate = ""
    
    var event: Event!
    
    var eventId = ""
    
    var giftToPass: Gift!
    
    var gifts: [[String: Any]] = []
    
    var logInType = UserDefaults.logInType
    
    var thanksFirst = true
    
    var eventIsOpen = true
    
    var lastSort = ""
    
    @IBOutlet weak var giftsReceivedLabel: UILabel!
    @IBOutlet weak var giftsTableView: UITableView!
    @IBOutlet weak var firstAndLastNameLabel: UILabel!
    
    @IBOutlet var showInfoGesture: UITapGestureRecognizer!
 
    @IBOutlet weak var dateToDateLabel: UILabel!
    @IBAction func showInfoGestureDidTap(_ sender: Any) {
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.thanksFirst = false
        
        firstAndLastNameLabel.text = firstAndLastName
        
        currentFacility = appDelegate.currentFacility
        
        giftsTableView.register(UINib(nibName: "GiftCellTableViewCell", bundle: nil), forCellReuseIdentifier: "giftCell")
        giftsTableView.register(UINib(nibName: "GiftAsFamilyTableViewCell", bundle: nil), forCellReuseIdentifier: "giftFamilyCell")
        giftsReceivedLabel.addCharacterSpacing(kernValue: 1.15)
        dateToDateLabel.text = dateToDate
        dateToDateLabel.addCharacterSpacing(kernValue: 1.15)
        
//        let button1 = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(segueToAddGift)) // action:#selector(Class.MethodName) for swift 3
//        button1.title = "Add Gift"
//        self.navigationItem.rightBarButtonItem  = button1
        
        switch logInType {
        case .family:
            let button1 = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(thanksSort)) // action:#selector(Class.MethodName) for swift 3
            button1.title = "Show Thanked First"
            self.navigationItem.rightBarButtonItem  = button1
            
        case .facility:
            let button1 = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(segueToAddGift)) // action:#selector(Class.MethodName) for swift 3
            button1.title = "Add Gift"
            self.navigationItem.rightBarButtonItem  = button1
        }
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    func defaultSort() {
        switch logInType {
        case .family:
            if thanksFirst == false {
                EventGifts.gifts.sort {
                        $0.thankYouSent && !$1.thankYouSent
                }
                
                let button1 = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(thanksSort)) // action:#selector(Class.MethodName) for swift 3
                button1.title = "Show Thanked Last"
                self.navigationItem.rightBarButtonItem  = button1
                
                thanksFirst = true
                self.giftsTableView.reloadData()
                
                if giftsTableView.isAtTop {
//                    self.giftsTableView.reloadSections([0], with: UITableView.RowAnimation.right)
                } else {
//                    self.giftsTableView.setContentOffset(.zero, animated: true)
//                    delayWithSeconds(0.3, completion: {
//                        self.giftsTableView.reloadSections([0], with: UITableView.RowAnimation.right)
//                    })
                    let indexPath = IndexPath(item: 0, section: 0)
                    giftsTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                }
                
                UserDefaults.thanksFirst = true
            } else {
                EventGifts.gifts.sort {
                    $1.thankYouSent && !$0.thankYouSent
                }
                
                let button1 = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(thanksSort)) // action:#selector(Class.MethodName) for swift 3
                button1.title = "Show Thanked First"
                self.navigationItem.rightBarButtonItem  = button1
                
                thanksFirst = false
                self.giftsTableView.reloadData()
                
                if giftsTableView.isAtTop {
//                    self.giftsTableView.reloadSections([0], with: UITableView.RowAnimation.right)
                } else {
//                    self.giftsTableView.setContentOffset(.zero, animated: true)
//                    delayWithSeconds(0.3, completion: {
//                        self.giftsTableView.reloadSections([0], with: UITableView.RowAnimation.right)
//                    })
                    let indexPath = IndexPath(item: 0, section: 0)
                    giftsTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                }
                
                UserDefaults.thanksFirst = false
            }
        
        default: break
        }
        self.giftsTableView.reloadData()
    }
    
    @objc func thanksSort() {
        defaultSort()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        giftsTableView.reloadData()
    }
    
    func getGifts() {
        let eventRef = Firestore.firestore().collection("events").document("\(event.eventId)").collection("gifts")
        
        eventRef.getDocuments() { [weak self] (snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            }
            EventGifts.gifts = snapshot?.documents.compactMap { Gift(dictionary: $0.data()) } ?? []
            self?.defaultSort()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getGifts()
            switch logInType {
            case .family:
                if UserDefaults.thanksFirst {
                    EventGifts.gifts.sort {
                        $0.thankYouSent && !$1.thankYouSent
                    }
                } else {
                    EventGifts.gifts.sort {
                        $1.thankYouSent && !$0.thankYouSent
                    }
                }
                
            default: break
            }

            giftsTableView.reloadData()
        
        let row = UserDefaults.lastEventSelectedRow
        if row > 0, EventGifts.gifts.count > row {
            let indexPath = IndexPath(item: 0, section: row)
            giftsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            
            UserDefaults.lastEventSelectedRow = 0
        }
    }

    @objc func segueToAddGift(sender: UIButton!) {
        performSegue(withIdentifier: "addGiftModal", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addGiftModal" {
            if let addGiftVC = segue.destination as? DoorBadgeAddGiftViewController {
                addGiftVC.currentEventId = event.eventId

                let nextPageBack = "Event"
                let backItem = UIBarButtonItem()
                backItem.title = nextPageBack
                navigationItem.backBarButtonItem = backItem
            }
        }
        
        if segue.identifier == "showEventInfo" {
            if let eventInfoVC = segue.destination as? EventInfoViewController {
            
                eventInfoVC.deceasedNameLabelText = "\(event.eventFirstName) \(event.eventLastName)"
                eventInfoVC.dateToDateLabelText = "\(event.dateOfBirth) - \(event.dateOfDeath)"
                eventInfoVC.eventImageReferenceString = "\(event.eventId)-full"
                eventInfoVC.eventTitleLabelText = "\(event.title)"
                eventInfoVC.eventId = eventId
                eventInfoVC.eventDateLabelText = "\(event.date)"
                eventInfoVC.event = event
                eventInfoVC.eventIsOpen = eventIsOpen
                
                if event.location == "" {
                    if LoggedIn.accountType == "family" {
                        
                    } else {
                        if let currentFacility = FacilityEvents.loggedInFacility {
                            eventInfoVC.eventLocationText1 = "\(currentFacility.address)"
                            eventInfoVC.eventLocationText2 = "\(currentFacility.city), \(currentFacility.state) \(currentFacility.zipCode)"
                        }
                    }
                } else {
                    eventInfoVC.eventLocationText1 = "\(event.location)"
                }
                
                eventInfoVC.familyPrimaryNameLabelText = "\(event.familyFirstName) \(event.familyLastName)"
                eventInfoVC.familyAddressLabelText = "\(event.familyAddress)"
                eventInfoVC.familyPhoneNumberLabelText = "\(event.familyPhone)"
                eventInfoVC.familyEmailLabelText = "\(event.primaryUserEmail)"
            }
        }
        
        if segue.identifier == "showGiftInfo" {
            if let giftVC = segue.destination as? GiftInfoViewController {
                giftVC.giftTitle = "\(giftToPass.title)"
                giftVC.giftDescription = "\(giftToPass.description)"
                giftVC.giftGiver = "From: \(giftToPass.giver)"
                giftVC.imageArray = []
                
                giftVC.imagesArray = [giftToPass.mainImage] + giftToPass.secondaryImages
                giftVC.thankYouWasSent = giftToPass.thankYouSent
                giftVC.giftId = giftToPass.giftId
                giftVC.eventId = eventId
                giftVC.indexPathRowNumber = indexToPass
                
                let backItem = UIBarButtonItem()
                backItem.title = "Event"
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch logInType {
        case .family: return 104 + UIScreen.main.bounds.width
        case .facility: return 128
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return EventGifts.gifts.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch logInType {
        case .facility: return 8
        case .family: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch logInType {
        case .facility:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "giftCell", for: indexPath) as? GiftCellTableViewCell else {
                fatalError("Not a Teaser Cell")
            }
            
            let gift = EventGifts.gifts[indexPath.section]
                cell.giftTitleLabel.text = gift.title
                if gift.giver != "" {
                    cell.giftGiverLabel.text = "From: \(gift.giver)"
                    cell.giftGiverLabel.addCharacterSpacing(kernValue: 1.10)
                } else {
                    cell.giftGiverLabel.text = ""
                }
            
                if gift.mainImage != "" {
                    cell.giftImageView.sd_setImage(with: URL(string: gift.mainImage))
                }
            return cell
        
        case .family:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "giftFamilyCell", for: indexPath) as? GiftAsFamilyTableViewCell else {
                fatalError("Not a Teaser Cell")
            }
            
            let gift = EventGifts.gifts[indexPath.section]
            
            cell.containerView.layer.cornerRadius = 10
            cell.containerView.layer.masksToBounds = true
                cell.giftTitleLabel.text = gift.title
                
                if gift.giver != "" {
                    cell.giftGiverLabel.text = "From:  \(gift.giver)"
                    cell.giftGiverLabel.addCharacterSpacing(kernValue: 1.10)
                } else {
                    cell.giftGiverLabel.text = ""
                }
            
                if gift.thankYouSent {
                    cell.thankYouLabel.text = "Thank you sent"
                    cell.sentIcon.isHidden = false
                } else {
                     cell.thankYouLabel.text = ""
                    cell.sentIcon.isHidden = true
                }
    
                if gift.mainImage != "" {
                    cell.giftImageView.sd_setImage(with: URL(string: gift.mainImage))
                }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        giftToPass = EventGifts.gifts[indexPath.section]
        
        indexToPass = indexPath.section
        performSegue(withIdentifier: "showGiftInfo", sender: self)
        UserDefaults.lastEventSelectedRow = indexToPass
    }
}
