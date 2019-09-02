//
//  PhotoModel.swift
//  Flickr Digger
//
//  Created by Cubastion on 8/31/19.
//  Copyright © 2019 Cubastion Consulting. All rights reserved.
//

import Foundation

struct ParentModel : Codable {
    let photos : Photos
    let stat : String
}

struct Photos : Codable {
    
    let page : Double
    let pages : Double
    let perpage : Int
    let total : String
    let photo : [PhotoModel]
    
}



struct PhotoModel : Codable {
    let photoId : String
    let ownerId : String
    let secretId : String
    let serverId : String
    let farm : Int
    let title : String
    let isPublic : Int
    let isFriend : Int
    let isFamily : Int
    
    enum CodingKeys: String, CodingKey {
        case photoId = "id"
        case ownerId = "owner"
        case secretId = "secret"
        case serverId = "server"
        case farm
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }
    
    
}
