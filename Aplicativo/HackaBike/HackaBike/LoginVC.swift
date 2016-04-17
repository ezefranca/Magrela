//
//  ViewController.swift
//  HackaBike
//
//  Created by Ezequiel on 4/16/16.
//  Copyright © 2016 Ezequiel. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginVC: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var fbView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            performSegueWithIdentifier("DevicesVC", sender: self)
        }
        else {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.frame = self.fbView.frame
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil) {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            if result.grantedPermissions.contains("email") {
                // Do work
                returnUserData()

            }
        }
          performSegueWithIdentifier("DevicesVC", sender: self)
       // Navigator().present("MapKitVC", navigation: self.navigationController!)
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserData() {
        /* Coloco os campos que eu quero extrair da conta do facebook do usuário */
        let fbRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, name"])
        
        fbRequest.startWithCompletionHandler({ (FBSDKGraphRequestConnection, result, error) -> Void in
            
            if (error == nil && result != nil) {
                /* Recebo a resposta em forma de dicionário */
                let facebookData = result as! NSDictionary
                
                /* Pego o que as informações que pedi em cada dicionario */
                let userEmail = (facebookData.objectForKey("email") as! String)
                let name = (facebookData.objectForKey("name") as! String)
                
                let p = Personn()
                p.name = name
                p.urlPhoto = ""
                p.longitude = 0
                p.latitude = 0
                p.hiddenPerson = true
                
                PersonnController.insertPerson(p) { (str:String?) in
                    p.objectId = str
                    Singleton.sharedInstance.pessoaAtual = p
                    
                    
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject("\(userEmail)", forKey: "userEmail")
                    defaults.setObject("\(name)", forKey: "userName")
                    print(str)
                }
                
                
                print("\(userEmail) - \(name)")
                
            } else {
                print(">> Erro ao tentar recuperar informações do facebook.")
            }
        })

    }
    
    
}

