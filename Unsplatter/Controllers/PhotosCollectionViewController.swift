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
    private var isPageLoading = false
    private var statusBarView = UIView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(statusBarView)
        configureStatusBar()
        
        if let layout = collectionView?.collectionViewLayout as? PhotosLayout {
            self.layout = layout
            self.layout?.delegate = self
        }
        
        collectionView?.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
        
        fetchPhotosFromAPI(by: pageNumber) { [weak self] fetchedPhotos in
            guard let indexes = self?.getIndexes(for: fetchedPhotos) else { return }
            self?.photos.append(contentsOf: fetchedPhotos)
            
            DispatchQueue.main.async {
                self?.collectionView?.insertItems(at: indexes)
                self?.isPageLoading = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
       self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // TODO: - scroll the last viewed photo when device had been rotated
        collectionView?.reloadData()
        layout?.invalidateLayout()
        
        switch UIDevice.current.orientation {
        case .portrait:
            if statusBarView.frame.equalTo(CGRect.zero) {
                configureStatusBar()
            } else {
                statusBarView.backgroundColor = UIColor.Gray.lightGray
            }
        case .landscapeLeft, .landscapeRight:
            statusBarView.backgroundColor = .clear
        default: return
        }
        
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

// MARK: - UIScrollViewDelegate
extension PhotosCollectionViewController {
    // in the end of the scrollView download another page with photos
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.equalTo(.zero) {
            return
        }
        if isPageLoading {
            return
        }
        
        let isBottomAchieved = (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.height)
        
        if !isBottomAchieved {
            return
        }

        isPageLoading = true
        pageNumber += 1
        
        // add ActivityIndicator
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.color = UIColor.Blue.defaultBlue

        activityView.center = CGPoint(x: view.bounds.width / 2.0,
                                      y: view.bounds.height - activityView.bounds.height)
        activityView.startAnimating()
        view.addSubview(activityView)
        
        fetchPhotosFromAPI(by: pageNumber) { [weak self] fetchedPhotos in
            guard let indexes = self?.getIndexes(for: fetchedPhotos) else { return }
            self?.photos.append(contentsOf: fetchedPhotos)
            
            DispatchQueue.main.async {
                self?.collectionView?.insertItems(at: indexes)
                self?.isPageLoading = false
                
                activityView.stopAnimating()
            }
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
    func fetchPhotosFromAPI(by page: Int, completion: @escaping ([Photo]) -> ()) {
        
        //typealias FetchingErrorHandler = (_ message: String?) -> ()
        PhotosAPI.fetchPhotos(pageNumber: page, completion: { [weak self] photos, error  in
            guard error == nil else {
                // show alert and try to fetch photos again
                let ac = UIAlertController(title: "Error during open gallery", message: error, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Try again", style: .default, handler: { [weak self] _ in
                    // TODO: - try do download again
                    // self?.fetchPhotosFromApi(page: page)
                }))
                self?.present(ac, animated: true)
                return
            }
            
            guard let fetchedPhotos = photos else {
                print("Something went wrong")
                return
            }
            completion(fetchedPhotos)
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
    
    // count [IndexPath] for new fetched photos
    func getIndexes(for fetchedPhotos: [Photo]) -> [IndexPath] {
        var indexes: [IndexPath] = []
        let count = photos.count
        
        for i in count ..< (fetchedPhotos.count + count) {
            indexes.append(IndexPath(item: i, section: 0))
        }
        return indexes
    }
    
    // configure status bar color without showing navigationBar
    func configureStatusBar() {
        statusBarView.frame = CGRect(origin: UIApplication.shared.statusBarFrame.origin,
                                     size: UIApplication.shared.statusBarFrame.size)
        statusBarView.backgroundColor = UIColor.Gray.lightGray
    }
}



