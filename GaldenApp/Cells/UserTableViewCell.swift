//
//  UserTableViewCell.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 17/9/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    let avatarView = UIImageView()
    let unameLabel = UILabel()
    let ugroupLabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
        selectedBackgroundView = bgColorView
        unameLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        unameLabel.adjustsFontForContentSizeCategory = true
        ugroupLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        ugroupLabel.adjustsFontForContentSizeCategory = true
        contentView.addSubview(avatarView)
        contentView.addSubview(unameLabel)
        
        ugroupLabel.text = "郊登仔"
        ugroupLabel.textColor = UIColor(hexRGB: "aaaaaa")
        contentView.addSubview(ugroupLabel)
        
        avatarView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(contentView.snp.topMargin).offset(5)
            make.leading.equalTo(10)
            make.bottom.equalTo(contentView.snp.bottomMargin).offset(5)
            make.width.equalTo(40)
            make.height.equalTo(avatarView.snp.width).multipliedBy(1/1)
        }
        
        unameLabel.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(contentView.snp.topMargin).offset(5)
            make.leading.equalTo(avatarView.snp.trailing).offset(10)
            make.trailing.equalTo(contentView.snp.trailing).offset(10)
        }
        
        ugroupLabel.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(unameLabel.snp.bottom).offset(10)
            make.leading.equalTo(avatarView.snp.trailing).offset(10)
            make.trailing.equalTo(contentView.snp.trailing).offset(10)
            make.bottom.equalTo(contentView.snp.bottomMargin).offset(5)
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
