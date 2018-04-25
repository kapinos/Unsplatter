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
 
    var image: UIImage? {
        get {
            return photoImageView.image
        }
    }

    func render(photo: Photo) {        
        guard let urls = photo.urls,
            let thumb = urls.thumb,
            let url = URL(string: thumb) else { return }
        
        downloadAndSetPhoto(from: url)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }
    
    private func downloadAndSetPhoto(from url: URL) {
        Alamofire.request(url).responseImage { response in
            guard let image = response.result.value else { return }
            DispatchQueue.main.async {
                self.photoImageView.image = image
            }
        }
    }
}
