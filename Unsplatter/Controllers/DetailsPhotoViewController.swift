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
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var authorProfileImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var locationButton: UIButton!
    
    // MARK: - Properties
    var photoId: String?
    var photoPriorImage: UIImage?
    
    private var photoDetails: PhotoDetails?
    private var blurEffectView: UIView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = ""
        
        configureLabels()
        configureAuthorImageView()
        
        guard let photoId = photoId, let priorImage = photoPriorImage else { return }
        configurePhotoImageView(image: priorImage)

        fetchDetailsPhoto(by: photoId)
    }
}

private extension DetailsPhotoViewController {
    // fetch info about photo
    func fetchDetailsPhoto(by id: String) {
        PhotosAPI.fetchPhotoDetails(by: id) { [weak self] details, error in
            guard error == nil else {
                // TODO: - show alert
                print(error!)
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
        likesLabel.text = "  ❤️ \(details.likesCount ?? 0)  "
        
        if let location = details.location?.title {
            locationButton.setTitle("📍 \(location)", for: .normal)
        } else {
            locationButton.setTitle("📍 No location", for: .normal)
            locationButton.isEnabled = false
        }
        
        if let date = details.created {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            self.title = "created at: \(dateFormatter.string(from: date))"
        }
        
        if let urls = details.urls {
            downloadAndShowPhoto(from: urls.regular, imageView: photoImageView)
        }
    }
    
    // implement reqest for download photo and set resultImage into imageView
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
    
    func configureLabels() {
        likesLabel.layer.borderColor = UIColor.lightGray.cgColor
        likesLabel.layer.borderWidth = 0.7
        likesLabel.layer.cornerRadius = 4.0
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
    
    // TODO: Add download button handler
}
