//
//  ThreadListTableViewCell.swift
//  GaldenApp
//
//  Created by 1080 on 30/9/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import SnapKit

class ThreadListTableViewCell: UITableViewCell {
    //MARK: Properties
    
    let threadTitleLabel = UILabel()
    let detailLabel = UILabel()
    let tagLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
        selectedBackgroundView = bgColorView
        
        backgroundColor = UIColor(white: 0.15, alpha: 1)
        
        threadTitleLabel.textColor = .lightGray
        threadTitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        threadTitleLabel.adjustsFontForContentSizeCategory = true
        threadTitleLabel.numberOfLines = 0
        contentView.addSubview(threadTitleLabel)
        
        detailLabel.textColor = .darkGray
        detailLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        detailLabel.adjustsFontForContentSizeCategory = true
        contentView.addSubview(detailLabel)
        
        tagLabel.clipsToBounds = true
        tagLabel.layer.cornerRadius = 3
        tagLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        tagLabel.adjustsFontForContentSizeCategory = true
        contentView.addSubview(tagLabel)
        
        threadTitleLabel.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
        }
        
        detailLabel.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(threadTitleLabel.snp.bottom).offset(10)
            make.leading.equalTo(10)
            make.bottom.equalTo(contentView).offset(-10)
        }
        
        tagLabel.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(threadTitleLabel.snp.bottom).offset(10)
            make.leading.equalTo(detailLabel.snp.trailing).offset(10)
            make.bottom.equalTo(contentView).offset(-10)
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
