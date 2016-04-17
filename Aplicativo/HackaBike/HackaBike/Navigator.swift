//
//  Navigator.swift
//  HackaBike
//
//  Created by Esdras Martins on 4/16/16.
//  Copyright © 2016 Ezequiel. All rights reserved.
//

import UIKit

class Navigator: NSObject {

    func push(identify:String, navigation: UINavigationController) -> Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(identify)
        navigation.pushViewController(vc, animated: true)
    }
    
    func present(identify:String, navigation: UINavigationController) -> Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(identify)
        navigation.presentViewController(vc, animated: true, completion: nil)
    }
}
