//
//  HomeViewController.swift
//  LockID Portal
//
//  Created by Paul Danielsons on 10/9/18.
//  Copyright © 2018 Paul Danielsons. All rights reserved.
// Partial Bluetooth logic from Udemy
//

import UIKit
import LocalAuthentication
import CoreBluetooth
import Alamofire
import Hero


let LockIDServiceUUID = CBUUID(string: "EC781505-C697-4A86-814D-D16E3ED9A3F0")
let LockIdentityCharacteristicCBUUID = CBUUID(string: "83843F96-A435-4C8D-8F09-DCCDD3F17309")
let TOTPCharacteristicCBUUID = CBUUID(string: "83843F96-A435-4C8D-8F09-DCCDD3F1730A")
let LockStatusCharacteristicCBUUID = CBUUID(string: "83843F96-A435-4C8D-8F09-DCCDD3F1730B")

class HomeViewController: UIViewController, CBCentralManagerDelegate {
    
    /*
    Workflow for processing locks
     1. centralManager scans for BT peripherals nearby
     2. BT discoveries are then limited to those with the 'LockIDServiceUUID' Service
     3. The BLE device is then connected to
     4. The characteristics are then discovered:
            A. LockIdentityCharacteristicCBUUID
            B. TOTPCharacteristicCBUUID
            C. LockStatusCharacteristicCBUUID
     
    4. The lock status and lock Identity are obtained
    5. The lock's ID (and the AccessToken from the login register call) are then processed to obtain the lock TOTP
    6. The TOTP is then written to the lock.
    7. The user is presented with a biometric verification.
    
    */
    
    var centralManager : CBCentralManager?
    var lockPeripheral: CBPeripheral!
    var lockName = ""
    var lockID: String!
    var _peripheral: CBPeripheral?
    var _totpCharacteristics: CBCharacteristic?
    private var authSuccess = false
    var userAccessToken: String!
    let appID:String = UIDevice.current.identifierForVendor!.uuidString
    var lockToken = ""
    var city: String!
    var welcomeName: String!
    
    @IBOutlet weak var txt_WelcomeName: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var animationImage: UIImageView!
    @IBOutlet weak var searchingImage: UIImageView!
    @IBOutlet weak var txt_searching: UILabel!
    @IBOutlet weak var btn_Settings: UIBarButtonItem!
    @IBOutlet weak var btn_BTDiscovery: UIBarButtonItem!
    
   
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        rightSwipe.direction = .right
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        leftSwipe.direction = .left
        
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(leftSwipe)
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getWeather()
        animate()
        uiTweak()
        loadDefaults()
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer){
        if sender.state == .ended{
            switch sender.direction {
            case .right:
                performSegue(withIdentifier: "segueSettings", sender: nil)
                stopScan()
            case .left:
               performSegue(withIdentifier: "segueBT", sender: nil)
                stopScan()
            default:
                performSegue(withIdentifier: "segueBT", sender: nil)
            }
        }
    }
    
    func uiTweak(){
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Apple SD Gothic Neo", size: 20)!]
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    func  loadDefaults(){
    
        //Show Weather
        if UserDefaults.standard.bool(forKey: "weatherEnabled") == true {
            weatherDescription.isHidden = false
            cityName.isHidden = false
        } else if UserDefaults.standard.bool(forKey: "weatherEnabled") == false {
            weatherDescription.isHidden = true
            cityName.isHidden = true
        }  else {
            weatherDescription.isHidden = false
            cityName.isHidden = false
        }
        
        //Show Name
        if UserDefaults.standard.bool(forKey: "nameEnabled") == true {
            txt_WelcomeName.isHidden = false
        } else if UserDefaults.standard.bool(forKey: "nameEnabled") == false {
            txt_WelcomeName.isHidden = true
        }  else {
            txt_WelcomeName.isHidden = false
        }
        
        if UserDefaults.standard.string(forKey: "welcomeName") != nil || UserDefaults.standard.string(forKey: "welcomeName") != "" {
            welcomeName = UserDefaults.standard.string(forKey: "welcomeName") ?? ""
            txt_WelcomeName.text = "Hello, \(welcomeName!)"
        }
        

    }
    
    
    func getWeather() {
        if UserDefaults.standard.string(forKey: "weatherCity") != nil || UserDefaults.standard.string(forKey: "weatherCity") != ""{
            city = UserDefaults.standard.string(forKey: "weatherCity") ?? "Cincinnati"
        } else {
            city = "Cincinnati"
        }
        
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city!)&appid=63923be9836ed9e5e6ce36dd771dfb4e")
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            
            if error != nil {
                print(error as Any)
            } else {
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    let description = ((jsonResult["weather"] as? NSArray)?[0] as? NSDictionary)?["description"] as? String
                    DispatchQueue.main.sync {
                        self.cityName.text = self.city!.lowercased().capitalized
                        self.weatherDescription.text = description?.lowercased().capitalized
                        //print(jsonResult)
                    }
                } catch let error as NSError {
                    print("JSON Processing Has Failed: ")
                    print(error)
                }
            }
            }.resume()
    }
  
    @IBAction func logOut(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToLogin", sender: self)
    }
    
    @IBAction func unwind(for segue: UIStoryboardSegue) {

        
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueSettings" {
            let dest = segue.destination as! SettingsViewController
            dest.hero.isEnabled = true
            dest.hero.modalAnimationType = .selectBy(presenting: .push(direction: .right), dismissing: .push(direction: .left))
        }
        if segue.identifier == "segueBT" {
            let dest = segue.destination as! BluetoothViewController
            dest.hero.isEnabled = true
            dest.hero.modalAnimationType = .selectBy(presenting: .push(direction: .left), dismissing: .push(direction: .right))
        }
    }
    
    func animate(){
        animationImage.loadGif(name: "homeAnimation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
            self.txt_searching.isHidden = true
            self.animationImage.image = UIImage(named: "HoldNearLock");
            self.searchingImage.loadGif(name: "Searching")
        })
    }
    
    @IBAction func screenTap(_ sender: Any) {
        animate()
        startScan()
    }
    

    // Begin Bluetooth Code
    func startScan() {
        centralManager?.stopScan()
        centralManager?.scanForPeripherals(withServices: [LockIDServiceUUID], options: nil)
    }
    
    func stopScan() {
         centralManager?.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (peripheral.name != nil && RSSI.intValue >= -65){
            lockName = peripheral.name!
            lockPeripheral = peripheral
            centralManager?.stopScan()
            centralManager?.connect(lockPeripheral)
            lockPeripheral.delegate = self
           
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        lockPeripheral.discoverServices([LockIDServiceUUID])
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScan()
        
        }
        else if central.state == .poweredOff{
            let alertVC = UIAlertController(title: "Bluetooth is Turned off", message: "Bluetooth is necessary for lock discovery. Please turn on bluetooh in Settings.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                alertVC.dismiss(animated: true, completion: nil)
            })
            alertVC.addAction(okAction)
            present(alertVC, animated: true, completion: nil)
        }
        else {
            let alertVC = UIAlertController(title: "Something went wrong with your bluetooth", message: "Make sure your bluetooth turned on, so locks can be discovered.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                alertVC.dismiss(animated: true, completion: nil)
            })
            alertVC.addAction(okAction)
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    
    //Action Handling
    @IBAction func refreshTapped(_ sender: Any) {
        startScan()
    }
    
    func showAlertController(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in self.viewDidLoad()}))
        present(alertController, animated: true, completion: nil)
    }
    
    func  AuthenticateUser(){
        let context = LAContext()
        var error: NSError?
        
        // check if Touch ID is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to verify your identity"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                {(success, error) in
                    if success {
                        self.writeToLock()
                        self.disconnect()
                    }
                    else {
                        self.showAlertController("Authentication was unsuccessful, and the lock was not able to unlock.")
                        self.disconnect()
                    }
            })
        }
        else {
            showAlertController("Oops! Touch ID is not available. Please check your device settings.")
        }
    }
    
    
    func getTOTPKey(){
            let headers: HTTPHeaders = [
                "Content-Type" : "application/json",
                "responseContentType" : "text/plain",
                "Authorization" : "Bearer \(userAccessToken!)"
            ]
        
            let apiIdentity = "https://lockid-api.azurewebsites.net"
        let apiURL = "\(apiIdentity)/api/lock/\(lockID!)/key/\(appID)"
        print("apiURL = \(apiURL)")
            Alamofire.request("\(apiIdentity)/api/lock/\(lockID!)/key/\(appID)", method: .get, headers: headers)
                .validate(statusCode: 200..<300)
                .response { response in
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        self.lockToken = utf8Text
                         print("apiURL = \(apiURL)")
                        print ("The lock token is: \(self.lockToken)")
                       
                        self.lockDiscovered()
                      
                        print("tried to write with key \(self.lockToken)")
                    }
        }
    }

    func lockDiscovered(){
        let alert = UIAlertController(title: "Lock Discovered: \(lockName)", message: "What do you want to do with this lock?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Ignore", style: .default, handler: { (action) in
            self.stopScan()
            self.disconnect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 60.0, execute: {
               self.startScan()
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Unlock", style: .default, handler: { (action) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
            self.stopScan()
            self.AuthenticateUser()
             }
            )}
        ))
        self.present(alert, animated: true, completion: nil)
    }
}


//peripheral handling
extension HomeViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(" ")
            print("LockID Service: ")
            print(service)
            print(" ")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        print(" ")
        print("LockID characteristics : ")
        for characteristic in characteristics {
          
           
            print(characteristic)
            
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)

            }
            if characteristic.properties.contains(.write) {
                print("\(characteristic.uuid): properties contains .write")

                _peripheral = peripheral
                _totpCharacteristics = characteristic
                
            }
            print(" ")
        }
        print(" ")
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        
        switch characteristic.uuid {
        case LockIdentityCharacteristicCBUUID:
            let lockIdentityValue = lockIdentity(from: characteristic)
            print("The lock identity is: \(lockIdentityValue)")
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
        
        switch characteristic.uuid {
        case LockStatusCharacteristicCBUUID:
            let lockStatusValue = lockStatus(from: characteristic)
            print("The lock status is: \(lockStatusValue)")
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    private func lockIdentity(from characteristic: CBCharacteristic) -> String {
        // Convert byte to unicode string
        let lockIdentity = String(data: characteristic.value!, encoding: String.Encoding.utf8)
        
        // If value exists
        if let lockIdentity = lockIdentity {
            lockID = lockIdentity
            //App has AccessToken and LockIdentity - Lock TOTP is now obtained
            getTOTPKey()
          return lockIdentity
            
        }
        return "Could not retrieve Value"
    }
   
    private func lockStatus(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value,
            let byte = characteristicData.first else { return "Error" }
        
        switch byte {
        case 0: return "Other"
        case 1: return "Locked"
        case 2: return "Unlocked"
        case 3: return "Unknown/Default"
        default:
            return "Reserved for future uses"
        }
    }
    
    func writeToLock(){
        let string = self.lockToken
        let data = string.data(using: String.Encoding.utf8)
        _peripheral!.writeValue(data!, for:  _totpCharacteristics!, type: CBCharacteristicWriteType.withResponse)
    }
    
    func disconnect(){
        // 1 - verify we have a peripheral
        guard let peripheral = self._peripheral
            else {
            print("No peripheral available to cleanup.")
            return
        }
        
        // 2 - Don't do anything if we're not connected
        if peripheral.state != .connected {
            print("Peripheral is not connected.")
            self._peripheral = nil
            return
        }
        
        // 3
        guard let services = peripheral.services else {
            // disconnect directly
            centralManager?.cancelPeripheralConnection(peripheral)
            return
        }
        
        // 4 - iterate through services
        for service in services {
            // iterate through characteristics
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    // find the Transfer Characteristic we defined in our Device struct
                    if characteristic.uuid ==  CBUUID(string: "83843F96-A435-4C8D-8F09-DCCDD3F1730B") {
                        // 5
                        peripheral.setNotifyValue(false, for: characteristic)
                        return
                    }
                }
            }
        }
        
        // 6 - disconnect from peripheral
        centralManager?.cancelPeripheralConnection(peripheral)
    }
}





