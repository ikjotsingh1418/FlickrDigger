//
//  ViewController.swift
//  Flickr Digger
//
//  Created by Ikjot Singh on 8/31/19.
//   .
//

import UIKit

class HomeViewController: UIViewController {
    // MARK:- Variables
    // outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // view model is lazily instantiated
    lazy var viewModel: HomescreenViewModel = {
        return HomescreenViewModel()
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModel()
        setupNavigationBar()
        setupCollectionView()
        // Do any additional setup after loading the view.
    }
    
    func showAlert( _ message: String ) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK:- Collection View setup
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName:"PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:constants.homescreen.photoCellId)
        collectionView.register(UINib(nibName: "FooterLoadingView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "HeaderView")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = constants.homescreen.gridHorizontalSpacing
        flowLayout.minimumInteritemSpacing = constants.homescreen.gridVerticalSpacing
        
    }
    
    // MARK:- Navigation Bar Setup
    func setupNavigationBar() {
        
        // search bar is enabled in navigation bar and right button is added with target.
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        self.navigationItem.titleView = searchController.searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "filter").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(filterButtonTapped(sender:)))
        
        
        
    }
    
    @objc func filterButtonTapped(sender : UIBarButtonItem) {
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Items In a row", preferredStyle: .actionSheet)
        
        let action2 = UIAlertAction(title: "2", style: .default) { _ in
            self.viewModel.itemsInRow = 2
        }
        let action3 = UIAlertAction(title: "3", style: .default) { _ in
            self.viewModel.itemsInRow = 3
        }
        let action4 = UIAlertAction(title: "4", style: .default) { _ in
            self.viewModel.itemsInRow = 4
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(action2)
        optionMenu.addAction(action3)
        optionMenu.addAction(action4)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    // MARK:- View Model Setup
    func setupViewModel() {
        viewModel.reloadCollectionViewClosure = { [weak self]() in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
            
        }
        viewModel.updateLoadingStatus = { [weak self]() in
            
            let isLoading = self?.viewModel.viewIsLoading ?? false
            DispatchQueue.main.async {
                if isLoading {
                    self?.collectionView.isHidden = true
                    self?.activityIndicator.isHidden = false
                    self?.activityIndicator.startAnimating()
                }else{
                    self?.collectionView.isHidden = false
                    self?.activityIndicator.isHidden = true
                    self?.activityIndicator.stopAnimating()
                }
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
        viewModel.pushNewViewController = { [weak self]() in
            DispatchQueue.main.async {
                if let newVC = self?.viewModel.pushViewController {
                    self?.navigationController?.pushViewController(newVC, animated: true)
                }
            }
            
        }
        viewModel.setNavigationDelegate = { [weak self]() in
            DispatchQueue.main.async {
                self?.navigationController?.delegate = self?.viewModel.navigationDelegate
            }
        }
        viewModel.getImageView  = { [weak self]()->UIImageView? in
            if let index = self?.viewModel.selectedIndexPath, let cell = self?.collectionView.cellForItem(at: index ) as? PhotoCollectionViewCell {
            return cell.imageView
            }else {
                return nil
            }
        }
        viewModel.getImageViewFrameInTransitioningView = { [weak self]()->CGRect? in
            
            guard let index = self?.viewModel.selectedIndexPath else {
                return nil
            }
            let cell = self?.collectionView.cellForItem(at: index) as! PhotoCollectionViewCell
            guard let cellFrame = self?.collectionView.convert(cell.frame, to: self?.view) else{
                return nil
            }
            
            guard let cvTop  = self?.collectionView.contentInset.top else {
                return nil
            }
            if cellFrame.minY < cvTop {
                return CGRect(x: cellFrame.minX, y: cvTop, width: cellFrame.width, height: cellFrame.height - (cvTop - cellFrame.minY))
            }
            
            return cellFrame
        }
  
        viewModel.fetchPhotosForKeyword(keyword: "height")
    }
    
    
   
    
    
    
}


// MARK:- Collection View Delegate and Datasource

extension HomeViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: constants.homescreen.photoCellId, for: indexPath) as? PhotoCollectionViewCell else {
            fatalError("Cell does not exist")
        }
     
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if !viewModel.islastPage {
            return CGSize(width: collectionView.bounds.width, height: constants.homescreen.footerLoadingHeight)
        }else{
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "HeaderView", for: indexPath)
            
            return footerView
        }
        return UICollectionReusableView()
    }
    
    
    
    
    
}

extension HomeViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cellModel = viewModel.getPhotoViewModelAtIndexPath(indexPath: indexPath)else{
            return
        }
        guard let photoCell = cell as? PhotoCollectionViewCell else{
            return
        }
        photoCell.imageView.image = UIImage(named: "thumbnail")
        
        ImageDownloadManager.shared.fetchImageForURL(urlString: cellModel.thumbnailImageUrl) { (image, url, error) in
            DispatchQueue.main.async {
                let errorImg =  UIImage(named: "error")
                if url == cellModel.thumbnailImageUrl,error == nil {
                    cellModel.thumbnailImage = image
                    photoCell.imageView.image = image  ?? errorImg
                }else{
                    cellModel.thumbnailImage =  errorImg
                    photoCell.imageView.image =  errorImg
                    
                }
                photoCell.imageView.contentMode = .scaleAspectFill
            }
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cellModel = viewModel.getPhotoViewModelAtIndexPath(indexPath: indexPath){
            ImageDownloadManager.shared.reducePriorityForDisappearingCellsWithUrl(urlString:cellModel.thumbnailImageUrl)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // current offset vertical point y coordinate
        if !viewModel.isCVLoadingMoreItems {
            let cvOffsetH = collectionView.contentOffset.y
            // height of content of collection view
            let contentSizeH = collectionView.contentSize.height
            let cvH = collectionView.frame.size.height
            let const = cvOffsetH+cvH+constants.homescreen.footerLoadingHeight
            if  const > contentSizeH {
                viewModel.loadNextPage()
            }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.pushDetailViewControllerForIndex(index: indexPath)
    }
}


// MARK:- Collection view flow layout delegate

extension HomeViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cvWidth  = self.collectionView.frame.size.width
        let spacing = constants.homescreen.gridHorizontalSpacing
        let rowItems = CGFloat(viewModel.itemsInRow)
        
        let widthForSpacing = (rowItems-1)*spacing
        
        let cellWidth = (cvWidth - widthForSpacing)/rowItems
        
        return CGSize(width: cellWidth, height: cellWidth)
        
        
    }
    
}

// MARK:- Search Bar Delegates
extension HomeViewController : UISearchBarDelegate  {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(true, animated: false)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(false, animated: false)
        searchBar.resignFirstResponder()
        guard let term = searchBar.text , term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            self.showAlert("Please enter a search keyword")
            return
        }
        self.viewModel.fetchPhotosForKeyword(keyword:term)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(false, animated: false)
        searchBar.text = String()
        searchBar.resignFirstResponder()

    }
}
