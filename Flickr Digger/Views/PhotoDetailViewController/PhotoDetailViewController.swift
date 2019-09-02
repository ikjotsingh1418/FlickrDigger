//
//  ViewController.swift
//  Flickr Digger
//
//  Created by Cubastion on 9/2/19.
//  Copyright © 2019 Cubastion Consulting. All rights reserved.
//

import UIKit

//protocol PhotoDetailViewControllerDelegate : NSObject {
//    func getPhotoModel() -> PhotoCollectionCellViewModel
//}

class PhotoDetailViewController: UIViewController {

    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
   // weak var delegate : PhotoDetailViewControllerDelegate?
    
    
    var photoModel : PhotoCollectionCellViewModel?
    
    lazy var viewModel: PhotoDetailViewModel = {
        return PhotoDetailViewModel()
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.stopAnimating()
        self.setupViewModel()
        self.viewModel.photo = photoModel
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnTap = false
    }
    
    func setupViewModel() {
        viewModel.reloadImage = { [weak self]() in
            DispatchQueue.main.async {
                self?.imageView.image = self?.viewModel.image
                self?.imageView.contentMode = .scaleAspectFill
            }
        }
        
        viewModel.updateLoadingStatus = { [weak self]() in
            let isLoading = self?.viewModel.viewIsLoading ?? false
            DispatchQueue.main.async {
                if isLoading {
                    self?.activityIndicator.isHidden = false
                    self?.activityIndicator.startAnimating()
                }else{
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
        
        viewModel.getImageView  = { [weak self]() -> UIImageView? in
           return self?.imageView
        }
        
        viewModel.getImageViewFrameInTransitioningView = { [weak self]()->CGRect? in
            if let rect = self?.imageView.frame {
               return self?.view.convert(rect, to: self?.view)
            }else{
                return nil
            }
        }
        
        viewModel.showAlertMessage = { [weak self]() in
            if let message = self?.viewModel.alertMessage {
                DispatchQueue.main.async {
                    self?.showAlert( message )
                    self?.activityIndicator.stopAnimating()
                }
                
            }
        }
        
    }

    func showAlert( _ message: String ) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
