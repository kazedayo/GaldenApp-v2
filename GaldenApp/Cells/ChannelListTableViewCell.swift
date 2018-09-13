//
//  ChannelListTableViewCell.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 15/11/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import SnapKit

class ChannelListTableViewCell: UITableViewCell {
    
    let channelTitle = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        
        channelTitle.textColor = .white
        channelTitle.textAlignment = .center
        channelTitle.font = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(channelTitle)
        
        channelTitle.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
