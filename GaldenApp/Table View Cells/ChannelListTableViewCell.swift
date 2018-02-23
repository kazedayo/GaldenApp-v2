//
//  ChannelListTableViewCell.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 15/11/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit

class ChannelListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var channelIcon: UIImageView!
    @IBOutlet weak var channelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
