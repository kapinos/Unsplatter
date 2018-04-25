//
//  PhotosByWord.swift
//  Unsplatter
//
//  Created by Anastasia on 4/24/18.
//  Copyright © 2018 Anastasia. All rights reserved.
//

import Foundation

class PhotosByWord: NSObject, Codable {
    let totalResults: Int?
    let totalPages:   Int?
    let photos:       [Photo]?

    enum CodingKeys: String, CodingKey {
        case totalResults = "total"
        case totalPages   = "total_pages"
        case photos       = "results"
    }
    
    init(totalResults: Int, totalPages: Int, photos: [Photo]) {
        self.totalResults = totalResults
        self.totalPages   = totalPages
        self.photos       = photos
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalResults = try container.decodeIfPresent(Int.self, forKey: .totalResults)
        totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages)
        photos = try container.decodeIfPresent([Photo].self, forKey: .photos)
    }
}
