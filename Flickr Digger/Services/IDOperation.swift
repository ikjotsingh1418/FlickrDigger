//
//  IDOperation.swift
//  Flickr Digger
//
//  Created by Ikjot Singh on 9/2/19.
//   .
//

import Foundation 
import UIKit

class IDOperation: Operation {
    
    // MARK:- Variables
    var downloadHandler : ImageDownloadClosure?
    var imageUrl: URL!
    var image : UIImage?
    
    private var downloadTask : URLSessionDownloadTask?
    override var isAsynchronous: Bool {
        get {
            return  true
        }
    }
    
    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    func executing(_ executing: Bool) {
        _executing = executing
    }
    
    func finish(_ finished: Bool) {
        _finished = finished
    }
    
    // MARK:- Main
    required init (url: URL) {
        self.imageUrl = url
    }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        self.executing(true)
        //Asynchronous logic (eg: n/w calls) with callback
        self.downloadImageFromUrl()
    }
    
    // MARK:- Set Priority Functions
    func setLowPriority (){
        downloadTask?.priority = 0
        queuePriority = .veryLow
    }
    
    func setMediumPriority() {
        downloadTask?.priority = 0.7
         queuePriority = .normal
    }
    
    func setHighPriority() {

        downloadTask?.priority = 1
         queuePriority = .veryHigh
    }
    
    func downloadImageFromUrl() {
        let newSession = URLSession.shared
         downloadTask = newSession.downloadTask(with: self.imageUrl) { (path, response, error) in
            if let pathUrl = path, let data = try? Data(contentsOf: pathUrl){
                 self.image = UIImage(data: data)
                self.downloadHandler?(self.image,self.imageUrl.absoluteString,error)
            }else{
                self.downloadHandler?(nil,self.imageUrl.absoluteString,error)
            }
            self.finish(true)
            self.executing(false)
        }
        downloadTask?.resume()
    }
    
    
}
