//
//  PhotoDetailViewModel.swift
//  Flickr Digger
//
//  Created by Cubastion on 9/2/19.
//  Copyright © 2019 Cubastion Consulting. All rights reserved.
//

import Foundation
import UIKit

class PhotoDetailViewModel {
 
    var showAlertMessage : (()->())?
    var updateLoadingStatus : (()->())?
    var reloadImage :  (()->())?
    var getImageView : (() -> UIImageView?)?
    var getImageViewFrameInTransitioningView : (() -> CGRect?)?
    
    var transitionController = ExpandTransitionController()
    
    var photo : PhotoCollectionCellViewModel? {
        didSet(value) {
            self.viewIsLoading = true
            self.image = photo?.thumbnailImage
            guard let url = photo?.originalImageUrl else{
                return
            }
            ImageDownloadManager.shared.fetchImageForURL(urlString: url) {[weak self] (image, url, error) in
                self?.viewIsLoading = false
                if let error = error {
                    let errorStr = APIService.getAPIErrorForErrorCode(code: error.code)
                    self?.alertMessage = errorStr.rawValue
                } else {
                    self?.image = image
                }
            }
        }
    }
    
    var image : UIImage? {
        didSet {
            self.reloadImage?()
        }
    }
    
    var viewIsLoading : Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var alertMessage : String? {
        didSet {
            self.showAlertMessage?()
        }
    }
    
}

extension PhotoDetailViewModel : ExpandAnimatorDelegate {
    func referenceImageViewForAnimation(for zoomAnimator: ExpandAnimator) -> UIImageView? {
        return self.getImageView?()
    }
    
    func transitionWillBeginWith(ExpandAnimator: ExpandAnimator) {
        
    }
    
    func transitionDidFinishWith(ExpandAnimator: ExpandAnimator) {
        
    }
    
    func referenceImageViewFrameInTransitioningView(for ExpandAnimator: ExpandAnimator) -> CGRect? {
        return self.getImageViewFrameInTransitioningView?()
    }
    
    
}
