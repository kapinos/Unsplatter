//
//  DetailsPhotoViewController.swift
//  Unsplatter
//
//  Created by Anastasia on 4/18/18.
//  Copyright © 2018 Anastasia. All rights reserved.
//

import UIKit

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
    private var task: URLSessionDataTask?
    private var photoDetails: PhotoDetails?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = ""
        
        photoImageView.layer.masksToBounds = true
        authorProfileImageView.layer.masksToBounds = true
        authorProfileImageView.layer.cornerRadius = 0.5 * authorProfileImageView.bounds.size.width
        configureLabels()
        
        guard let id = photoId else { return }
        PhotosAPI.fetchDetailsPhoto(by: id) { [weak self] details in
            if let det = details {
                self?.photoDetails = det
                DispatchQueue.main.async {
                    self?.fetchParametersIntoUI()
                }
            } else {
                print("Something went wrong")
            }
        }
    }
}

private extension DetailsImageViewController {
    func fetchParametersIntoUI() {
        guard let details = photoDetails else { return }
        
        authorLabel.text    = details.author.name
        usernameLabel.text  = "@\(details.author.username)"
        likesLabel.text     = "  ❤️ \(details.likesCount)  "
        
        if let location     = details.location?.title {
            locationButton.setTitle("📍\(location)", for: .normal)
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
        let task = URLSession.shared.dataTask(with: urlPath) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                imageView.alpha = 0
                imageView.image = UIImage(data: data)
                UIView.animate(withDuration: 0.25, animations: {
                    imageView.alpha = 1.0
                })
            }
        }
        task.resume()
        self.task = task
    }
    
    func configureLabels() {
        likesLabel.layer.borderColor = UIColor.lightGray.cgColor
        likesLabel.layer.borderWidth = 0.7
        likesLabel.layer.cornerRadius = 4.0
    }
    
    // FIXME: Add donload button handler
}
