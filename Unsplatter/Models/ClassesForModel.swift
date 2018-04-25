//
//  ClassesForModel.swift
//  Unsplatter
//
//  Created by Anastasia on 4/19/18.
//  Copyright © 2018 Anastasia. All rights reserved.


//  classes:
//  - Urls
//  - User
//  - ProfileImage
//  - Links
//  - Location
//  - Position


import UIKit

class Urls: Codable {
    let raw:     String?
    let full:    String?
    let regular: String?
    let small:   String?
    let thumb:   String?
    
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
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        raw = try container.decodeIfPresent(String.self, forKey: .raw)
        full = try container.decodeIfPresent(String.self, forKey: .full)
        regular = try container.decodeIfPresent(String.self, forKey: .regular)
        small = try container.decodeIfPresent(String.self, forKey: .small)
        thumb = try container.decodeIfPresent(String.self, forKey: .thumb)
    }
}

class User: Codable {
    let name:         String?
    let profileName:  String?
    let profileImage: ProfileImage?
    
    enum CodingKeys: String, CodingKey {
        case name
        case profileName  = "username"
        case profileImage = "profile_image"
    }
    
    init(name: String, profileName: String, profileImage: ProfileImage) {
        self.name         = name
        self.profileName  = profileName
        self.profileImage = profileImage
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        profileName = try container.decodeIfPresent(String.self, forKey: .profileName)
        profileImage = try container.decodeIfPresent(ProfileImage.self, forKey: .profileImage)
    }
}

class ProfileImage: Codable {
    let small:  String?
    let medium: String?
    let large:  String?

    
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
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        small = try container.decodeIfPresent(String.self, forKey: .small)
        medium = try container.decodeIfPresent(String.self, forKey: .medium)
        large = try container.decodeIfPresent(String.self, forKey: .large)
    }
}

class Links: Codable {
    let download: String?
    
    enum CodingKeys: String, CodingKey {
        case download
    }
    
    init(download: String) {
        self.download = download
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        download = try container.decodeIfPresent(String.self, forKey: .download)
    }
}

class Location: Codable {
    let title: String?
    let city: String?
    let country: String?
    let position: Position?
    
    enum CodingKeys: String, CodingKey {
        case title
        case city
        case country
        case position
    }
    
    init(title: String, city: String, country: String, position: Position) {
        self.title    = title
        self.city     = city
        self.country  = country
        self.position = position
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        position = try container.decodeIfPresent(Position.self, forKey: .position)
    }
}

class Position: Codable {
    let latitude: CGFloat?
    let longitude: CGFloat?
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    init(latitude: CGFloat, longitude: CGFloat) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try container.decodeIfPresent(CGFloat.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(CGFloat.self, forKey: .longitude)
    }
}

class ErrorData: Codable {
    let errors: [String]
    
    enum CodingKeys: String, CodingKey {
        case errors
    }
    
    init(errors: [String]) {
        self.errors = errors
    }
}
