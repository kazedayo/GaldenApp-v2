//
//  History.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 12/1/2018.
//  Copyright © 2018年 1080@galden. All rights reserved.
//

import RealmSwift

class History: Object {
    @objc dynamic var threadID = ""
    @objc dynamic var page = 1
    @objc dynamic var position = ""
    
    override static func primaryKey() -> String? {
        return "threadID"
    }
}
