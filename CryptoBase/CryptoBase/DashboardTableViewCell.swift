//
//  DashboardTableViewCell.swift
//  CryptoBase
//
//  Created by eirik Bernhart on 11.12.2017.
//  Copyright © 2017 eirik Bernhart. All rights reserved.
//

import UIKit

class DashboardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var currencyLabel : UILabel!
    @IBOutlet weak var currencyValueLabel : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
