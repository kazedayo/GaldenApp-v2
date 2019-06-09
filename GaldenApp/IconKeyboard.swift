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
    
    var iconPack: [IconPacks]!
    var segmentedControl: UISegmentedControl!
    var collectionView: UICollectionView!
    weak var keyboardDelegate: IconKeyboardDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let getIconPacksQuery = GetIconPacksQuery()
        apollo.fetch(query: getIconPacksQuery,cachePolicy: .fetchIgnoringCacheData) {
            [weak self] result,error in
            self?.iconPack = result?.data?.installedPacks.map {$0.fragments.iconPacks}
            
            let layout = VerticalBlueprintLayout()
            if UIDevice.current.userInterfaceIdiom == .pad {
                layout.itemsPerRow = 6
            } else {
                layout.itemsPerRow = 4
            }
            layout.sectionInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
            //layout.itemSize = CGSize(width: 100, height: 50)
            
            self?.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            self?.collectionView.backgroundColor = .clear
            self?.collectionView.clipsToBounds = true
            self?.collectionView.delegate = self
            self?.collectionView.dataSource = self
            self?.collectionView.register(IconCollectionViewCell.self, forCellWithReuseIdentifier: "iconCell")
            self?.addSubview((self?.collectionView)!)
            
            let items = self?.iconPack!.compactMap {$0.title}
            self?.segmentedControl = UISegmentedControl(items: items)
            self?.segmentedControl.selectedSegmentIndex = 0
            self?.segmentedControl.tintColor = UIColor(hexRGB: "#568064")
            self?.segmentedControl.addTarget(self, action: #selector(self?.onChange(sender:)), for: .valueChanged)
            self?.addSubview((self?.segmentedControl)!)
            
            self?.collectionView.snp.makeConstraints {
                (make) -> Void in
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            
            self?.segmentedControl.snp.makeConstraints {
                (make) -> Void in
                make.top.equalTo(10)
                make.leading.equalTo(20)
                make.trailing.equalTo(-20)
                make.bottom.equalTo((self?.collectionView.snp.top)!).offset(-10)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconPack![segmentedControl.selectedSegmentIndex].smilies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCell", for: indexPath) as! IconCollectionViewCell
        
        let id = iconPack![segmentedControl.selectedSegmentIndex].id
        let iconid = iconPack![segmentedControl.selectedSegmentIndex].smilies[indexPath.item].id
        cell.iconImage.kf.setImage(with: URL(string: "https://s.hkgalden.org/smilies/\(id)/\(iconid).gif")!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = iconPack![segmentedControl.selectedSegmentIndex].id
        let iconid = iconPack![segmentedControl.selectedSegmentIndex].smilies[indexPath.item].id
        let alt = iconPack![segmentedControl.selectedSegmentIndex].smilies[indexPath.item].alt
        let width = iconPack![segmentedControl.selectedSegmentIndex].smilies[indexPath.item].width
        let height = iconPack![segmentedControl.selectedSegmentIndex].smilies[indexPath.item].height
        keyboardDelegate?.keyWasTapped(character: "<img class=\"icon\" src=\"https://s.hkgalden.org/smilies/\(id)/\(iconid).gif\" data-nodetype=\"smiley\" data-id=\"\(iconid)\" data-pack-id=\"\(id)\" data-sx=\"\(width)\" data-sy=\"\(height)\" data-alt=\"\(alt)\">")
    }
    
    @objc func onChange(sender: UISegmentedControl) {
        collectionView.reloadData()
    }
    
}
