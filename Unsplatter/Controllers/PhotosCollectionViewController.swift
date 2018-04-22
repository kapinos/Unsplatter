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
    private var pageNumber = 1
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = collectionView?.collectionViewLayout as? PhotosLayout {
            self.layout = layout
            self.layout?.delegate = self
        }
        
        collectionView?.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
        
        fetchPhotosIntoCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
       self.navigationController?.setNavigationBarHidden(true, animated: animated)
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
            // get selected image and photo.id
            let image = (collectionView.cellForItem(at: indexPath) as? PhotoCell)?.image
            let photo = photos[indexPath.row]
            performSegue(withIdentifier: Constants.showPhotoDetailsSegue, sender: (image, photo))
        }
    }
}

// MARK: - Navigation
extension PhotosCollectionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.showPhotoDetailsSegue {
            guard let destination = segue.destination as? DetailsPhotoViewController,
                let data = sender as? (image: UIImage, photo: Photo) else { return }
            destination.photoId = data.photo.id
            destination.photoPriorImage = data.image
        }
    }
}

// MARK: - Private
private extension PhotosCollectionViewController {
    // TODO: - fetch more than one page
    func fetchPhotosIntoCollectionView() {
        PhotosAPI.fetchPhotos(pageNumber: pageNumber, completion: { [weak self] photos, error  in
            guard error == nil else {
                // show alert and try fetch photos again
                let ac = UIAlertController(title: "Error during open gallery", message: error, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Try again", style: .default, handler: { [weak self] _ in
                    self?.fetchPhotosIntoCollectionView()
                }))
                self?.present(ac, animated: true)
                
                return
            }
            
            guard let photos = photos else {
                print("Something went wrong")
                return
            }
            
            self?.photos = photos
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
            }
        })
    }
    
    func countItemWidth() -> CGFloat? {
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



