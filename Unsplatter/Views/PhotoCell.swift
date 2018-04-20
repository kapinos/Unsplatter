//
//  PhotoCell.swift
//  Unsplatter
//
//  Created by Anastasia on 4/18/18.
//  Copyright © 2018 Anastasia. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoIdLabel: UILabel!
 
    var image: UIImage? {
        get {
            return photoImageView.image
        }
    }

    func render(photo: Photo) {        
        guard let url = URL(string: photo.urls.thumb) else { return }
        
        downloadAndSetPhotoIntoCell(from: url)
        photoIdLabel.text = photo.id
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func downloadAndSetPhotoIntoCell(from url: URL) {
        Alamofire.request(url).responseImage { response in
            guard let image = response.result.value else { return }
            DispatchQueue.main.async {
                self.photoImageView.image = image
            }
        }
    }
}
