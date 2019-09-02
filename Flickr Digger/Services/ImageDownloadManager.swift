//
//  ImageDownloadManager.swift
//  Flickr Digger
//
//  Created by Ikjot Singh on 9/2/19.
//   .
//

import Foundation
import UIKit

typealias ImageDownloadClosure = (_ image: UIImage?, _ url: String, _ error: Error?) -> Void

final class ImageDownloadManager : NSObject {

    // shared static variable for singleton creation
    static let shared = ImageDownloadManager()

    // MARK:- Variables
    private lazy var downloadsInProgress: [String: IDOperation] = [:]
    private let imageCache = NSCache<NSString, AnyObject>()
    private lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.flicker.DownloadQueue"
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    // MARK:- Network Call
    
    func fetchImageForURL (urlString: String , completion : @escaping ImageDownloadClosure) {
        guard let url = URL(string: urlString) else { return }
        
        // if images are present in Cache then they are returned immediately.
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) as? UIImage {
            OperationQueue.main.addOperation {
                completion(imageFromCache,urlString,nil)
            }
            return
        }
        // if not present in cache then the downloadInProgress Array is checked, if present , its priority is increased
        guard downloadsInProgress[urlString] == nil else {
            let fetchOp = downloadsInProgress[urlString]
            fetchOp?.downloadHandler = completion
            fetchOp?.setHighPriority()
            return
        }
        // if not present then a new operation is created and added to the the lists
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
    
    
    /*called then cells are no longer displayed on the screen, this reduces the priority of those images and helps to increase the speed of those images which are still being asked by the screen.
     */
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
