//
//  EventCellTableViewCell.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 4/28/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import UIKit
import FirebaseStorage

class EventCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventCodeLabel: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    
    override func prepareForReuse() {
        self.eventDateLabel.text = ""
        self.eventNameLabel.text = ""
        self.eventCodeLabel.text = ""
        self.eventImageView.image = nil
    }
    
    func populate(event: Event) {
        eventNameLabel.text = "\(event.eventLastName), \(event.eventFirstName)"
        eventCodeLabel.text = "\(event.eventCode)"
        
        if event.date == "99999999" {
             eventDateLabel.text = "tba"
        } else {
            eventDateLabel.text = event.date.replacingOccurrences(of: "/", with: ".")
        }
    }
}
