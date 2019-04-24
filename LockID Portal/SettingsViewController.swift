//
//  SettingsViewController.swift
//  LockID Portal
//
//  Created by Paul Danielsons on 3/7/19.
//  Copyright © 2019 Paul Danielsons. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController {
    
    var weatherCity : String = ""
    var name : String = "New User"
    
    @IBOutlet weak var weatherSwitch: UISwitch!
    @IBOutlet weak var nameSwitch: UISwitch!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var weatherTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Swipe
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
        //loadSettings
        if UserDefaults.standard.bool(forKey: "weatherEnabled") == false {
            weatherSwitch.setOn(false, animated: true)
        }
        if UserDefaults.standard.bool(forKey: "nameEnabled") == false {
            nameSwitch.setOn(false, animated: true)
        }
        let name = UserDefaults.standard.string(forKey: "welcomeName") ?? ""
        if name != ""{
           nameTextField.text = name
        }
        let city = UserDefaults.standard.string(forKey: "weatherCity") ?? ""
        if city != "" {
            weatherTextField.text = city
        }
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer){
        if sender.state == .ended{
            switch sender.direction {
            case .left:
                performSegue(withIdentifier: "segueHome", sender: nil)
            default: break
            }
        }
    }
    
    
    @IBAction func switchWeatherEnabled(_ sender: Any) {
        if weatherSwitch.isOn {
            UserDefaults.standard.set(true, forKey: "weatherEnabled")
            
        } else {
            UserDefaults.standard.set(false, forKey: "weatherEnabled")
        }
    }
    
    @IBAction func switchNameEnabled(_ sender: Any) {
        if nameSwitch.isOn {
            UserDefaults.standard.set(true, forKey: "nameEnabled")
        } else {
            UserDefaults.standard.set(false, forKey: "nameEnabled")
        }
    }


    
    @IBAction func tap_UpdateWeather(_ sender: Any) {
        if weatherTextField.text != ""{
            UserDefaults.standard.set("\(weatherTextField.text ?? "Cincinnati")", forKey: "weatherCity")
        }
        
    }
    
    @IBAction func tap_UpdateName(_ sender: Any) {
        if nameTextField.text != "" {
            UserDefaults.standard.set("\(nameTextField.text ?? "Hello there!")", forKey: "welcomeName")
        }
    }
    
    @IBAction func launchAdminPortal(_ sender: Any) {
        guard let url = URL(string: "https://lockid-adminportal.azurewebsites.net") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func unwind(for segue: UIStoryboardSegue) {
    }
}
