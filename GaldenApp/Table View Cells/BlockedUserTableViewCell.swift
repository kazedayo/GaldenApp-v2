//
//  BlockedUserTableViewCell.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 28/10/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit

class BlockedUserTableViewCell: UITableViewCell {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
