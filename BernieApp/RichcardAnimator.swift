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
    
    let duration = 0.2
    var presenting = true
    var originFrame = CGRect.zero
    var cell = CarouselCell()
    
    var dismissCompletion: (()->Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
                        
        let details = presenting ? toView :
            transitionContext.view(forKey: .from)!
        
        var detailsFrame: CGRect = details.frame
        
        var card = CardView()
        
        for subview in details.subviews {
            if type(of: subview) == BackgroundImageView.self {
                detailsFrame = subview.frame
            }
            if type(of: subview) == CardView.self {
                card = subview as! CardView
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
            details.layer.cornerRadius = richcardRadius
            
            card.isHidden = true
            card.transform = CGAffineTransform(translationX: 0, y: card.topHeight)
            
            UIView.animate(withDuration: duration, animations: {
                self.cell.subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 10)
                self.cell.subtitleLabel.alpha = 0.0
            })
            
            UIView.animate(withDuration: duration, delay: 0.1, animations: {
                self.cell.titleLabel.transform = CGAffineTransform(translationX: 0, y: 10)
                self.cell.titleLabel.alpha = 0.0
            }, completion: {_ in
                containerView.addSubview(toView)
                containerView.bringSubview(toFront: details)
                
                UIView.animate(withDuration: self.duration, delay:0.0, options: .curveEaseInOut,
                               animations: {
                                details.transform = CGAffineTransform.identity
                                details.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
                                details.layer.cornerRadius = 0
                },
                               completion:{_ in
                                
                                card.isHidden = false
                                UIView.animate(withDuration: self.duration, animations: {
                                    
                                    card.transform = CGAffineTransform.identity
                                    transitionContext.completeTransition(true)
                                })
                }
                )
            })
        }
        else {
            containerView.addSubview(toView)
            containerView.bringSubview(toFront: details)
            
            
            UIView.animate(withDuration: self.duration, animations: {
                card.transform = CGAffineTransform(translationX: 0, y: card.topHeight)
            }, completion: {_ in
                
                card.isHidden = true
                UIView.animate(withDuration: self.duration, delay:0.0, options: .curveEaseInOut,
                               animations: {
                                details.transform = scaleTransform
                                details.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
                                details.layer.cornerRadius = richcardRadius
                },
                               completion:{_ in
                                
                                containerView.bringSubview(toFront: toView)
                                UIView.animate(withDuration: self.duration, animations: {
                                    self.cell.subtitleLabel.transform = CGAffineTransform.identity
                                    self.cell.subtitleLabel.alpha = 1.0
                                })
                                
                                UIView.animate(withDuration: self.duration, delay: 0.1, animations: {
                                    self.cell.titleLabel.transform = CGAffineTransform.identity
                                    self.cell.titleLabel.alpha = 1.0
                                }, completion: {_ in
                                    self.dismissCompletion?()
                                    
                                    transitionContext.completeTransition(true)
                                })
                }
                )

            })
            
         }
        
        
    }
}
