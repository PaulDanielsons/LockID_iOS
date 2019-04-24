//
//  BluetoothTableView.swift
//    LockID Portal
//
//  Created by Paul Danielsons on 2/12/19.
//  Copyright © 2019 Paul Danielsons. All rights reserved.
//  Partial code is sourced from Udemy.com
//
import UIKit

class BluetoothTableView: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var signalStregth: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
