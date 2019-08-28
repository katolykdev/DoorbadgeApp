//
//  DoorBadgeOpenEventsViewController.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 4/27/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SDWebImage

class DoorBadgeOpenEventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    var event: Event!
    var events: [String] = []
    var gifts: [Gift] = []
    
    var sortedBy = "date"

    func reloadData() {
        openEventsTableView.reloadData()
    }

    var logInType = UserDefaults.logInType
    
    var currentUserId = ""
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    let db = Firestore.firestore()
    
    // Create a query against the collection.

    @IBOutlet var rightAddButton: UIBarButtonItem!
    
    @IBOutlet weak var leftSortButton: UIBarButtonItem!
    
    @IBOutlet weak var openEventsTableView: UITableView!
    
    @IBOutlet weak var openEventsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        tabBarController?.tabBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        openEventsLabel.text = "OPEN EVENTS"
        openEventsLabel.addCharacterSpacing(kernValue: 1.15)
        
        openEventsTableView.register(UINib(nibName: "EventCellTableViewCell", bundle: nil), forCellReuseIdentifier: "eventCell")
        
        self.openEventsTableView.dataSource = self;
        self.openEventsTableView.delegate = self;
       
//        navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(addEventButtonDidTap(_:)), imageName: "addIcon")
        
        if logInType == .family {
            rightAddButton.isEnabled = false
            rightAddButton.tintColor = .clear
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
        switch logInType {
        case .family:
            FamilyEvents.currentEvents.sort(by: {
                if $0.date != $1.date {
                    return changeDateStringToYearFirstNumber(date: $0.date) < changeDateStringToYearFirstNumber(date: $1.date)
                }else {
                    return $0.eventLastName < $1.eventLastName
                }
            })
        
        case .facility:
            FacilityEvents.currentEvents.sort(by: {
                if $0.date != $1.date {
                    return changeDateStringToYearFirstNumber(date: $0.date) < changeDateStringToYearFirstNumber(date: $1.date)
                }else {
                    return $0.eventLastName < $1.eventLastName
                }
            })
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
            
            switch logInType {
            case .family:
                FamilyEvents.currentEvents.sort(by: {
                    if $0.eventLastName != $1.eventLastName {
                        return $0.eventLastName < $1.eventLastName
                    } else if $0.date != $1.date {
                        return changeDateStringToYearFirstNumber(date: $0.date) < changeDateStringToYearFirstNumber(date: $1.date)
                    } else {
                        return $0.eventCode < $1.eventCode
                    }
                })
                
            case .facility:
                FacilityEvents.currentEvents.sort(by: {
                    if $0.eventLastName != $1.eventLastName {
                        return $0.eventLastName < $1.eventLastName
                    } else if $0.date != $1.date {
                        return changeDateStringToYearFirstNumber(date: $0.date) < changeDateStringToYearFirstNumber(date: $1.date)
                    } else {
                        return $0.eventCode < $1.eventCode
                    }
                })
            }
            if openEventsTableView.isAtTop {
                self.openEventsTableView.reloadSections([0], with: UITableView.RowAnimation.right)
            } else {
                self.openEventsTableView.setContentOffset(.zero, animated: true)
                delayWithSeconds(0.3, completion: {
                    self.openEventsTableView.reloadSections([0], with: UITableView.RowAnimation.right)
                })
            }
        } else {

            leftSortButton.title = "Sort by Name"
            sortedBy = "date"
            
            switch logInType {
            case .family:
                FamilyEvents.currentEvents.sort(by: {
                    if $0.date != $1.date {
                        return changeDateStringToYearFirstNumber(date: $0.date) < changeDateStringToYearFirstNumber(date: $1.date)
                    } else if $0.eventLastName != $1.eventLastName {
                        return $0.eventLastName < $1.eventLastName
                    } else {
                        return $0.eventCode < $1.eventCode
                    }
                })
                
            case .facility:
                FacilityEvents.currentEvents.sort(by: {
                    if $0.date != $1.date {
                        return changeDateStringToYearFirstNumber(date: $0.date) < changeDateStringToYearFirstNumber(date: $1.date)
                    } else if $0.eventLastName != $1.eventLastName {
                        return $0.eventLastName < $1.eventLastName
                    } else {
                        return $0.eventCode < $1.eventCode
                    }
                })
            }

            if openEventsTableView.isAtTop {
                self.openEventsTableView.reloadSections([0], with: UITableView.RowAnimation.right)
            } else {
                self.openEventsTableView.setContentOffset(.zero, animated: true)
                delayWithSeconds(0.3, completion: {
                    self.openEventsTableView.reloadSections([0], with: UITableView.RowAnimation.right)
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        openEventsTableView.reloadData()
        defaultSort()
        EventGifts.gifts = []
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch logInType {
        case .family:
            return FamilyEvents.currentEvents.count
        case .facility:
            return FacilityEvents.currentEvents.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventCellTableViewCell else {
            fatalError("Not a Teaser Cell")
        }
        
        switch logInType {
        case .family: event = FamilyEvents.currentEvents[indexPath.row]
        case .facility: event = FacilityEvents.currentEvents[indexPath.row]
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
        switch logInType {
        case .family: event = FamilyEvents.currentEvents[indexPath.row]
        case .facility: event = FacilityEvents.currentEvents[indexPath.row]
        }
        
        performSegue(withIdentifier: "showEventFromOpenEvents", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventFromOpenEvents" {
            if let projectVC = segue.destination as? DoorBadgeEventViewController {

                projectVC.eventIsOpen = true
                projectVC.event = event
                projectVC.firstAndLastName = "\(event.eventFirstName) \(event.eventLastName)"
                if event.date == "99999999" {
                    projectVC.dateToDate = "tba"
                } else {
                    projectVC.dateToDate = "\(event.date)"
                }
                
                projectVC.eventId = "\(event.eventId)"
             
                let nextPageBack = "Open Events"
                let backItem = UIBarButtonItem()
                backItem.title = nextPageBack
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
}

// MARK: - UpdatableViewController
extension DoorBadgeOpenEventsViewController: UpdatableViewController {
    func update() {
        openEventsTableView.reloadData()
    }
}

extension UIBarButtonItem {
    
    static func menuButton(_ target: Any?, action: Selector, imageName: String) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        
        button.setImage(UIImage(named: imageName), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        
//        button.tintColor = UIColor(red: 94.0/255.0, green: 163.0/255.0, blue: 113.0/255.0, alpha: 1)
        
        button.tintColor = UIColor.black
        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        return menuBarItem
    }
}

extension UILabel {
    func addCharacterSpacing(kernValue: Double) {
        if let labelText = text, labelText.count > 0 {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}

extension UIScrollView {
    var isAtTop: Bool {
        return contentOffset.y <= verticalOffsetForTop
    }
    
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    var verticalOffsetForTop: CGFloat {
        let topInset = contentInset.top
        return -topInset
    }
    
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
}
