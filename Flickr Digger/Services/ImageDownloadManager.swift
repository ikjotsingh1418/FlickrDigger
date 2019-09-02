//
//  ImageDownloadManager.swift
//  Flickr Digger
//
//  Created by Cubastion on 9/2/19.
//  Copyright © 2019 Cubastion Consulting. All rights reserved.
//

import Foundation
import UIKit

typealias ImageDownloadClosure = (_ image: UIImage?, _ url: String, _ error: Error?) -> Void

final class ImageDownloadManager : NSObject {

    static let shared = ImageDownloadManager()
    
    private lazy var downloadsInProgress: [String: IDOperation] = [:]
    private let imageCache = NSCache<NSString, AnyObject>()
    
    //private var completionHandler: ImageDownloadClosure?
    private lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.flicker.DownloadQueue"
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    func fetchImageForURL (urlString: String , completion : @escaping ImageDownloadClosure) {
        guard let url = URL(string: urlString) else { return }
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) as? UIImage {
            OperationQueue.main.addOperation {
                completion(imageFromCache,urlString,nil)
            }
            return
        }
        guard downloadsInProgress[urlString] == nil else {
            let fetchOp = downloadsInProgress[urlString]
            fetchOp?.downloadHandler = completion
            fetchOp?.setHighPriority()
            return
        }
        
        let fetchOperation = IDOperation(url: url)
        fetchOperation.downloadHandler = completion
        fetchOperation.setMediumPriority()
        fetchOperation.completionBlock = {
            if fetchOperation.isCancelled{
                return
            }
            if let img = fetchOperation.image {
                self.imageCache.setObject(img, forKey: fetchOperation.imageUrl.absoluteString as NSString)
            }
            DispatchQueue.main.async {
                self.downloadsInProgress.removeValue(forKey: fetchOperation.imageUrl.absoluteString)
            }
        }
        downloadsInProgress[urlString] = fetchOperation
        downloadQueue.addOperation(fetchOperation)
        
    }
    
    func reducePriorityForDisappearingCellsWithUrl(urlString : String){
        guard downloadsInProgress[urlString] != nil else {
            return
        }
            let fetchOp = downloadsInProgress[urlString]
            fetchOp?.setLowPriority()
            fetchOp?.downloadHandler = nil
            return
    }
    
   

}
