//
//  DetailSettingsTableViewCell.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/02/17.
//

import UIKit

class DetailSettingsTableViewCell: UITableViewCell {

    @IBOutlet var toggleSwitch: UISwitch!
    
    @IBOutlet var stepper: UIStepper!
    @IBOutlet var label: UILabel!
    
    @IBOutlet var stepperCharSize: UIStepper!
    
    @IBOutlet var toggleSwitchDarkMode: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        if toggleSwitch != nil {
            print(UserDefaults.standard.bool(forKey: "TableViewOrCollectionView"))
            toggleSwitch.isOn = UserDefaults.standard.bool(forKey: "TableViewOrCollectionView")
        }
        if stepper != nil {
            print(UserDefaults.standard.double(forKey: "SyncInterval"))
            stepper.value = UserDefaults.standard.double(forKey: "SyncInterval")
            label.text = "\(Int(stepper.value)) min"
        }
        if stepperCharSize != nil {
            print(UserDefaults.standard.double(forKey: "CharSize"))
            stepperCharSize.value = UserDefaults.standard.double(forKey: "CharSize")
            label.text = "\(Int(stepperCharSize.value))"
        }
        if toggleSwitchDarkMode != nil {
            print(UserDefaults.standard.bool(forKey: "DarkMode"))
            toggleSwitchDarkMode.isOn = UserDefaults.standard.bool(forKey: "DarkMode")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
