//
//  SZURayOvalLayer.swift
//  SZUAnimations
//
//  Created by Slava Zubrin on 10/30/16.
//  Copyright © 2016 Slava Zubrin. All rights reserved.
//

import UIKit

class SZURayOvalLayer: CAShapeLayer {
    
    let animationDuration: CFTimeInterval = 0.3
    
    override init() {
        super.init()
        
        fillColor = UIColor.blue.cgColor
        path = ovalPathSmall.cgPath
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var ovalPathSmall: UIBezierPath {
        return UIBezierPath(ovalIn: CGRect(x: 50.0, y: 50.0, width: 0.0, height: 0.0))
    }
    
    var ovalPathLarge: UIBezierPath {
        return UIBezierPath(ovalIn: CGRect(x: 2.5, y: 2.5, width: 95.0, height: 95.0))
    }
    
    var ovalPathSquishVertical: UIBezierPath {
        return UIBezierPath(ovalIn: CGRect(x: 2.5, y: 20.0, width: 95.0, height: 90.0))
    }
    
    var ovalPathSquishHorizontal: UIBezierPath {
        return UIBezierPath(ovalIn: CGRect(x: 5.0, y: 20.0, width: 90.0, height: 90.0))
    }
    
    func expand() {
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = ovalPathSmall.cgPath
        animation.toValue   = ovalPathLarge.cgPath
        animation.duration  = animationDuration;
        animation.fillMode  = kCAFillModeForwards;
        animation.isRemovedOnCompletion = false;
        add(animation, forKey: nil)
    }
    
    func wobble() {
        
    }
    
    func contract() {
        
    }

}
