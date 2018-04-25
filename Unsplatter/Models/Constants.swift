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
    
    // amount photos for downloading per page
    static let amountPerPage = 12
    
    // padding for cell in collectionView
    static let collectionCellPadding: CGFloat = 6.0
    
    // number for colums for different modes
    static let numberOfColumnsForLandscapeMode = 3
    static let numberOfColumnsForPortraitMode  = 2
    
    // segues
    static let showPhotoDetailsSegue = "showPhotoDetailsSegue"
    static let showPhotoOnMapSegue   = "showPhotoOnMapSegue"
    
    // map pin image size
    static let pinImageSize: CGFloat = 60.0
}

