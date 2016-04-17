//
//  StyleNavigator.swift
//  HackaBike
//
//  Created by Esdras Martins on 4/16/16.
//  Copyright © 2016 Ezequiel. All rights reserved.
//

import UIKit

class StyleNavigator: NSObject {

    func custom(navigator:UINavigationController) -> Void {
        navigator.navigationBar.tintColor = UIColor(red: 31/255, green: 25/255, blue: 36/255, alpha: 1)
        navigator.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Montserrat-Bold", size: 21)!]
    }
 
    func hidden(navigator:UINavigationController) -> Void {
        navigator.setNavigationBarHidden(false, animated: false)
    }
    
    func notHidden(navigator:UINavigationController) -> Void {
        navigator.setNavigationBarHidden(true, animated: false)
    }
    
}
