//
//  Constants.swift
//  Flickr Digger
//
//  Created by Cubastion on 8/31/19.
//  Copyright © 2019 Cubastion Consulting. All rights reserved.
//

import Foundation
import UIKit
struct constants {
    
    
    
    struct APIDetails {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        // parameters
        static let FlickerAPIKey = "6466935fc93912d71f5d40444c283cc9"
        static let FlickerAPIMethod = "flickr.photos.search"
        static let PhotosPerRequest = "40"
        
    }
    
    static let FlickerSearchPhotoAPI = "https://api.flickr.com/services/rest"
    
    struct homescreen {
        static let gridHorizontalSpacing : CGFloat = 10
        static let gridVerticalSpacing : CGFloat = 10
        static let footerLoadingHeight : CGFloat = 140
        static let photoCellId = "PhotosCellIdentifier"
        
    }
    
    
}

