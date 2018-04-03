//
//  BlockedTableViewCell.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 1/4/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import UIKit

class BlockedTableViewCell: UITableViewCell {

    let threadTitleLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
        selectedBackgroundView = bgColorView
        
        threadTitleLabel.textColor = .lightGray
        threadTitleLabel.font = UIFont.systemFont(ofSize: 15)
        threadTitleLabel.numberOfLines = 0
        contentView.addSubview(threadTitleLabel)
        
        threadTitleLabel.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.bottom.equalTo(-10)
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
