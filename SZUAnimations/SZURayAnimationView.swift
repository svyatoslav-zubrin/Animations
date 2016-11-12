//
//  SZURayAnimationView.swift
//  SZUAnimations
//
//  Created by Slava Zubrin on 10/29/16.
//  Copyright © 2016 Slava Zubrin. All rights reserved.
//

import UIKit

class SZURayAnimationView: UIView {
    
    let ovalLayer = SZURayOvalLayer()
    
    fileprivate func addOval() {
        layer.addSublayer(ovalLayer)
        ovalLayer.expand()
    }
}

extension SZURayAnimationView: SZUAnimationViewInterface {
    func animate() {
        addOval()
    }
}
