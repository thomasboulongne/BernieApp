//
//  RichcardAnimator.swift
//  BernieApp
//
//  Created by Eleve on 14/06/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit

class RichcardAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.3
    var presenting = true
    var originFrame = CGRect.zero
    var cell = CarouselCell()
    
    var dismissCompletion: (()->Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let viewController = presenting ?
            transitionContext.viewController(forKey: .from) as! ViewController : transitionContext.viewController(forKey: .to) as! ViewController
        
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
                        
        let details = presenting ? toView :
            transitionContext.view(forKey: .from)!
        
        var detailsFrame: CGRect = details.frame
        
        for subview in details.subviews {
            if type(of: subview) == BackgroundImageView.self {
                detailsFrame = subview.frame
            }
        }
        
        let initialFrame = presenting ? originFrame : detailsFrame
        let finalFrame = presenting ? detailsFrame : originFrame
        
        let xScaleFactor = presenting ?
            
            initialFrame.width / finalFrame.width :
            finalFrame.width / initialFrame.width
        
        let yScaleFactor = presenting ?
            
            initialFrame.height / finalFrame.height :
            finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor,
                                               y: yScaleFactor)
        
        if presenting {
            details.transform = scaleTransform
            details.center = CGPoint(
                x: initialFrame.midX,
                y: initialFrame.midY)
        }
                
        containerView.addSubview(details)
        
//        containerView.bringSubview(toFront: details)
        
        self.animateImage(containerView: containerView, context: transitionContext, details: details, finalFrame: finalFrame, scaleTransform: scaleTransform)
    }
    
    func animateImage(containerView: UIView, context: UIViewControllerContextTransitioning, details: UIView, finalFrame: CGRect, scaleTransform: CGAffineTransform ) {
        
        containerView.bringSubview(toFront: details)
        UIView.animate(withDuration: duration, delay:0.0,
                       animations: {
                        details.transform = self.presenting ?
                            CGAffineTransform.identity : scaleTransform
                        details.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        },
                       completion:{_ in
                        if !self.presenting {
                            self.dismissCompletion?()
                        }
                        context.completeTransition(true)
        }
        )
    }
}
