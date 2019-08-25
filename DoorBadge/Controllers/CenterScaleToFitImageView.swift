//
//  CenterScaleToFitImageView.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 6/10/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import UIKit

class CenterScaleToFitImageView: UIImageView {
    override var bounds: CGRect {
        didSet {
            adjustContentMode()
        }
    }
    
    override var image: UIImage? {
        didSet {
            adjustContentMode()
        }
    }
    
    func adjustContentMode() {
        guard let image = image else {
            return
        }
        if image.size.width > bounds.size.width ||
            image.size.height > bounds.size.height {
            contentMode = .scaleAspectFit
        } else {
            contentMode = .center
        }
    }
}
