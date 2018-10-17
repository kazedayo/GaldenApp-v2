//
//  URLNavigationMap.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 8/4/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import Foundation
import URLNavigator

struct URLNavigationMap {
    static func initialize(navigator: NavigatorType) {
        //url with page number
        navigator.register("https://hkgalden.org/forum/thread/<int:id>/<int:page>") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? Int else {return nil}
            guard let page = values["page"] as? Int else {return nil}
            contentVC.tID = id
            contentVC.pageNow = page
            return contentVC
        }
        
        //url without page number
        navigator.register("https://hkgalden.org/forum/thread/<int:id>") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? Int else {return nil}
            contentVC.tID = id
            return contentVC
        }
    }
}
