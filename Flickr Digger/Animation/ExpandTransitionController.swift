//
//  ZoomAnimator.swift
//  Flickr Digger
//
//  Created by Cubastion on 9/2/19.
//  Copyright © 2019 Cubastion Consulting. All rights reserved.
//

import Foundation
import UIKit
class ExpandTransitionController : NSObject {
    let expandAnimator : ExpandAnimator
    
    weak var sourceDelegate : ExpandAnimatorDelegate?
    weak var destinationDelegate : ExpandAnimatorDelegate?
    
    override init() {
        expandAnimator = ExpandAnimator()
        super.init()
    }
    
}

extension ExpandTransitionController : UIViewControllerTransitioningDelegate{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.expandAnimator.isExpanding = true
        self.expandAnimator.sourceDelegate = sourceDelegate
        self.expandAnimator.destinationDelegate = destinationDelegate
        return self.expandAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.expandAnimator.isExpanding = false
        let desDelegate = destinationDelegate
        self.expandAnimator.destinationDelegate = sourceDelegate
        self.expandAnimator.sourceDelegate = desDelegate
        return self.expandAnimator
    }
    
}

extension ExpandTransitionController : UINavigationControllerDelegate {
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
