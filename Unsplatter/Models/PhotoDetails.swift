//
//  PhotoDetails.swift
//  Unsplatter
//
//  Created by Anastasia on 4/19/18.
//  Copyright © 2018 Anastasia. All rights reserved.
//

import UIKit

class PhotoDetails: NSObject, Codable {
    let id:         String
    let created:    Date?
    let author:     User
    let urls:       Urls
    let links:      Links
    let likesCount: Int
    let location:   Location?
    
    enum CodingKeys: String, CodingKey {
        case id
        case created = "created_at"
        case author = "user"
        case urls
        case links
        case likesCount = "likes"
        case location
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        created = try container.decodeIfPresent(Date.self, forKey: .created)
        author = try container.decode(User.self, forKey: .author)
        urls = try container.decode(Urls.self, forKey: .urls)
        links = try container.decode(Links.self, forKey: .links)
        likesCount = try container.decode(Int.self, forKey: .likesCount)
        location = try container.decodeIfPresent(Location.self, forKey: .location)
    }
    
    init(id: String, created: Date, author: User, urls: Urls, links: Links, likesCount: Int, location: Location) {
        self.id         = id
        self.created    = created
        self.author     = author
        self.urls       = urls
        self.links      = links
        self.likesCount = likesCount
        self.location   = location
    }
}




