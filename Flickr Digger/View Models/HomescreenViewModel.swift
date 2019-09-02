//
//  PhotoCollectionCellViewModel.swift
//  Flickr Digger
//
//  Created by Ikjot Singh on 8/31/19.
//   .
//

import Foundation
import UIKit

class PhotoCollectionCellViewModel {
    var thumbnailImage : UIImage?
    let thumbnailImageUrl : String
    let originalImageUrl : String
    let name : String
    
    // Dependency Injection
    init(photoModel : PhotoModel) {
        let urlString = String(format: "https://farm%d.staticflickr.com/%@/%@_%@", photoModel.farm,photoModel.serverId,photoModel.photoId,photoModel.secretId)
        thumbnailImageUrl = urlString + "_t.jpg"
        originalImageUrl = urlString + ".jpg"
        name = photoModel.title
    }
}

class HomescreenViewModel {
    
    
    let service : APIServiceProtocol
    
    //MARK:- Weakely called property on view
    var reloadCollectionViewClosure : (()->())?
    var updateLoadingStatus : (()->())?
    var showAlertMessage : (()->())?
    
    var pushNewViewController : (()->())?
    var setNavigationDelegate : (()->())?
    
    var getImageView : (() -> UIImageView?)?
    var getImageViewFrameInTransitioningView : (() -> CGRect?)?
    
    //MARK:- Variables
    var fetchedDetailModel : Photos?
    var latestPage : Double = 1
    var currentSearchTerm : String?
    var selectedIndexPath : IndexPath?
    
    private var cellViewModels : [PhotoCollectionCellViewModel] = [PhotoCollectionCellViewModel]() {
        didSet {
            self.reloadCollectionViewClosure?()
        }
    }
  
    var itemsInRow : Int {
        get {
            if let val = UserDefaults.standard.value(forKey: "itemsInRow") as? Int{
                return val
            }else{
                return 3
            }
        }
        set(val) {
            UserDefaults.standard.setValue(val, forKey: "itemsInRow")
           self.reloadCollectionViewClosure?()
        }
    }
    
    var numberOfItems : Int {
        return cellViewModels.count
    }
    
    var islastPage : Bool = false {
        didSet {
            self.reloadCollectionViewClosure?()
        }
    }
    
    var pushViewController : PhotoDetailViewController? {
        didSet{
           self.pushNewViewController?()
        }
    }
    
    var isCVLoadingMoreItems : Bool = false
    
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
    
    var navigationDelegate : ExpandTransitionController? {
        didSet {
            self.setNavigationDelegate?()
        }
    }
    
    //MARK:- Methods
    init(apiService : APIServiceProtocol = APIService() ) {
        self.service = apiService
        
    }
    
    func getPhotoViewModelAtIndexPath(indexPath : IndexPath) -> PhotoCollectionCellViewModel? {
        if cellViewModels.count > indexPath.row{
            return cellViewModels[indexPath.row]
        }else{
            return nil
        }
    }
    
    func loadNextPage() {
        guard let searchStr = currentSearchTerm else{
            return
        }
        if  latestPage != fetchedDetailModel?.pages {
            self.isCVLoadingMoreItems = true
            fetchPhotosForKeyword(keyword: searchStr, forPage: latestPage+1)
        }else{
            islastPage = true
        }
        
    }
    
    func pushDetailViewControllerForIndex(index:IndexPath){
        selectedIndexPath = index
        let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "photoDetail") as! PhotoDetailViewController
        if  cellViewModels.count > index.row {
            detailVC.photoModel = cellViewModels[index.row]
        }
        detailVC.viewModel.transitionController.sourceDelegate = self
        detailVC.viewModel.transitionController.destinationDelegate = detailVC.viewModel
        self.navigationDelegate = detailVC.viewModel.transitionController
        self.pushViewController = detailVC
    }
    
    func fetchPhotosForKeyword(keyword:String){
        self.viewIsLoading = true
        islastPage = false
        cellViewModels.removeAll()
        fetchPhotosForKeyword(keyword: keyword, forPage:1)
    }
    
    
    func fetchPhotosForKeyword(keyword:String, forPage page: Double){
        currentSearchTerm = keyword
        latestPage = page
        service.fetchPhotosForSearchKeyword(keyword: keyword, forPage: page) { [weak self] (success, photos, error) in
            self?.isCVLoadingMoreItems = false
            if let error = error {
                self?.islastPage = true
                self?.alertMessage = error.rawValue
            } else {
                if photos?.pages == self?.latestPage {
                    self?.islastPage = true
                }
                if photos?.pages == 0 {
                    self?.islastPage = true
                    self?.alertMessage = "No results found"
                }
                self?.fetchedDetailModel = photos
                if let array =  photos?.photo {
                self?.processFetchedPhotos(arrPhotos:array)
                }else{
                   self?.islastPage = true
                   self?.alertMessage = "Some unexpected error Occured"
                }
            }
            self?.viewIsLoading = false
            
        }
    }
    
    
    func processFetchedPhotos(arrPhotos: [PhotoModel]) {
        let newPhotoArray  = arrPhotos.map({ (photo) -> PhotoCollectionCellViewModel in
            return PhotoCollectionCellViewModel(photoModel: photo)
        })
        self.cellViewModels += newPhotoArray
    }
    
    
}

// MARK:- Animator Delegate Methods
extension HomescreenViewModel : ExpandAnimatorDelegate {
    func transitionWillBeginWith(ExpandAnimator: ExpandAnimator) {
        
    }
    func referenceImageViewForAnimation(for zoomAnimator: ExpandAnimator) -> UIImageView? {
        return self.getImageView?()
    }
    
    
    func transitionDidFinishWith(ExpandAnimator: ExpandAnimator) {
        
    }
    
    func referenceImageViewFrameInTransitioningView(for ExpandAnimator: ExpandAnimator) -> CGRect? {
       return  self.getImageViewFrameInTransitioningView?()
    }
    
    
}



