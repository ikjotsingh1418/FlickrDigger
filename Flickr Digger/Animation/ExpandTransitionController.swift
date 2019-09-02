//
//  ZoomAnimator.swift
//  Flickr Digger
//
//  Created by Ikjot Singh on 9/2/19.
//   .
//

import Foundation
import UIKit


/*
 This class will be the delegate for navigation controller and handeles the push and pop transition incorporating the Expand Animator
 */
class ExpandTransitionController : NSObject {
    // Variables
    
    // variable for animator
    let expandAnimator : ExpandAnimator
    
    // delegates variable
    weak var sourceDelegate : ExpandAnimatorDelegate?
    weak var destinationDelegate : ExpandAnimatorDelegate?
    
    
    override init() {
        expandAnimator = ExpandAnimator()
        super.init()
    }
    
}


extension ExpandTransitionController : UINavigationControllerDelegate {
    
    /*
     This method will be called by navigation controller and has to be implemented by its delegate. It check of "push" or "pop" transition and accordingly set the delegates for the Expand Animator
     */
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            self.expandAnimator.isExpanding = true
            self.expandAnimator.sourceDelegate = sourceDelegate
            self.expandAnimator.destinationDelegate = destinationDelegate
        } else {
            self.expandAnimator.isExpanding = false
            let desDelegate = destinationDelegate
            self.expandAnimator.destinationDelegate = sourceDelegate
            self.expandAnimator.sourceDelegate = desDelegate
        }
        
        return self.expandAnimator
    }
}
