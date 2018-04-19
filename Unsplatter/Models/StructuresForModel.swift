//
//  StructuresForModel.swift
//  Unsplatter
//
//  Created by Anastasia on 4/19/18.
//  Copyright © 2018 Anastasia. All rights reserved.


//  structures:
//  - Urls
//  - User
//  - ProfileImage
//  - Links
//  - Location
//  - Position


import UIKit

struct Urls: Codable {
    let raw:     String
    let full:    String
    let regular: String
    let small:   String
    let thumb:   String
    
    enum CodingKeys: String, CodingKey {
        case raw
        case full
        case regular
        case small
        case thumb
    }
    
    init(raw: String, full: String, regular: String, small: String, thumb: String) {
        self.raw     = raw
        self.full    = full
        self.regular = regular
        self.small   = small
        self.thumb   = thumb
    }
}

struct User: Codable {
    let name:         String
    let username:     String
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case name
        case username
        case profileImage = "profile_image"
    }
    
    init(name: String, username: String, profileImage: ProfileImage) {
        self.name         = name
        self.username     = username
        self.profileImage = profileImage
    }
}

struct ProfileImage: Codable {
    let small:  String
    let medium: String
    let large:  String

    
    enum CodingKeys: String, CodingKey {
        case small
        case medium
        case large
    }
    
    init(small: String, medium: String, large: String) {
        self.small  = small
        self.medium = medium
        self.large  = large
    }
}

struct Links: Codable {
    let download: String
    
    enum CodingKeys: String, CodingKey {
        case download
    }
    
    init(download: String) {
        self.download = download
    }
}

struct Location: Codable {
    let title: String
    let position: Position
    
    enum CodingKeys: String, CodingKey {
        case title
        case position
    }
    
    init(title: String, position: Position) {
        self.title = title
        self.position = position
    }
}

struct Position: Codable {
    let latitude: CGFloat
    let longitude: CGFloat
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    init(latitude: CGFloat, longitude: CGFloat) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
