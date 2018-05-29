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
        navigator.register("https://hkgalden.com/view/<string:id>") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? String else {return nil}
            contentVC.threadIdReceived = id
            return contentVC
        }
        navigator.register("http://hkgalden.com/view/<string:id>") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? String else {return nil}
            contentVC.threadIdReceived = id
            return contentVC
        }
        navigator.register("hkgalden.com/view/<string:id>") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? String else {return nil}
            contentVC.threadIdReceived = id
            return contentVC
        }
        navigator.register("https://hkgalden.com/view/<string:id>/page") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? String else {return nil}
            contentVC.threadIdReceived = id
            return contentVC
        }
        navigator.register("http://hkgalden.com/view/<string:id>/page") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? String else {return nil}
            contentVC.threadIdReceived = id
            return contentVC
        }
        navigator.register("hkgalden.com/view/<string:id>/page") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? String else {return nil}
            contentVC.threadIdReceived = id
            return contentVC
        }
        navigator.register("https://hkgalden.com/view/<string:id>/page/<int:page>") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? String else {return nil}
            guard let page = values["page"] as? Int else {return nil}
            contentVC.threadIdReceived = id
            contentVC.pageNow = page
            return contentVC
        }
        navigator.register("http://hkgalden.com/view/<string:id>/page/<int:page>") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? String else {return nil}
            guard let page = values["page"] as? Int else {return nil}
            contentVC.threadIdReceived = id
            contentVC.pageNow = page
            return contentVC
        }
        navigator.register("hkgalden.com/view/<string:id>/page/<int:page>") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? String else {return nil}
            guard let page = values["page"] as? Int else {return nil}
            contentVC.threadIdReceived = id
            contentVC.pageNow = page
            return contentVC
        }
        navigator.register("https://hkgalden.com/view/<string:id>/page/<int:page>/highlight/") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? String else {return nil}
            guard let page = values["page"] as? Int else {return nil}
            contentVC.threadIdReceived = id
            contentVC.pageNow = page
            return contentVC
        }
        navigator.register("http://hkgalden.com/view/<string:id>/page/<int:page>/highlight/") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? String else {return nil}
            guard let page = values["page"] as? Int else {return nil}
            contentVC.threadIdReceived = id
            contentVC.pageNow = page
            return contentVC
        }
        navigator.register("hkgalden.com/view/<string:id>/page/<int:page>/highlight/") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? String else {return nil}
            guard let page = values["page"] as? Int else {return nil}
            contentVC.threadIdReceived = id
            contentVC.pageNow = page
            return contentVC
        }
        navigator.register("https://hkgalden.com/view/<string:id>/page/<int:page>/highlight/<string:uid>") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? String else {return nil}
            guard let page = values["page"] as? Int else {return nil}
            contentVC.threadIdReceived = id
            contentVC.pageNow = page
            return contentVC
        }
        navigator.register("http://hkgalden.com/view/<string:id>/page/<int:page>/highlight/<string:uid>") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? String else {return nil}
            guard let page = values["page"] as? Int else {return nil}
            contentVC.threadIdReceived = id
            contentVC.pageNow = page
            return contentVC
        }
        navigator.register("hkgalden.com/view/<string:id>/page/<int:page>/highlight/<string:uid>") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? String else {return nil}
            guard let page = values["page"] as? Int else {return nil}
            contentVC.threadIdReceived = id
            contentVC.pageNow = page
            return contentVC
        }
        navigator.register("https://hkgalden.com/view/<string:id>/highlight/<string:uid>") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? String else {return nil}
            contentVC.threadIdReceived = id
            return contentVC
        }
        navigator.register("http://hkgalden.com/view/<string:id>/highlight/<string:uid>") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? String else {return nil}
            contentVC.threadIdReceived = id
            return contentVC
        }
        navigator.register("hkgalden.com/view/<string:id>/highlight/<string:uid>") {
            url, values, context in
            let contentVC = ContentViewController()
            guard let id = values["id"] as? String else {return nil}
            contentVC.threadIdReceived = id
            return contentVC
        }
    }
}
