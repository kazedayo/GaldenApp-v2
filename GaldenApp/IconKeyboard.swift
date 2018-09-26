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
    
    var segmentedControl: UISegmentedControl!
    var collectionView: UICollectionView!
    weak var keyboardDelegate: IconKeyboardDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layout = VerticalBlueprintLayout()
        layout.itemsPerRow = 3
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 100, height: 50)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(IconCollectionViewCell.self, forCellWithReuseIdentifier: "iconCell")
        addSubview(collectionView)
        
        let items = iconPack!.compactMap {$0.title}
        segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(onChange(sender:)), for: .valueChanged)
        addSubview(segmentedControl)
        
        collectionView.snp.makeConstraints {
            (make) -> Void in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        segmentedControl.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(10)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.bottom.equalTo(collectionView.snp.top).offset(-10)
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
