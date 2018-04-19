//
//  PhotoCell.swift
//  Unsplatter
//
//  Created by Anastasia on 4/18/18.
//  Copyright © 2018 Anastasia. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoIdLabel: UILabel!
    
    private var task: URLSessionDataTask?
    
    func render(photo: Photo) {        
        guard let url = URL(string: photo.urls.thumb) else { return }
        
        downloadPhoto(from: url)
        photoIdLabel.text = photo.id
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard let task = task else { return }
        task.cancel()
    }
    
    private func downloadPhoto(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.photoImageView.image = UIImage(data: data)
            }
        }
        task.resume()
        self.task = task
    }
}
