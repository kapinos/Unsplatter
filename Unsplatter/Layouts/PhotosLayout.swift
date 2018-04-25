//
//  PhotosLayout.swift
//  Unsplatter
//
//  Created by Anastasia on 4/18/18.
//  Copyright © 2018 Anastasia. All rights reserved.
//

import UIKit

protocol PhotosLayoutDelegate: class {
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat
}

class PhotosLayout: UICollectionViewLayout {

    weak var delegate: PhotosLayoutDelegate!
    
    // properties for configuring the layout
    private var cellPadding: CGFloat = Constants.collectionCellPadding
    
    // array for cache calculated attributes
    private var cache = [UICollectionViewLayoutAttributes]()
    
    // photo's size
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    // return the size of collectionView contents
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    // calculate an instance of CollectionViewLayoutAttributes for every item in layout
    override func prepare() {

        guard let collectionView = collectionView else {
            return
        }
        
        var numberOfColumns = Constants.numberOfColumnsForPortraitMode
        
        if UIDevice.current.orientation.isLandscape {
            numberOfColumns = Constants.numberOfColumnsForLandscapeMode
        } else if UIDevice.current.orientation.isPortrait {
            numberOfColumns = Constants.numberOfColumnsForPortraitMode
        }
        // count y-position for every column
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        cache.removeAll()
        contentHeight = 0.0
        // count height, frame, y-offset for every section in collectionView
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            let photoHeight = delegate.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath)
            let height = cellPadding * 2 + photoHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            // create attributes and appends it to cache[]()
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            // expands contentHeight to account for the frame for new item
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
