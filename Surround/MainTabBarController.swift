//
//  MainTabBarController.swift
//  Surround
//
//  Created by Frank Chen on 2019-04-17.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBar.appearance().tintColor = UIColor(red: 255/255, green: 102/255, blue: 102/255, alpha: 1)
        
        signInAnonymously()
        
        
    }
    
    func signInAnonymously(){
        Auth.auth().signInAnonymously { (authResult, err) in
            if let err = err{
                print("Failed to sign in anonymously", err)
                return
            }
            print("Sign in succesfully with user", authResult?.user.uid ?? "")
        }
    }
    

}
