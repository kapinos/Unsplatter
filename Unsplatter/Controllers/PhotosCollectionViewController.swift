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
    private var itemWidth: CGFloat?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = collectionView?.collectionViewLayout as? PhotosLayout {
            layout.delegate = self
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // get the width for photo
        guard let cv = collectionView else { return }
        itemWidth = (cv.frame.width - (cv.contentInset.left + cv.contentInset.right + 10)) / CGFloat(Constants.numberOfColumns)
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
        guard let itemWidth = itemWidth else {
            return PhotosAPI.service.photos[indexPath.item].height * 0.05
        }
        let itemHeight = PhotosAPI.service.photos[indexPath.item].height * itemWidth / PhotosAPI.service.photos[indexPath.item].width
        return itemHeight
    }
}




