//
//  Thread.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 3/12/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import Foundation
import SwiftDate
import RealmSwift

struct Thread {
    let id: Int
    let title: String
    let nickName: String
    let count: Int
    let date: String
    let tagName: String
    let tagColor: String
    var newReplyCount: String
    
    init(id: Int,title: String,nick: String,count: Int,date: String, tag: String, tagC: String) {
        self.id = id
        self.title = title
        self.nickName = nick
        self.count = count
        self.date = (date.toISODate()?.toRelative(since: DateInRegion(), style: RelativeFormatter.twitterStyle(), locale: Locales.chineseTaiwan))!
        self.tagName = tag
        self.tagColor = tagC
        self.newReplyCount = ""
        let realm = try! Realm()
        let readThreads = realm.object(ofType: History.self, forPrimaryKey: id)
        if (readThreads != nil) {
            let newReply = count-readThreads!.replyCount
            if newReply > 0 {
                newReplyCount = String(newReply)
            }
        }
    }
}
