//
//  OnboardingViewController.swift
//  LockID Portal
//
//  Created by Paul Danielsons on 3/13/19.
//  Copyright © 2019 Paul Danielsons. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: "firstLaunch")

        
       

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
