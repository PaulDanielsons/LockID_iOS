//
//  LoginViewController.swift
//  LockID Portal
//
//  Created by Paul Danielsons on 3/9/19.
//  Copyright © 2019 Paul Danielsons. All rights reserved.
//

import UIKit
import Alamofire

struct TokenResponse: Codable{
    var access_token: String
    var expires_in: Int
    var token_type: String
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
  
    @IBOutlet weak var txt_userName: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    @IBOutlet weak var btn_Login: UIButton!
    @IBOutlet weak var lbl_errorMessage: UILabel!
    @IBOutlet weak var connectionImage: UIImageView!
    @IBOutlet weak var btn_SaveLogin: UIBarButtonItem!
    
    var username =  ""
    var password = ""
    var accessToken: String = ""
    var loginSuccess: Bool = false
    let appID:String = UIDevice.current.identifierForVendor!.uuidString

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        //handle saved info
        if UserDefaults.standard.bool(forKey: "loginSaved") == true {
            txt_userName.text = UserDefaults.standard.string(forKey: "username") ?? ""
            txt_password.text = UserDefaults.standard.string(forKey: "password") ?? ""
           
            self.btn_SaveLogin.title = "Forget Login"
        }
    }
    //Modify Keyboard Settings
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txt_userName {
            txt_password.becomeFirstResponder()
        } 
        return true
    }

    @IBAction func textFieldPrimaryActionTriggered(_ sender: Any) {
         btn_Login.sendActions(for: .touchUpInside)
    }
    
    //Toolbar Actions
    @IBAction func unreg_tap(_ sender: Any) {
        let alertController = UIAlertController(title: "Reset App", message: "This will reset your device's registration. Relaunching the app will load the inital registration view. \n\n To proceed select 'OK'", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in self.resetDevice()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    

    func resetDevice(){
        UserDefaults.standard.set(nil, forKey: "firstLaunch")
    }
    
    
    @IBAction func tap_register(_ sender: Any) {
        performSegue(withIdentifier: "seugeOnboarding", sender: nil)
    }
    
    @IBAction func SaveLogin(_ sender: Any) {
        // remove info
         if UserDefaults.standard.bool(forKey: "loginSaved") == true {
            
            UserDefaults.standard.set("", forKey: "username")
            UserDefaults.standard.set("", forKey: "password")
            
            txt_userName.text = ""
            txt_password.text = ""
            
            UserDefaults.standard.set(false, forKey: "loginSaved")
            
            self.btn_SaveLogin.title = "Save Login"
            
        }
         //Store info
         else if txt_password.text == "" || txt_userName.text == "" {
            let alert = UIAlertController(title: "Missing Information", message: "Username and password cannot be empty while saving the login information.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            UserDefaults.standard.set("\(txt_userName.text!)", forKey: "username")
            UserDefaults.standard.set("\(txt_password.text!)", forKey: "password")
            
            UserDefaults.standard.set(true, forKey: "loginSaved")
            
            self.btn_SaveLogin.title = "Forget Login"
            
            let alert = UIAlertController(title: "Success", message: "Your username and password have been stored locally. \n\n Adios, pesky login info!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    func validateInputs() -> Bool {
        if (txt_userName.text?.isEmpty)! {
            txt_userName.attributedPlaceholder = NSAttributedString(string: "This is a required field", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
 
        if (txt_password.text?.isEmpty)! {
            txt_password.attributedPlaceholder = NSAttributedString(string: "This is a required field", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        return true
    }
    
    func connectToken(){
        //        Obtains Access key, expire time, and token type and if successful registers device
        if validateInputs() == true {
            username = txt_userName.text!
            password = txt_password.text!
            
            let parameters: [String: String] = [
                "grant_type": "password",
                "username":"\(username)",
                "password":"\(password)",
                "scope":"LockIDApi",
                "client_id":"PhoneClient",
                "client_secret":"e465302d-af88-4d00-88a6-357c86f0b5fd"
            ]
            
            let apiIdentity = "https://lockid-identityserver.azurewebsites.net"
            
            Alamofire.request("\(apiIdentity)/connect/token", method: .post, parameters: parameters, encoding: URLEncoding.default)
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseData { response in
                    switch response.result {
                    case .success:
                        if let data = response.data, let _ = String(data: data, encoding: .utf8)
                        {
                            do {
                                let decoder = JSONDecoder()
                                let token = try decoder.decode(TokenResponse.self,from: data)
                                self.accessToken = token.access_token
                                self.registerDevice()
                                self.animate()
                                print("The user's access token is: \n \(self.accessToken) \n")
                            } catch {
                                print("error")
                            }
                            self.lbl_errorMessage.isHidden = false
                        }
                        
                    case .failure:
                        self.lbl_errorMessage.isHidden = false
                        self.lbl_errorMessage.text = "Login Failed"
                        self.lbl_errorMessage.textColor = UIColor.red
                    }
                    
                    
            }
        }
    }
    
    func registerDevice(){
        
//        print("Device identifier for registration is: \(appID)")
//
//        let headers: HTTPHeaders = [
//            "Authorization" : "Bearer \(self.accessToken)"
//        ]
//
//        let apiIdentity = "https://lockid-api.azurewebsites.net"
//
//        Alamofire.request("\(apiIdentity)/api/device/\(appID)/register", method: .get, headers: headers)
//            .validate(statusCode: 200..<300)
//            .response { response in
//                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                    print("Connection result is \(data)")
//                }
//        }
    
       
        //After registering device user is logged in
       loginUser()
    }
    
    func animate(){
        connectionImage.isHidden = false
        connectionImage.loadGif(name: "connecting")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.connectionImage.isHidden = true
            self.resetView()
        })
    }
    
    func resetView(){
        lbl_errorMessage.text = "Sign In"
        self.lbl_errorMessage.textColor = UIColor.white
        connectionImage.isHidden = true
        txt_userName.text = ""
        txt_password.text = ""
    }
    
    func loginUser(){
        loginSuccess.toggle()
        performSegue(withIdentifier: "segueHome", sender: nil )
    }

    @IBAction func tap_Login(_ sender: Any) {
        connectToken()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if loginSuccess == true {
            let navVC = segue.destination as? UINavigationController
            let vc = navVC?.viewControllers.first as! HomeViewController
            vc.userAccessToken = accessToken
            }
            else {
                _ = segue.destination as? OnboardingViewController
            
        }
    }
    
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    }
    
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
 
    









