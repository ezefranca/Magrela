//
//  InitVC.swift
//  HackaBike
//
//  Created by Esdras Martins on 4/16/16.
//  Copyright © 2016 Ezequiel. All rights reserved.
//

import UIKit

class InitVC: UIViewController {

    @IBOutlet weak var play: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func playVideo(sender: AnyObject) {
        performSegueWithIdentifier("LoginVC", sender: self);
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
