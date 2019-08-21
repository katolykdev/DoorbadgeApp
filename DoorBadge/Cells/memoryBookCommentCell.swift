//
//  memoryBookCommentCell.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 7/9/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import UIKit

class memoryBookCommentCell: UITableViewCell {

    var yourobj : (() -> Void)? = nil
    
    
    var memoryBookController: MemoryBookViewController?
    
    @IBOutlet weak var memoryPhotoButton: UIButton!
    @IBOutlet weak var memoryText: UILabel!
    @IBOutlet weak var memoryName: UILabel!
    @IBOutlet weak var memoryDate: UILabel!
    @IBOutlet weak var memoryPhotoLabel: UILabel!
    
    @IBOutlet var stackview: UIStackView!
    @IBOutlet weak var memoryVideoLabel: UILabel!
    @IBOutlet weak var memoryVideoButton: UIButton!
    @IBOutlet weak var memoryBookStackViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        memoryBookStackViewHeight.constant = 150
        memoryPhotoButton.isUserInteractionEnabled = true
        memoryVideoButton.isUserInteractionEnabled = true
        
        
        let grayColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        memoryPhotoButton.layer.borderWidth = 3
        memoryPhotoButton.layer.borderColor = grayColor.cgColor
        memoryVideoButton.layer.borderWidth = 3
        memoryVideoButton.layer.borderColor = grayColor.cgColor

    }
    @IBOutlet var photoStackView: UIView!
    
    @IBOutlet var videoStackView: UIView!
    override func prepareForReuse() {
        memoryDate.text = ""
        memoryName.text = ""
        memoryText.text = ""
       
        memoryVideoLabel.isHidden = true
        memoryVideoButton.isHidden = true
        memoryPhotoLabel.isHidden = true
        
        memoryBookStackViewHeight.constant = 150
        
        stackview.insertArrangedSubview(photoStackView, at: 0)
        stackview.insertArrangedSubview(videoStackView, at: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func animate() {
//        
//        memoryBookController?.animateImageView(statusImageView: memoryPhotoButton, media:)
//   
//    }
    
    
    @IBAction func clickedPhotoButtonForCell(_ sender: UIButton) {
        
//        if let btnAction = self.yourobj {
//
//            btnAction()
//
//        }
        sender.pulsate()
        memoryBookController?.animateImageView(statusImageView: memoryPhotoButton, media: "photo")
    
    }
    
    @IBAction func clickedVideoButtonForCell(_ sender: UIButton) {
        sender.pulsate()
        memoryBookController?.animateImageView(statusImageView: memoryVideoButton, media: "video")
        
   
        
        
    }
    
}
