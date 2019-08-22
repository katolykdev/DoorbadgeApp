//
//  GiftCellTableViewCell.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 5/21/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import UIKit

class GiftCellTableViewCell: UITableViewCell {

    override func prepareForReuse() {
        self.giftTitleLabel.text = ""
        self.giftGiverLabel.text = ""
        self.giftImageView.image = nil
    }
    
    @IBOutlet weak var giftImageView: UIImageView!
    @IBOutlet weak var giftGiverLabel: UILabel!
    @IBOutlet weak var giftTitleLabel: UILabel!
    
    func populate(gift: Gift) {
        giftTitleLabel.text = "\(gift.title)"
        
        if gift.giver != "" {
            giftGiverLabel.text = "From:  \(gift.giver)"
        } else {
            giftGiverLabel.text = ""
        }
    }
}
