//
//  PhotosCollectionViewController.swift
//  Unsplatter
//
//  Created by Anastasia on 4/18/18.
//  Copyright © 2018 Anastasia. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class PhotosCollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    private var photos: [Photo] = []
    private var photosByWord: PhotosByWord?
    private var layout: PhotosLayout?
    
    private var queryWord = ""
    private var pageNumber = 1
    private var isPageLoading = false
    
    private var statusBarView = UIView()
    private var searchButton = UIButton()
    private var searchBar = UISearchBar()
    private var tapGestureRecognizer = UITapGestureRecognizer()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.prefetchDataSource = self
        
        view.addSubview(statusBarView)
        view.addSubview(searchBar)
        view.addSubview(searchButton)
        
        configureGestureRecognizer()
        configureSearchBarWithSearchButton()
        
        if let layout = collectionView?.collectionViewLayout as? PhotosLayout {
            self.layout = layout
            self.layout?.delegate = self
        }
        
        collectionView?.contentInset = UIEdgeInsets(top: 0,
                                                    left: Constants.collectionCellPadding,
                                                    bottom: 16,
                                                    right: Constants.collectionCellPadding)
        
        fetchPhotosFromAPI(by: pageNumber) { [weak self] fetchedPhotos in
            self?.photos = fetchedPhotos

            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
                self?.isPageLoading = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
       self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideSearchBarIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let isStatusBarHidden = UIApplication.shared.isStatusBarHidden
        var barFrame = searchBar.frame
        barFrame.origin.y = isStatusBarHidden ? 0 : 20
        searchBar.frame = barFrame
            
        var buttonFrame = searchButton.frame
        buttonFrame.origin.y = isStatusBarHidden ? 0 : 20
        searchButton.frame = buttonFrame
        
        configureStatusBar()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // scroll in rotation
        if let paths = collectionView?.indexPathsForVisibleItems.sorted(), paths.count > 0 {
            let avgPath = paths[paths.count / 2]
            if avgPath.item > paths.count { // not apply for first screen
                DispatchQueue.main.async {
                    self.collectionView?.scrollToItem(at: avgPath, at: .centeredVertically, animated: false)
                }
            }
        }
    }
}

// MARK: - User Interactions
private extension PhotosCollectionViewController {
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        hideSearchBarIfNeeded()
    }
    
    @objc func searchButtonTapAction(button: UIButton) {
        showSearchBarIfNeeded()
    }
}


// MARK: UISearchBarDelegate
extension PhotosCollectionViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.view.endEditing(true)
            
            photosByWord = nil
            queryWord = ""
            
            fetchPhotosFromAPI(by: pageNumber) { [weak self] fetchedPhotos in
                self?.photos = fetchedPhotos
                
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                    self?.isPageLoading = false
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        
        pageNumber = 1
        
        // implementation request by word
        guard let word = searchBar.text else { return }
        queryWord = word
        
        fetchPhotosFromAPI(by: queryWord, page: pageNumber) { [weak self] photosByWord in
            self?.photosByWord = photosByWord
            
            print("totalResults: \(String(describing: photosByWord.totalResults))")
            print("totalPages: \(String(describing: photosByWord.totalPages))")
            
            guard let fetchedPhotos = photosByWord.photos else { return }
            self?.photos = fetchedPhotos
            
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
                self?.isPageLoading = false
            }
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

// MARK: - PhotosLayoutDelegate
extension PhotosCollectionViewController: PhotosLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        guard let height = photos[indexPath.item].height, let width = photos[indexPath.item].width  else { return 0.0 }

        // return proportional photo height - 5%
        guard let itemWidth = countItemWidth() else { return height * 0.05 }

        let itemHeight = height * itemWidth / width
        return itemHeight
    }
}

// MARK: - UIScrollViewDelegate
extension PhotosCollectionViewController {
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if searchBar.text == "" {
            hideSearchBarIfNeeded()
        } else {
            self.view.endEditing(true)
        }
    }
    
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
        
        if photosByWord != nil {
            guard let lastPage = photosByWord?.totalPages else { return }
            fetchPhotosFromAPI(by: queryWord, page: min(pageNumber, lastPage)) { [weak self] photosByWord in
                self?.photosByWord = photosByWord
                
                print("totalResults: \(String(describing: photosByWord.totalResults))")
                print("totalPages: \(String(describing: photosByWord.totalPages))")
                
                guard let fetchedPhotos = photosByWord.photos else { return }
                guard let indexes = self?.getIndexes(for: fetchedPhotos) else { return }
                self?.photos.append(contentsOf: fetchedPhotos)
                
                DispatchQueue.main.async {
                    self?.collectionView?.insertItems(at: indexes)
                    self?.isPageLoading = false
                    activityView.stopAnimating()
                }
            }
        } else {
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
}

// MARK: - UICollectionViewDataSourcePrefetching
extension PhotosCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let photo = photos[indexPath.item]
            guard let thumb = photo.urls?.thumb else { return }
            
            Alamofire.request(thumb).responseImage(completionHandler: {_ in })
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
        PhotosAPI.fetchPhotos(pageNumber: page, perPage: Constants.amountPerPage, completion: { [weak self] photos, error  in
            guard error == nil else {
                // show alert and try to fetch photos again
                let ac = UIAlertController(title: "Error during open gallery", message: error, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Try again", style: .default, handler: { [weak self] _ in
                     self?.fetchPhotosFromAPI(by: page, completion: completion)
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
    
    func fetchPhotosFromAPI(by word: String, page: Int, completion: @escaping (PhotosByWord) -> ()) {
        PhotosAPI.fetchPhotosByWord(queryWord: word, pageNumber: page, perPage: Constants.amountPerPage) { [weak self] photosByWord, error  in
            guard error == nil else {
                // show alert and try to fetch photos again
                let ac = UIAlertController(title: "Error during open gallery", message: error, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Try again", style: .default, handler: { [weak self] _ in
                    self?.fetchPhotosFromAPI(by: word, page: page, completion: completion)
                }))
                self?.present(ac, animated: true)
                return
            }
            
            guard let fetchedPhotos = photosByWord else {
                print("Something went wrong")
                return
            }
            completion(fetchedPhotos)
        }
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
        statusBarView.autoresizingMask = [.flexibleWidth]
    }
    
    func configureSearchBarWithSearchButton() {
        let statusBarHeight: CGFloat = 20.0
        
        searchBar.frame = CGRect(x: 0, y: statusBarHeight, width: self.view.bounds.width, height: 44)
        searchBar.delegate = self
        searchBar.alpha = 0
        searchBar.autoresizingMask = [.flexibleWidth]
        self.view.addSubview(searchBar)
        
        searchButton = UIButton(frame: CGRect(x: self.view.bounds.maxX - 52,
                                              y: statusBarHeight,
                                              width: 44, height: 44))
        searchButton.setImage(UIImage(named: "searchIcon.png"), for: .normal)
        searchButton.autoresizingMask = [.flexibleLeftMargin]
        searchButton.addTarget(self, action: #selector(searchButtonTapAction(button:)), for: .touchUpInside)
        self.view.addSubview(searchButton)
    }
    
    func configureGestureRecognizer() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        tapGestureRecognizer.delegate = self
        
        collectionView?.backgroundView = UIView(frame: (collectionView?.bounds)!)
        collectionView?.backgroundView!.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func showSearchBarIfNeeded() {
        guard self.searchBar.alpha == 0 else { return }
        
        searchButton.isHidden = true
        searchBar.becomeFirstResponder()
        UIView.animate(withDuration: 0.25) {
            self.searchBar.alpha = 1
        }
    }
    
    func hideSearchBarIfNeeded() {
        guard self.searchBar.alpha == 1 else { return }
        
        searchButton.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.searchBar.alpha = 0
            self.view.endEditing(true)
        }
    }
}



