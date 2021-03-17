//
//  SettingTableViewCell.swift
//  RtspClient
//
//  Created by hkuit155 on 16/2/2021.
//  Copyright © 2021 Andres Rojas. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var settingTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
