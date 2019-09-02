//
//  UIImageViewExtension.swift
//  Flickr Digger
//
//  Created by Cubastion on 8/31/19.
//  Copyright © 2019 Cubastion Consulting. All rights reserved.
//

import Foundation
import UIKit


let imageCache = NSCache<NSString, AnyObject>()

class URLImageView: UIImageView {
    
    var imageUrlString: String?
    var task : URLSessionDataTask?
    
    func reducePriorityOfTask() {
        if task != nil {
            task?.priority = 0.2
        }
    }
    
    func loadImageUsingUrlString(urlString: String) {
        self.contentMode = .scaleAspectFill
        imageUrlString = urlString
        guard let url = URL(string: urlString) else { return }
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = imageFromCache
            return
        }
        
       
        
      task =  URLSession.shared.dataTask(with: url) { (data, response, error) in
        
            if error != nil {
                print(error!)
                return
            }
            
            guard data != nil else { return }
            
            DispatchQueue.main.async {
                
                let imageToCache = UIImage(data: data!)
                if self.imageUrlString == urlString {
                    self.image = imageToCache
                    self.contentMode = .scaleAspectFill
                }
                imageCache.setObject(imageToCache!, forKey: urlString as NSString)
            }
        }
        task?.priority = 1
        task?.resume()
    }
}

