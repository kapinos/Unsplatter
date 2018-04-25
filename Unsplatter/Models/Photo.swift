//
//  Photo.swift
//  Unsplatter
//
//  Created by Anastasia on 4/18/18.
//  Copyright © 2018 Anastasia. All rights reserved.
//

import UIKit

class Photo: NSObject, Codable {
    let id:     String
    let urls:   Urls?
    let width:  CGFloat?
    let height: CGFloat?

    enum CodingKeys: String, CodingKey {
        case id
        case urls
        case width
        case height
    }

    init(id: String, urls: Urls, width: CGFloat, height: CGFloat) {
        self.id     = id
        self.urls   = urls
        self.width  = width
        self.height = height
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        urls = try container.decodeIfPresent(Urls.self, forKey: .urls)
        width = try container.decodeIfPresent(CGFloat.self, forKey: .width)
        height = try container.decodeIfPresent(CGFloat.self, forKey: .height)
    }
}
