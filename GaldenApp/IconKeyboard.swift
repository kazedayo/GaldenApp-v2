//
//  IconKeyboard.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 10/11/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import Kingfisher
import Blueprints

protocol IconKeyboardDelegate: class {
    func keyWasTapped(character: String)
}

class IconKeyboard: UIView,UICollectionViewDelegate,UICollectionViewDataSource {
    
    let iconCode = ["[369]","#adore#","#yup#","O:-)",":-[","#ass#","[banghead]",":D","[bomb]","[bouncer]","[bouncy]","#bye#","[censored]","#cn#",":o)",":~(","xx(",":-]","#ng#","#fire#","[flowerface]",":-(","fuck","@_@","#good#","#hehe#","#hoho#","#kill#","#kill2#","^3^","#love#","#no#","[offtopic]",":O","[photo]","[shocking]","[slick]",":)","[sosad]","#oh#",":P",";-)","?_?","???","[yipes]","Z_Z","#lol#"]
    let iconUrl = ["369","adore","agree","angel","angry","ass","banghead","biggrin","bomb","bouncer","bouncy","bye","censored","chicken","clown","cry","dead","devil","donno","fire","flowerface","frown","fuck","@","good","hehe","hoho","kill","kill2","kiss","love","no","offtopic","oh","photo","shocking","slick","smile","sosad","surprise","tongue","wink","wonder","wonder2","yipes","z","lol"].map({URL(string:"https://hkgalden.com/face/hkg/\($0).gif")!})
    weak var keyboardDelegate: IconKeyboardDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layout = VerticalBlueprintLayout()
        layout.itemsPerRow = 3
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        if #available(iOS 10.0, *) {
            layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        } else {
            // Fallback on earlier versions
            layout.estimatedItemSize = CGSize(width: 50, height: 50)
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .darkGray
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(IconCollectionViewCell.self, forCellWithReuseIdentifier: "iconCell")
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconCode.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCell", for: indexPath) as! IconCollectionViewCell
        
        cell.iconImage.kf.setImage(with: iconUrl[indexPath.item])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        keyboardDelegate?.keyWasTapped(character: iconCode[indexPath.item])
    }
    
}
