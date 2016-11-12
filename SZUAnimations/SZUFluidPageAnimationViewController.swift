//
//  SZUFluidPageAnimationViewController.swift
//  SZUAnimations
//
//  Created by Slava Zubrin on 10/31/16.
//  Copyright © 2016 Slava Zubrin. All rights reserved.
//

import UIKit

class SZUFluidPageAnimationViewController: UIViewController {
    
    @IBOutlet weak var animationView: SZUFluidPageAnimationView!
    @IBOutlet weak var slider: UISlider!

    override func viewDidLoad() {
        animationView.set(progress: CGFloat(slider.value))
//        animationView.spurType = .Quadratic
    }
    
    @IBAction func onSliderChange(_ sender: UISlider) {
        animationView.set(progress: CGFloat(sender.value))
    }
}
