//
//  GiftAsFamilyTableViewCell.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 6/26/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import UIKit

class GiftAsFamilyTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.layer.borderWidth = 1
        let grayColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1)
        self.containerView.layer.borderColor = grayColor.cgColor
    }
    
    override func prepareForReuse() {
        
        self.thankYouLabel.text = ""
        self.giftTitleLabel.text = ""
        self.giftGiverLabel.text = ""
        self.giftImageView.image = nil
        self.sentIcon.isHidden = true
    }
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var sentIcon: UIImageView!
    
    @IBOutlet weak var giftImageView: UIImageView!
    
    
    @IBOutlet weak var thankYouLabel: UILabel!
    
    
    @IBOutlet weak var giftGiverLabel: UILabel!
    
    
    @IBOutlet weak var giftTitleLabel: UILabel!
    
    
    func populate(gift: Gift) {
        
        
        giftTitleLabel.text = "\(gift.title)"
        
        if gift.giver != "" {
            
            giftGiverLabel.text = "From:  \(gift.giver)"
            
        } else {
            
            giftGiverLabel.isHidden = true
            
            
        }
        //        eventDateLabel.text = event.getReleaseDateFrom(integer: event.date)
        thankYouLabel.text = ""
        

    }
    
    
    
    
    
    
    
    
}
