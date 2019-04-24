//
//  BluetoothViewController.swift
//  LockID Portal
//
//  Copyright © 2019 Paul Danielsons. All rights reserved.
//  Partial code is sourced from Udemy.com
//
//

import UIKit
import CoreBluetooth

class BluetoothViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate {
    
    var centralManager : CBCentralManager?
    var strength = "Error"
    var names : [String] = []
    var RSSIs : [NSNumber] = []
    var signalStregth : [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIImage(named: "backButton")
        self.navigationController?.navigationBar.backIndicatorImage = backButton
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backButton
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        view.addGestureRecognizer(rightSwipe)
    
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer){
        if sender.state == .ended{
            switch sender.direction {
            case .right:
                performSegue(withIdentifier: "segueHome", sender: nil)
            default: break
            }
        }
    }
    
    @IBAction func rescan(_ sender: Any) {
        names = []
        RSSIs = []
        signalStregth = []
        
        startScan()
        tableView.reloadData()
    }
    
    
    
    
    func startScan() {
        centralManager?.stopScan()
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//      Values are based of: https://www.metageek.com/training/resources/understanding-rssi.html
        if (RSSI.intValue <= -90){
            strength = "Unusable"
        } else  if (RSSI.intValue <= -80){
            strength = "Not good"
        } else if (RSSI.intValue <= -70){
            strength = "Okay"
        } else if (RSSI.intValue <= -67){
            strength = "Very good"
        } else if (RSSI.intValue <= -50){
            strength = "Excellent"
        } else if (RSSI.intValue <= -30){
            strength = "Near perfect"
        } else if (RSSI.intValue >= -30){
            strength = "Perfect"
        }
        
        if let name = peripheral.name {
            names.append(name)
        } else{
            names.append(peripheral.identifier.uuidString)
        }
      
        RSSIs.append(RSSI)
        signalStregth.append(strength)
        tableView.reloadData()
     
        
//
//        if let name = peripheral.name {
//            print("Device Name: \(name)")
//            print("UUID: \(peripheral.identifier.uuidString)")
//            print("RSSI: \(RSSI)")
//            print("Signal Stregth: \(strength)")
//            // print ("Ad Data: \(advertisementData)")
//            print("\n")
//        }
//        else{
//            print("Device Name: Unknown")
//            print("UUID: \(peripheral.identifier.uuidString)")
//            print("RSSI: \(RSSI)")
//            print("Signal Stregth: \(strength)")
//            // print ("Ad Data: \(advertisementData)")
//            print("\n")
//        }
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Working
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
            // Not Working
            let alertVC = UIAlertController(title: "Something went wrong with your bluetooth", message: "Make sure your bluetooth turned on, so locks can be discovered.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                alertVC.dismiss(animated: true, completion: nil)
            })
            alertVC.addAction(okAction)
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "bluetoothCell", for: indexPath) as? BluetoothTableView {
            cell.nameLabel.text = names[indexPath.row]
            cell.signalStregth.text = "Signal Stregth: \(signalStregth[indexPath.row])"
            cell.rssiLabel.text = "RSSI: \(RSSIs[indexPath.row])"
            return cell
        }
        return UITableViewCell()
    }
}
