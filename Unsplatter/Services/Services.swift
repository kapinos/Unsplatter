//
//  Services.swift
//  Unsplatter
//
//  Created by Anastasia on 4/18/18.
//  Copyright © 2018 Anastasia. All rights reserved.
//

import Foundation

class PhotosAPI: NSObject {
    
    static let service = PhotosAPI()

    private enum API {
        static let path     = "https://api.unsplash.com"
        static let clientId = "7e63407b21e8a266d64e554fec19f205138b5a03bf2357e6d719315e12018f70"
        static let basePath = "\(path)/photos/?client_id=\(clientId)"
        
        case photos
        
        func fetch(completion: @escaping (Data) -> ()) {
            let session = URLSession(configuration: .default)
            guard let url = URL(string: PhotosAPI.API.basePath) else { return }
            
            let task = session.dataTask(with: url) { (data, response, error) in
                guard let data = data, error == nil else { return }
                completion(data)
            }
            task.resume()
        }
    }
    
    @objc dynamic private(set) var photos: [Photo] = []
    
    func fetchPhotos() {
        API.photos.fetch { data in
            do {
                self.photos = try! JSONDecoder().decode([Photo].self, from: data)
            } catch {
                print("failed to convert: \(error.localizedDescription)")
            }
        }
    }
}
