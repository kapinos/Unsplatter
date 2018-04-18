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
    let urls:   URLS
    let width:  CGFloat
    let height: CGFloat

    enum CodingKeys: String, CodingKey {
        case id
        case urls
        case width
        case height
    }
    
    init(id: String, urls: URLS, width: CGFloat, height: CGFloat) {
        self.id     = id
        self.urls   = urls
        self.width  = width
        self.height = height
    }
}

class URLS: NSObject, Codable {
    let regular: String
    let thumb:   String
    let small:   String
    
    enum CodingKeys: String, CodingKey {
        case regular
        case thumb
        case small
    }
    
    init(regular: String, thumb: String, small: String) {
        self.regular = regular
        self.thumb   = thumb
        self.small   = small
    }
}
