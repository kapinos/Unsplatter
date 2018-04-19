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
    private var photos: [Photo] = []
    private var layout: PhotosLayout?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = collectionView?.collectionViewLayout as? PhotosLayout {
            self.layout = layout
            self.layout?.delegate = self
        }
        
        collectionView?.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
        
        PhotosAPI.fetchPhotos(completion: { [weak self] photos in
            if let ph = photos {
                self?.photos = ph
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                }
            } else {
                print("Something went wrong")
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        layout?.invalidateLayout()
    }
}

// MARK: UICollectionViewDataSource
extension PhotosCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.photoCellInCollectionView, for: indexPath) as! PhotoCell
        cell.render(photo: photos[indexPath.row])
        return cell
    }
}

// MARK: - PhotosLayoutDelegate
extension PhotosCollectionViewController: PhotosLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        
        guard let itemWidth = countItemWidth() else {
            // get proportional photo height - 5%
            return photos[indexPath.item].height * 0.05
        }
        
        let itemHeight = photos[indexPath.item].height * itemWidth / photos[indexPath.item].width
        return itemHeight
    }
}

// MARK: - UICollectionViewDelegate
extension PhotosCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView.cellForItem(at: indexPath) as? PhotoCell) != nil {
            let photo = photos[indexPath.row]
            performSegue(withIdentifier: Constants.showPhotoDetailsSegue, sender: photo)
        }
    }
}

// MARK: - Navigation
extension PhotosCollectionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.showPhotoDetailsSegue {
            guard let destination = segue.destination as? DetailsImageViewController,
                let photo = sender as? Photo else { return }
            destination.photoId = photo.id
        }
    }
}

// MARK: - Private
private extension PhotosCollectionViewController {
    private func countItemWidth() -> CGFloat? {
        guard let cv = collectionView else { return 0.0 }
        
        var width: CGFloat = 0.0
        if UIDevice.current.orientation.isLandscape {
            width = (cv.frame.width - (cv.contentInset.left + cv.contentInset.right + 10)) / CGFloat(Constants.numberOfColumnsForLandscapeMode)
        } else if UIDevice.current.orientation.isPortrait {
            width = (cv.frame.width - (cv.contentInset.left + cv.contentInset.right + 10)) / CGFloat(Constants.numberOfColumnsForPortraitMode)
        }
        return width
    }
}



