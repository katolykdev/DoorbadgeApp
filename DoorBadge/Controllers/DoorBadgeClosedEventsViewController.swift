//
//  DoorBadgeClosedEventsViewController.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 7/5/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SDWebImage

class DoorBadgeClosedEventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    var event: Event!
    var events: [String] = []
    var gifts: [Gift] = []
    
    var sortedBy = "date"
    
    func reloadData() {
        closedEventsTableView.reloadData()
    }
    
    var logInType = ""
    
    let defaults = UserDefaults.standard
    
    var currentUserId = ""
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let db = Firestore.firestore()
    
    // Create a query against the collection.
    
    @IBOutlet weak var leftSortButton: UIBarButtonItem!
    
    @IBOutlet weak var closedEventsTableView: UITableView!
    
    @IBOutlet weak var closedEventsLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if defaults.string(forKey: "logInType") == "family" {
            logInType = "family"
        } else {
            logInType = "facility"
        }
        
        print(logInType)
        
        let user = Auth.auth().currentUser
        
        if let user = user {
            
            let uid = user.uid
            
            print(uid)
            
        }
        
        navigationController?.navigationBar.isTranslucent = false
        tabBarController?.tabBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        closedEventsLabel.text = "CLOSED EVENTS"
        closedEventsLabel.addCharacterSpacing(kernValue: 1.15)
        
        
        closedEventsTableView.register(UINib(nibName: "EventCellTableViewCell", bundle: nil), forCellReuseIdentifier: "eventCell")
        
        self.closedEventsTableView.dataSource = self;
        self.closedEventsTableView.delegate = self;
        
        
        //        navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(addEventButtonDidTap(_:)), imageName: "addIcon")
        
        if logInType == "family" {
            print("gettingFam")
            
            getFamily()
        } else {
            getFacility()
            print("gettingFacility")
        }
    }
    
    func changeDateStringToYearFirstNumber(date: String) -> Int {
        
        if date == "" {
            return 99999999
        } else {
            let removedSlashes = date.replacingOccurrences(of: "/", with: "")
            
            let year = removedSlashes.suffix(4)
            let monthAndDate = removedSlashes.prefix(4)
            
            let newDateNumberString = "\(year)\(monthAndDate)"
            
            let finalNumber = Int(newDateNumberString)
            return finalNumber!
        }
    }
    
    func defaultSort() {
        
        if logInType == "family" {
            
            FamilyEvents.pastEvents.sort(by: {
                if $0.date != $1.date {
                    return changeDateStringToYearFirstNumber(date: $0.date) < changeDateStringToYearFirstNumber(date: $1.date)
                }else {
                    return $0.eventLastName < $1.eventLastName
                }
            })
        } else {
            FacilityEvents.pastEvents.sort(by: {
                if $0.date != $1.date {
                    return changeDateStringToYearFirstNumber(date: $0.date) < changeDateStringToYearFirstNumber(date: $1.date)
                }else {
                    return $0.eventLastName < $1.eventLastName
                }
            })
        }
    }
    
    func getFacility(){
        let user = Auth.auth().currentUser
        
        if let user = user {
            
            let uid = user.uid
            
            let facilityRef = db.collection("facilities").document("\(uid)")
            
            facilityRef.getDocument { (document, error) in
                
                if let facility = document.flatMap({
                    
                    $0.data().flatMap({ (data) in
                        
                        return Facility(dictionary: data)
                        
                    })
                    
                }) {
                    FacilityEvents.loggedInFacility = facility
                    
                    if let currentFacility = FacilityEvents.loggedInFacility {
                        let events = currentFacility.events
                        
                        for event in events {
                            let eventRef = Firestore.firestore().collection("events").document(event)
                            
                            eventRef.getDocument { (document, error) in
                                if let event = document.flatMap({
                                    $0.data().flatMap({ (data) in
                                        return Event(dictionary: data)
                                    })
                                }) {
                                    
                                    if event.isOpen {
                                        
                                    } else {
                                        
                                        FacilityEvents.pastEvents.append(event)
                                        self.closedEventsTableView.reloadData()
                                        self.defaultSort()
                                        
                                    }
                                } else {
                                    print("that: document does not exist")
                                }
                            }
                        }
                    }
                } else {
                    print("this: document does not exist")
                }
            }
        }
    }
    
    func getFamily(){
        
        let user = Auth.auth().currentUser
        
        if let user = user {
            
            let uid = user.uid
            
            let familyRef = db.collection("users").document("\(uid)")
            
            familyRef.getDocument { (document, error) in
                
                if let family = document.flatMap({
                    
                    $0.data().flatMap({ (data) in
                        
                        return Family(dictionary: data)
                        
                    })
                }) {
                    FamilyEvents.loggedInFamily = family
                    
                    if let currentFamily = FamilyEvents.loggedInFamily {
                        let events = currentFamily.events
                        
                        for event in events {
                            
                            let eventRef = Firestore.firestore().collection("events").document(event)
                            
                            eventRef.getDocument { (document, error) in
                                if let event = document.flatMap({
                                    $0.data().flatMap({ (data) in
                                        return Event(dictionary: data)
                                    })
                                }) {
                                    if event.isOpen {
                                        
                                    } else {
                                        FamilyEvents.pastEvents.append(event)
                                        self.closedEventsTableView.reloadData()
                                        self.defaultSort()
                                    }
                                } else {
                                    print("that: document does not exist")
                                }
                            }
                        }
                    }
                } else {
                    print("this: document does not exist")
                }
            }
        }
    }
    
    @IBAction func addEventButtonDidTap(_ sender: Any) {
        performSegue(withIdentifier: "toAddEventAdmin", sender: Any?.self)
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    @IBAction func sortButtonDidTap(_ sender: Any) {
        if sortedBy == "date" {
            
            leftSortButton.title = "Sort by Date"
            sortedBy = "name"
            
            if logInType == "family" {
                
                FamilyEvents.pastEvents.sort(by: {
                    if $0.eventLastName != $1.eventLastName {
                        return $0.eventLastName < $1.eventLastName
                    } else if $0.date != $1.date {
                        return changeDateStringToYearFirstNumber(date: $0.date) < changeDateStringToYearFirstNumber(date: $1.date)
                    } else {
                        return $0.eventCode < $1.eventCode
                    }
                })
            } else {
                FacilityEvents.pastEvents.sort(by: {
                    if $0.eventLastName != $1.eventLastName {
                        return $0.eventLastName < $1.eventLastName
                    } else if $0.date != $1.date {
                        return changeDateStringToYearFirstNumber(date: $0.date) < changeDateStringToYearFirstNumber(date: $1.date)
                    } else {
                        return $0.eventCode < $1.eventCode
                    }
                })
                
            }
            if closedEventsTableView.isAtTop {
                self.closedEventsTableView.reloadSections([0], with: UITableView.RowAnimation.right)
            } else {
                self.closedEventsTableView.setContentOffset(.zero, animated: true)
                delayWithSeconds(0.3, completion: {
                    self.closedEventsTableView.reloadSections([0], with: UITableView.RowAnimation.right)
                })
            }
        } else {
            leftSortButton.title = "Sort by Name"
            sortedBy = "date"
            
            if logInType == "family" {
                
                FamilyEvents.pastEvents.sort(by: {
                    if $0.date != $1.date {
                        return changeDateStringToYearFirstNumber(date: $0.date) < changeDateStringToYearFirstNumber(date: $1.date)
                    } else if $0.eventLastName != $1.eventLastName {
                        return $0.eventLastName < $1.eventLastName
                    } else {
                        return $0.eventCode < $1.eventCode
                    }
                })
                
            } else {
                
                FacilityEvents.pastEvents.sort(by: {
                    if $0.date != $1.date {
                        return changeDateStringToYearFirstNumber(date: $0.date) < changeDateStringToYearFirstNumber(date: $1.date)
                    } else if $0.eventLastName != $1.eventLastName {
                        return $0.eventLastName < $1.eventLastName
                    } else {
                        return $0.eventCode < $1.eventCode
                    }
                })
                
                
            }
            
            if closedEventsTableView.isAtTop {
                
                self.closedEventsTableView.reloadSections([0], with: UITableView.RowAnimation.right)
                
            } else {
                self.closedEventsTableView.setContentOffset(.zero, animated: true)
                delayWithSeconds(0.3, completion: {
                    self.closedEventsTableView.reloadSections([0], with: UITableView.RowAnimation.right)
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        closedEventsTableView.reloadData()
        defaultSort()
        EventGifts.gifts = []
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if logInType == "family" {
            return FamilyEvents.pastEvents.count
        } else {
            return FacilityEvents.pastEvents.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventCellTableViewCell else {
            fatalError("Not a Teaser Cell")
        }
        
        if logInType == "family" {
            event = FamilyEvents.pastEvents[indexPath.row]
        } else {
            event = FacilityEvents.pastEvents[indexPath.row]
        }
        
        cell.populate(event: event)
        cell.eventNameLabel.addCharacterSpacing(kernValue: 1.05)
        
        let imageDownloadURL = event.image
        
        if imageDownloadURL != "" {
            cell.eventImageView.sd_setImage(with: URL(string: event.image))
        } else {
            cell.eventImageView.image = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if logInType == "family" {
            event = FamilyEvents.pastEvents[indexPath.row]
        } else {
            event = FacilityEvents.pastEvents[indexPath.row]
        }

        performSegue(withIdentifier: "showEventFromClosedEvents", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventFromClosedEvents" {
            if let projectVC = segue.destination as? DoorBadgeEventViewController {
                
                projectVC.eventIsOpen = false
                projectVC.event = event
                projectVC.firstAndLastName = "\(event.eventFirstName) \(event.eventLastName)"
                if event.date == "99999999" {
                    projectVC.dateToDate = "tba"
                } else {
                    projectVC.dateToDate = "\(event.date)"
                }
                
                projectVC.eventId = "\(event.eventId)"
                
                let nextPageBack = "Closed Events"
                let backItem = UIBarButtonItem()
                backItem.title = nextPageBack
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
}
