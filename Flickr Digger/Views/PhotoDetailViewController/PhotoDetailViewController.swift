//
//  ViewController.swift
//  Flickr Digger
//
//  Created by Ikjot Singh on 9/2/19.
//   .
//

import UIKit

class PhotoDetailViewController: UIViewController {

    // outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!

    // photo model is passed by the intializing class
    var photoModel : PhotoCollectionCellViewModel?
    
    // view model is lazily instantiated
    lazy var viewModel: PhotoDetailViewModel = {
        return PhotoDetailViewModel()
    }()
    
    // MARK:- Methods
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
    
    func showAlert( _ message: String ) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK:- View Model Setup
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

    
    
    
}
