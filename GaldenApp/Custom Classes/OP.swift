//
//  OP.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 5/10/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit

class OP {
    var title: String
    var name: String
    var level: String
    var content: String
    var contentHTML: String
    var avatar: String
    var date: String
    var good: String
    var bad: String
    var gender: String
    var channel: String
    var quoteID: String
    var userID: String
    
    init(t: String,n: String,l: String,c: String,cH: String,a: String,d: String,gd: String,b: String,ge: String,ch: String,qid: String,uid: String) {
        title = t
        name = n
        level = l
        content = c
        contentHTML = cH
        avatar = a
        date = d
        good = gd
        bad = b
        gender = ge
        channel = ch
        quoteID = qid
        userID = uid
    }
}
