//
//  ChannelListTableViewCell.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 15/11/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import AttributedLabel

class ChannelListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var channelIcon: UIImageView!
    @IBOutlet weak var channelTitle: AttributedLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        channelTitle.font = UIFont.systemFont(ofSize: 15)
        channelTitle.contentAlignment = .center
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
