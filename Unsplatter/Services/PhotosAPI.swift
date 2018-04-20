//
//  PhotosAPI.swift
//  Unsplatter
//
//  Created by Anastasia on 4/18/18.
//  Copyright © 2018 Anastasia. All rights reserved.
//

import Foundation
import Alamofire

class PhotosAPI: NSObject {
    
    private enum API {
        static let sitePath = "https://api.unsplash.com"
        static let clientId = "7e63407b21e8a266d64e554fec19f205138b5a03bf2357e6d719315e12018f70"
        
        case photos
        case photoDetails
        
        func fetch(path: String, completion: @escaping (Data) -> ()) {
            let session = URLSession(configuration: .default)
            guard let url = URL(string: path) else { return }
            
            let task = session.dataTask(with: url) { (data, response, error) in
                guard let data = data, error == nil else { return }
                completion(data)
            }
            task.resume()
        }
    }
    
    class func fetchPhotos(completion: @escaping ([Photo]?) -> ()) {

        var photos: [Photo]?
        
        let url = "\(API.sitePath)/photos/?client_id=\(API.clientId)"
        let parameters: [String: Any] = [
            "per_page": 30
        ]
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            // FIXME: - Handle 'Result'
            
            // FIXME: - Get 'x-ratelimit-limit' from Headers
            if let headers = response.response?.allHeaderFields {
                print("headers: \(headers)")
            }
            
            if let data = response.data {
                photos = try? JSONDecoder().decode([Photo].self, from: data)
                completion(photos)
            }
        }
    }
    
    // FIXME: - Rewrite to Alamofire
    class func fetchDetailsPhoto(by id: String, completion: @escaping (PhotoDetails?) -> ()) {
        let formatter = ISO8601DateFormatter()
        let customDateHandler: (Decoder) throws -> Date = { decoder in
            let string = try decoder.singleValueContainer().decode(String.self)
            guard let date = formatter.date(from: string) else { return Date() }
            return date
        }
        
        let url = "\(API.sitePath)/photos/\(id)/?client_id=\(API.clientId)"
        var photoDetails: PhotoDetails?
        API.photoDetails.fetch(path: url) { data in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom(customDateHandler)
            photoDetails = try? decoder.decode(PhotoDetails.self, from: data)
            completion(photoDetails)
        }
    }
}
