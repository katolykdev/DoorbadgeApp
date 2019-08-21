//
//  memoryBookHeaderCell.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 7/9/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import UIKit

class memoryBookHeaderCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var memoryBookImageView: UIImageView!
    @IBOutlet weak var memoryBookName: UILabel!
    @IBOutlet weak var memoryBookDates: UILabel!
    

    
    
    
    
}
