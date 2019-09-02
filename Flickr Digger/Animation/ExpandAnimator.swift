//
//  ExpandAnimator.swift
//  Flickr Digger
//
//  Created by Ikjot Singh on 9/2/19.
//   .
//

import Foundation
import UIKit


// some short forms used to make variables
// vw = view
// Img = Image
// Ref = Reference

//MARK:- Animator Protocols
protocol ExpandAnimatorDelegate: class {
    func referenceImageViewForAnimation(for zoomAnimator: ExpandAnimator) -> UIImageView?
    func transitionWillBeginWith(ExpandAnimator: ExpandAnimator)
    func transitionDidFinishWith(ExpandAnimator: ExpandAnimator)
    func referenceImageViewFrameInTransitioningView(for ExpandAnimator: ExpandAnimator) -> CGRect?
}
//MARK:- Animator Class
class ExpandAnimator : NSObject {
    // Variables
    var isExpanding : Bool = true
    // is expanding tells whether image is openeing or closing
    
    var transitionImageView : UIImageView?
    // transitionImageView is a temporary view that appear while zooming. This view zoom from small to large and then large to small
    
    // Delegates
    weak var sourceDelegate : ExpandAnimatorDelegate?
    weak var destinationDelegate : ExpandAnimatorDelegate?
    
    // Method called while expanding
    fileprivate func animateExpandTransitionOfViewWith(context: UIViewControllerContextTransitioning){
        let containerView = context.containerView
        // container view is the parent of all in transition animation. All views that appears should be inside transition image view.
        
        guard let destinationVC = context.viewController(forKey: .to),
            let sourceRefImgView = sourceDelegate?.referenceImageViewForAnimation(for: self),
        let destinationRefImgView = destinationDelegate?.referenceImageViewForAnimation(for: self),
            
            let sourceRefImgViewFrame = sourceDelegate?.referenceImageViewFrameInTransitioningView(for: self)
        else {
            return
        }
        
        // call the begin delegates method informing the source and destination that the animation is about to begin
        sourceDelegate?.transitionWillBeginWith(ExpandAnimator: self)
        destinationDelegate?.transitionWillBeginWith(ExpandAnimator: self)
        
        //Hide the destination View
        destinationVC.view.alpha = 0
        // Hide the destination image View
        destinationRefImgView.isHidden = true
        // Hide the source Image View
        destinationRefImgView.isHidden = true
        containerView.addSubview(destinationVC.view)
        let sourceRefImg = sourceRefImgView.image ?? UIImage()
        
        if self.transitionImageView == nil {
            let imgView = UIImageView(image: sourceRefImg)
            imgView.frame = sourceRefImgViewFrame
            imgView.contentMode = .scaleAspectFill
            imgView.clipsToBounds = true
            self.transitionImageView = imgView
            containerView.addSubview(imgView)
        }
        
        // image size of final destination image
        let finalImageSize = getFrameForDestinationImageViewFor(image: sourceRefImg, forDestinationView: destinationVC.view)
        
        // animate the transitionImageView from small to large
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [UIView.AnimationOptions.transitionCrossDissolve], animations: {
            self.transitionImageView?.frame = finalImageSize
            destinationVC.view.alpha = 1
        }) { (finished) in
            // remove transition image view after animation
            self.transitionImageView?.removeFromSuperview()
            // show source and destination image view
            sourceRefImgView.isHidden = false
            destinationRefImgView.isHidden = false
            // empty the transition image view
            self.transitionImageView = nil
        }
        
        context.completeTransition(!context.transitionWasCancelled)
        
        // imform the source and destination that the animation has finished
        sourceDelegate?.transitionDidFinishWith(ExpandAnimator: self)
        destinationDelegate?.transitionDidFinishWith(ExpandAnimator: self)
 
    }
    
    // Method called while contracting
    fileprivate func animateContractTransitionOfViewWith(context: UIViewControllerContextTransitioning){
        let containerView = context.containerView
        // container view is the parent of all in transition animation. All views that appears should be inside transition image view.
        
        guard let destinationVC = context.viewController(forKey: .to),
            let sourceVC = context.viewController(forKey: .from),
            let sourceRefImgView = sourceDelegate?.referenceImageViewForAnimation(for: self),
            let destinationRefImgView = destinationDelegate?.referenceImageViewForAnimation(for: self),
            
            let sourceRefImgViewFrame = sourceDelegate?.referenceImageViewFrameInTransitioningView(for: self),
            let destinationRefImgViewFrame = destinationDelegate?.referenceImageViewFrameInTransitioningView(for: self)
            else {
                return
        }
        
        sourceDelegate?.transitionWillBeginWith(ExpandAnimator: self)
        destinationDelegate?.transitionWillBeginWith(ExpandAnimator: self)
        // Hide the destination image View
        destinationRefImgView.isHidden = true
        
        let sourceRefImg = sourceRefImgView.image ?? UIImage()
        
        if self.transitionImageView == nil {
            let imgView = UIImageView(image: sourceRefImg)
            imgView.contentMode = .scaleAspectFill
            imgView.clipsToBounds = true
            imgView.frame = sourceRefImgViewFrame
            self.transitionImageView = imgView
            containerView.addSubview(imgView)
        }
        containerView.insertSubview(destinationVC.view, belowSubview: sourceVC.view)
        
        let finalTransitionSize = destinationRefImgViewFrame
        
        UIView.animate(withDuration: transitionDuration(using: context),
                       delay: 0,
                       options: [],
                       animations: {
                        sourceVC.view.alpha = 0
                        self.transitionImageView?.frame = finalTransitionSize
        }, completion: { finished in
            
            self.transitionImageView?.removeFromSuperview()
            destinationRefImgView.isHidden = false
            sourceRefImgView.isHidden = false
            
            context.completeTransition(!context.transitionWasCancelled)
            self.destinationDelegate?.transitionDidFinishWith(ExpandAnimator: self)
            self.sourceDelegate?.transitionDidFinishWith(ExpandAnimator: self)
            
        })
    }
    
    private func getFrameForDestinationImageViewFor(image: UIImage, forDestinationView view: UIView) -> CGRect {
        
        return CGRect(x: 0, y: view.frame.origin.y, width: view.frame.width, height: view.frame.height)
        
        // below code can be used when image is not being shown on full screen
        
        /*
        let viewAspectRatio = view.frame.width/view.frame.height
        let imageAspectRatio = image.size.width/image.size.height
        let widthGreater = (imageAspectRatio>viewAspectRatio)

        if widthGreater {
            let newHeight = view.frame.height / imageAspectRatio
            let YCoordinate = view.frame.minY + (view.frame.height-newHeight)/2
            return CGRect(x: 0, y: YCoordinate, width: view.frame.width, height: newHeight)
        }else{
            let newWidth = view.frame.height * imageAspectRatio
            let XCoordinate = view.frame.minX + (view.frame.width - newWidth)/2
            return CGRect(x: 0, y: XCoordinate, width: newWidth, height: view.frame.height)
        }
        */
    }
    
}


extension ExpandAnimator : UIViewControllerAnimatedTransitioning {
    // this method returns the time taken for transition in both case i.e expanding and contracting
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if self.isExpanding {
            return 0.4
        }else{
            return 0.3
        }
    }
    
    // actual delegates method which is called to animate transtion.
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isExpanding {
            animateExpandTransitionOfViewWith(context: transitionContext)
        }else{
            animateContractTransitionOfViewWith(context: transitionContext)
        }
    }
    
    
}
