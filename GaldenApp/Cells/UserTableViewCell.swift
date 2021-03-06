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
    let primaryStack = UIStackView()
    let secondaryStack = UIStackView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .systemBackground
        unameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        unameLabel.adjustsFontForContentSizeCategory = true
        ugroupLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        ugroupLabel.adjustsFontForContentSizeCategory = true
        avatarView.layer.cornerRadius = 25
        avatarView.clipsToBounds = true
        
        ugroupLabel.text = "郊登仔"
        ugroupLabel.textColor = .secondaryLabel
        
        primaryStack.axis = .vertical
        primaryStack.alignment = .leading
        primaryStack.distribution = .equalSpacing
        primaryStack.spacing = 10
        primaryStack.addArrangedSubview(unameLabel)
        primaryStack.addArrangedSubview(ugroupLabel)
        
        secondaryStack.axis = .horizontal
        secondaryStack.alignment = .center
        secondaryStack.distribution = .fillProportionally
        secondaryStack.spacing = 10
        secondaryStack.addArrangedSubview(avatarView)
        secondaryStack.addArrangedSubview(primaryStack)
        contentView.addSubview(secondaryStack)
        
        avatarView.snp.makeConstraints {
            (make) -> Void in
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        secondaryStack.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(10)
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
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
