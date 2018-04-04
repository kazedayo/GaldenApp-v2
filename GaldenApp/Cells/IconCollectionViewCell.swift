//
//  IconCollectionViewCell.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 4/4/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import UIKit

class IconCollectionViewCell: UICollectionViewCell {
    
    let iconImage = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        
        iconImage.contentMode = .center
        contentView.addSubview(iconImage)
        
        iconImage.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(contentView).offset(10)
            make.bottom.equalTo(contentView).offset(-10)
            make.leading.equalTo(contentView).offset(10)
            make.trailing.equalTo(contentView).offset(-10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
