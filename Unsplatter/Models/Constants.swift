//
//  Constants.swift
//  Unsplatter
//
//  Created by Anastasia on 4/18/18.
//  Copyright © 2018 Anastasia. All rights reserved.
//

import UIKit

enum Constants {
    static let photoCellInCollectionView = "PhotoCell"
    
    // number for colums for different modes
    static let numberOfColumnsForLandscapeMode = 3
    static let numberOfColumnsForPortraitMode  = 2
    
    // segues
    static let showPhotoDetailsSegue = "showPhotoDetailsSegue"
}


extension UIColor {
    struct Blue {
        static let defaultBlue = UIColor(displayP3Red:  0/255,
                                         green:         122/255,
                                         blue:          255/255,
                                         alpha:         1)
    }
}
