//
//  PageSelectTableViewCell.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 16/10/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit

class PageSelectTableViewCell: UITableViewCell {
    
    let pageNo = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        pageNo.textColor = .lightGray
        pageNo.textAlignment = .center
        pageNo.font = UIFont.preferredFont(forTextStyle: .subheadline)
        pageNo.adjustsFontForContentSizeCategory = true
        contentView.addSubview(pageNo)
        
        pageNo.snp.makeConstraints {
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
