//
//  ThreadListTableViewCell.swift
//  GaldenApp
//
//  Created by 1080 on 30/9/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import AttributedLabel

class ThreadListTableViewCell: UITableViewCell {
    
    
    //MARK: Properties
    
    
    @IBOutlet weak var threadTitleLabel: AttributedLabel!
    @IBOutlet weak var detailLabel: AttributedLabel!
    @IBOutlet weak var titleTrailing: NSLayoutConstraint!
    @IBOutlet weak var detailTrailing: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
        selectedBackgroundView = bgColorView
        threadTitleLabel.numberOfLines = 0
        detailLabel.numberOfLines = 1
        threadTitleLabel.usesIntrinsicContentSize = true
        threadTitleLabel.preferredMaxLayoutWidth = threadTitleLabel.frame.width
        threadTitleLabel.font = UIFont.systemFont(ofSize: 15)
        detailLabel.font = UIFont.systemFont(ofSize: 12)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
