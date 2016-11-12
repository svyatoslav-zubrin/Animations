//
//  SZUIconAnimationsViewController.swift
//  SZUAnimations
//
//  Created by Slava Zubrin on 10/29/16.
//  Copyright © 2016 Slava Zubrin. All rights reserved.
//

import UIKit

class SZUIconAnimationsViewController: UIViewController {

    private var animationView: SZUAnimationViewInterface?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let frame = CGRect(x: (view.bounds.size.width - 100) / 2,
                           y: (view.bounds.size.height - 100) / 2,
                           width: 100,
                           height: 100)
        let rayAnimetionView = SZURayAnimationView(frame: frame)
        rayAnimetionView.backgroundColor = UIColor.lightGray
        self.view.addSubview(rayAnimetionView)
        
        animationView = rayAnimetionView
    }
    
    // MARK: Actions
    
    @IBAction
    func start(sender: NSObject) {
        animationView?.animate()
    }
}
