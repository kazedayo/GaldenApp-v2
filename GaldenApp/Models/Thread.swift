//
//  Thread.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 3/12/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import Foundation
import SwiftDate

struct Thread {
    let id: Int
    let title: String
    let nickName: String
    let count: Int
    let date: String
    let tagName: String
    let tagColor: String
    
    init(id: Int,title: String,nick: String,count: Int,date: String, tag: String, tagC: String) {
        self.id = id
        self.title = title
        self.nickName = nick
        self.count = count
        self.date = (date.toISODate()?.toRelative(since: DateInRegion(), style: RelativeFormatter.twitterStyle(), locale: Locales.english))!
        self.tagName = tag
        self.tagColor = tagC
    }
}
