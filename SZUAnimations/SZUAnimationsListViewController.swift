//
//  SZUAnimationsListViewController.swift
//  SZUAnimations
//
//  Created by Slava Zubrin on 10/28/16.
//  Copyright © 2016 Slava Zubrin. All rights reserved.
//

import UIKit

class SZUAnimationsListViewController: UITableViewController {

    fileprivate let animations = ["Icons", "Fluid Page Control", "Fluid Page Indicator"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = animations[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            self.performSegue(withIdentifier: "toIconAnimations", sender: self)
        } else if (indexPath.row == 1) {
            self.performSegue(withIdentifier: "toFluidPageAnimation", sender: self)
        } else {
            self.performSegue(withIdentifier: "toFluidPageIndicator", sender: self)
        }
    }
}

