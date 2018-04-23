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
    }
    
    // fetching array of Photo
    class func fetchPhotos(pageNumber: Int, completion: @escaping ([Photo]?, String?) -> ()) {
        
        let url = "\(API.sitePath)/photos/?client_id=\(API.clientId)"
        let parameters: [String: Any] = [
            "per_page": 15,
            "page":     pageNumber
        ]
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { response in
            if let limitLoaders = response.response?.allHeaderFields["x-ratelimit-remaining"] as? String {
                print("x-ratelimit-remaining: \(limitLoaders)") // LOG
            }

            // check for result and return [Photo]? and error(String?)
            switch response.result {
            case .success(let data):
                let photos: [Photo]? = try? JSONDecoder().decode([Photo].self, from: data)
                 
                 var error: String?
                 if photos == nil {
                    let errorInfo = try? JSONDecoder().decode(ErrorData.self, from: data)
                    error = errorInfo?.errors.first ?? "Unknown Error"
                 }
                 completion(photos, error)
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    // fetching PhotoDetails by its id
    class func fetchPhotoDetails(by id: String, completion: @escaping (PhotoDetails?, String?) -> ()) {
        let formatter = ISO8601DateFormatter()
        let customDateHandler: (Decoder) throws -> Date = { decoder in
            let string = try decoder.singleValueContainer().decode(String.self)
            guard let date = formatter.date(from: string) else { return Date() }
            return date
        }
        
        let url = "\(API.sitePath)/photos/\(id)/?client_id=\(API.clientId)"
        
        Alamofire.request(url).responseData { response in
            //print("Response: \(String(describing: response.response))") // http url response
            //print("Result: \(response.result)")                         // response serialization result
            if let limitLoaders = response.response?.allHeaderFields["x-ratelimit-remaining"] as? String {
                print("x-ratelimit-remaining: \(limitLoaders)")
            }
            
            // check for result and return PhotoDetails? and error(String?)
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom(customDateHandler)
                let photoDetails: PhotoDetails? = try? decoder.decode(PhotoDetails.self, from: data)
                
                var error: String?
                if photoDetails == nil {
                    let errorInfo = try? decoder.decode(ErrorData.self, from: data)
                    assert(errorInfo != nil)
                    error = errorInfo?.errors.first ?? "Unknown Error"
                }
                completion(photoDetails, error)
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
}
