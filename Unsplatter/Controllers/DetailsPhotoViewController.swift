//
//  DetailsPhotoViewController.swift
//  Unsplatter
//
//  Created by Anastasia on 4/18/18.
//  Copyright © 2018 Anastasia. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class DetailsPhotoViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var profileNameLabel: UILabel!
    @IBOutlet private weak var authorProfileImageView: UIImageView!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet private weak var dateCreationLabel: UILabel!
    @IBOutlet private weak var zoomingScrollView: UIScrollView!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var locationButton: UIButton!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var zoomingSignImageView: UIImageView!
    
    // MARK: - Properties
    var photoId: String?
    var photoPriorImage: UIImage?

    private var photoDetails: PhotoDetails?
    private var blurEffectView: UIView?
    private var fakeLikesAmount = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""
        navigationController?.navigationBar.topItem?.title = ""
        
        configureLabels()
        configureAuthorImageView()
        configureProgressView()
        configureZoomingScrollView()
        
        guard let photoId = photoId, let priorImage = photoPriorImage else { return }
        configurePhotoImageView(image: priorImage)
        fetchDetailsPhoto(by: photoId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make visible the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // Managed layouts for scrollView with imageView hen device had been rotated
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateLayoutsForScrollView()
    }
}

// MARK: - UIScrollViewDelegate
extension DetailsPhotoViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) / 2.0, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) / 2.0, 0)
        scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0)
                
        zoomingSignImageView.isHidden = true
    }
}

// MARK: - User Interactions
extension DetailsPhotoViewController {
    // change likes amount in button
    @IBAction func likesButtonPressed(_ sender: UIButton) {
        fakeLikesAmount += 1
        sender.setTitle("  ❤️ \(fakeLikesAmount)  ", for: .normal)
        sender.pulsate()
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        guard let photo = photoDetails else { return }
        performSegue(withIdentifier: Constants.showPhotoOnMapSegue, sender: photo)
    }
    
    @IBAction func downloadBarButtonPressed(_ sender: UIBarButtonItem) {
        downloadImage { image in
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // got back an error
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            self.title = "saved successfully"
            progressView.tintColor = .green
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                self.title = ""
                self.configureProgressView()
            })
        }
    }
}

// MARK: - Private
private extension DetailsPhotoViewController {
    // Download opened image into photo gallery
    func downloadImage(completion: @escaping (UIImage) -> ()) {
        progressView.isHidden = false
        
        guard let details = photoDetails else { return }
        guard let downloadURL = details.links?.download else { return }
        
        Alamofire.request(downloadURL).responseImage { response in
            guard let imageResult = response.result.value else { return }
            completion(imageResult)
            }.downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                DispatchQueue.main.async {
                    self.progressView.progress = Float(progress.fractionCompleted)
                }
        }
    }
    
    // Fetch info about photo
    func fetchDetailsPhoto(by id: String) {
        PhotosAPI.fetchPhotoDetails(by: id) { [weak self] details, error in
            guard error == nil else {
                // show alert and return back
                let ac = UIAlertController(title: "Error during open photo", message: error, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                }))
                self?.present(ac, animated: true)
                return
            }
            
            guard let details = details else {
                print("Something went wrong")
                return
            }
            self?.photoDetails = details
            DispatchQueue.main.async {
                self?.setDetailsPhotoIntoUI()
            }
        }
    }
    
    func setDetailsPhotoIntoUI() {
        guard let details = photoDetails else { return }
        
        // details about author
        if let author = details.author, let profileName = author.profileName {
            authorLabel.text = author.name
            profileNameLabel.text = "@\(profileName)"
            
            if let profileImage = author.profileImage {
                downloadAndShowPhoto(from: profileImage.small, imageView: authorProfileImageView)
            }
        }
        
        // details about photo
        if let likes = details.likesCount {
            fakeLikesAmount = likes
            likesButton.setTitle("  ❤️ \(fakeLikesAmount)  ", for: .normal)
        }
        
        // locationButton
        if let locationTitle = details.location?.title {
            locationButton.setTitle("📍 \(locationTitle)", for: .normal)
            
            if details.location?.position?.latitude != nil, details.location?.position?.longitude != nil {
                locationButton.isEnabled = true
            } else {
                locationButton.setTitleColor(UIColor.Gray.nickelGray, for: .normal)
                locationButton.isEnabled = false
            }
        } else {
            locationButton.setTitle("📍 No location", for: .normal)
            locationButton.setTitleColor(UIColor.Gray.nickelGray, for: .normal)
            locationButton.isEnabled = false
        }
        
        // dateCreationLabel
        if let date = details.created {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            dateCreationLabel.text = "created at: \(dateFormatter.string(from: date))"
        }
        
        // show photo
        if let urls = details.urls {
            downloadAndShowPhoto(from: urls.regular, imageView: photoImageView)
        }
    }
    
    // Implement request for download photo and set resultImage into imageView
    func downloadAndShowPhoto(from url: String?, imageView: UIImageView) {
        guard let urlPath = URL(string: url!) else { return }
        
        Alamofire.request(urlPath).responseImage { response in
            guard let image = response.result.value else { return }
            DispatchQueue.main.async {
                imageView.image = image
                UIView.animate(withDuration: 0.25, animations: {
                    self.blurEffectView?.alpha = 0
                })
            }
        }
    }
    
    // Update layouts for scrollView content
    func updateLayoutsForScrollView() {
        zoomingScrollView.contentSize = zoomingScrollView.bounds.size
        
        let widthRatio = zoomingScrollView.bounds.size.width / photoImageView.bounds.size.width
        let heightRatio = zoomingScrollView.bounds.size.height / photoImageView.bounds.size.height
        
        zoomingScrollView.zoomScale = min(widthRatio, heightRatio)
        zoomingScrollView.contentInset = UIEdgeInsets(top: (zoomingScrollView.bounds.size.height - photoImageView.frame.size.height) / 2,
                                                      left: (zoomingScrollView.bounds.size.width - photoImageView.frame.size.width) / 2,
                                                      bottom: 0, right: 0)
        
        photoImageView.contentMode = .scaleAspectFit
    }
    
    func configureLabels() {
        likesButton.layer.borderColor  = UIColor.lightGray.cgColor
        likesButton.layer.borderWidth  = 0.7
        likesButton.layer.cornerRadius = 4.0
    }
    
    func configureAuthorImageView() {
        authorProfileImageView.layer.masksToBounds = true
        authorProfileImageView.layer.cornerRadius = 0.5 * authorProfileImageView.bounds.size.width
    }
    
    func configurePhotoImageView(image: UIImage) {
        photoImageView.layer.masksToBounds = true
        photoImageView.image = image
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = photoImageView.bounds
        blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        photoImageView.addSubview(blurEffectView!)
    }
    
    func configureProgressView() {
        progressView.progress = 0.0
        progressView.isHidden = true
        progressView.tintColor = UIColor.Blue.defaultBlue
    }
    
    func configureZoomingScrollView() {
        zoomingScrollView.delegate = self
        zoomingScrollView.minimumZoomScale = 0.75
        zoomingScrollView.maximumZoomScale = 4
    }
}

// MARK: - Navigation
extension DetailsPhotoViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.showPhotoOnMapSegue {
            guard let destination = segue.destination as? DetailsMapViewController,
                let data = sender as? PhotoDetails else { return }
            destination.photoDetails = data
        }
    }
}


