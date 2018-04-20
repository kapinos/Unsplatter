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
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var authorProfileImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var locationButton: UIButton!
    
    // MARK: - Properties
    var photoId: String?
    var photoImageSmall: UIImage?
    
    private var photoDetails: PhotoDetails?
    private var blurEffectView: UIView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = ""
        
        photoImageView.layer.masksToBounds = true
        authorProfileImageView.layer.masksToBounds = true
        authorProfileImageView.layer.cornerRadius = 0.5 * authorProfileImageView.bounds.size.width
        
        configureLabels()
        configureBlurEffectView()
        
        guard let id = photoId, let image = photoImageSmall else { return }
        self.photoImageView.image = image

        
        // fetch info about photo
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
                self?.fetchParametersIntoUI()
            }
        }
    }
}

private extension DetailsPhotoViewController {
    func fetchParametersIntoUI() {
        guard let details = photoDetails else { return }
        
        authorLabel.text    = details.author.name
        usernameLabel.text  = "@\(details.author.username)"
        likesLabel.text     = "  ❤️ \(details.likesCount)  "
        
        if let location = details.location?.title {
            let title = !location.isEmpty ? "📍\(location)" : ""
            locationButton.setTitle(title, for: .normal)
        }
        
        if let date = details.created {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            self.title = "created at: \(dateFormatter.string(from: date))"
        }
        downloadAndShowPhoto(from: details.urls.regular, imageView: photoImageView)
        downloadAndShowPhoto(from: details.author.profileImage.small, imageView: authorProfileImageView)
    }
    
    private func downloadAndShowPhoto(from url: String?, imageView: UIImageView) {
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
    
    func configureBlurEffectView() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = photoImageView.bounds
        blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        photoImageView?.addSubview(blurEffectView!)
    }
    
    // TODO: Add download button handler
}
