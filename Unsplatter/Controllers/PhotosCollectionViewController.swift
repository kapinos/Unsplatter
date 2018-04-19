//
//  PhotosCollectionViewController.swift
//  Unsplatter
//
//  Created by Anastasia on 4/18/18.
//  Copyright © 2018 Anastasia. All rights reserved.
//

import UIKit

class PhotosCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties
    private var token: NSKeyValueObservation?
//    private var itemWidth: CGFloat?
    private var layout: PhotosLayout?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = collectionView?.collectionViewLayout as? PhotosLayout {
            self.layout = layout
            self.layout?.delegate = self
        }
        
        self.title = "Photos"
        collectionView?.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        token = PhotosAPI.service.observe(\.photos) { _, _ in
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
        PhotosAPI.service.fetchPhotos()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        layout?.invalidateLayout()
    }
}

// MARK: UICollectionViewDataSource
extension PhotosCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PhotosAPI.service.photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.photoCellInCollectionView, for: indexPath) as! PhotoCell
        cell.render(photo: PhotosAPI.service.photos[indexPath.row])
        return cell
    }
}

extension PhotosCollectionViewController: PhotosLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        
        guard let itemWidth = countItemWidth() else {
            print("5%") // LOG
            return PhotosAPI.service.photos[indexPath.item].height * 0.05
        }
        
        let itemHeight = PhotosAPI.service.photos[indexPath.item].height * itemWidth / PhotosAPI.service.photos[indexPath.item].width
        return itemHeight
    }
}

// MARK: - Private
private extension PhotosCollectionViewController {
    private func countItemWidth() -> CGFloat? {
        guard let cv = collectionView else { return 0.0 }
        
        var width: CGFloat = 0.0
        if UIDevice.current.orientation.isLandscape {
            width = (cv.frame.width - (cv.contentInset.left + cv.contentInset.right + 10)) / CGFloat(Constants.numberOfColumnsForLandscapeMode)
            print("landscape, w = \(width)")  // LOG
        } else if UIDevice.current.orientation.isPortrait {
            width = (cv.frame.width - (cv.contentInset.left + cv.contentInset.right + 10)) / CGFloat(Constants.numberOfColumnsForPortraitMode)
            print("portrait, w = \(width)")  // LOG
        }
        return width
    }
}



