//
//  HKGaldenAPI.swift
//  GaldenApp
//
//  Created by 1080 on 30/9/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift
import PKHUD
import SwiftEntryKit

class HKGaldenAPI {
    
    static let shared = HKGaldenAPI()
    var chList: [JSON]?
    
    
    func login(email: String, password: String, completion: @escaping ()->() ) {
        let par = ["dname": "1080-SIGNAL User", "email": email, "password": password, "appid": "74", "deviceid": UIDevice.current.identifierForVendor!.uuidString]
        let head: HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed"]
        NetworkActivityIndicatorManager.networkOperationStarted()
        Alamofire.request("https://api.hkgalden.com/u/authorize", method: .post, parameters: par, headers: head).response {
            response in
            NetworkActivityIndicatorManager.networkOperationFinished()
            var userKey = response.response?.url?.absoluteString
            userKey = userKey?.replacingOccurrences(of: "https://api.hkgalden.com/auth/authorized?u=", with: "")
            let keychain = KeychainSwift()
            keychain.set(userKey!, forKey: "userKey")
            completion()
        }
    }
    
    func getUserDetail(completion: @escaping (_ uname: String, _ uid: String)->Void) {
        let keychain = KeychainSwift()
        let head: HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        NetworkActivityIndicatorManager.networkOperationStarted()
        Alamofire.request("https://api.hkgalden.com/u/check", method: .get,headers: head).responseJSON {
            response in
            NetworkActivityIndicatorManager.networkOperationFinished()
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let userName = json["data"]["user"]["username"].stringValue
                let id = json["data"]["user"]["id"].stringValue
                completion(userName,id)
            case .failure(let error):
                print(error)
                self.showError(error: error)
            }
        }
    }
    
    func logout(completion: @escaping ()->() ) {
        let keychain = KeychainSwift()
        let par = ["did": UIDevice.current.identifierForVendor!.uuidString]
        let head:HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        NetworkActivityIndicatorManager.networkOperationStarted()
        Alamofire.request("https://api.hkgalden.com/u/unreg",method:.get,parameters:par,headers:head).response {
            response in
            NetworkActivityIndicatorManager.networkOperationFinished()
            keychain.delete("userKey")
            completion()
        }
    }
    
    func reply(topicID: String, content: String, completion: @escaping (_ error: Error?)->Void ) {
        let keychain = KeychainSwift()
        let par = ["t_id": topicID,"content": content]
        let head:HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        NetworkActivityIndicatorManager.networkOperationStarted()
        Alamofire.request("https://api.hkgalden.com/f/r",method:.post,parameters:par,headers:head).response {
            response in
            NetworkActivityIndicatorManager.networkOperationFinished()
            if response.error != nil {
                completion(response.error)
                HUD.hide()
                self.showError(error: response.error!)
            } else {
                HUD.flash(.success,delay:1)
                completion(nil)
            }
        }
    }
    
    func submitPost(channel: String, title: String, content: String, completion: @escaping (_ error: Error?)->Void ) {
        let keychain = KeychainSwift()
        let par = ["title": title, "content": content, "ident": channel]
        let head:HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        NetworkActivityIndicatorManager.networkOperationStarted()
        Alamofire.request("https://api.hkgalden.com/f/t",method:.post,parameters:par,headers:head).response {
            response in
            NetworkActivityIndicatorManager.networkOperationFinished()
            if response.error != nil {
                completion(response.error)
                self.showError(error: response.error!)
            } else {
                completion(nil)
            }
        }
    }
    
    func rate(threadID: String, rate: String, completion: @escaping () -> Void) {
        let keychain = KeychainSwift()
        let par = ["t_id": threadID, "r": rate]
        let head:HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        Alamofire.request("https://api.hkgalden.com/f/rate",method:.post,parameters:par,headers:head)
        completion()
    }
    
    /*func getBlockedUsers(completion: @escaping ()-> Void) {
        let keychain = KeychainSwift()
        let head:HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        Alamofire.request("https://api.hkgalden.com/f/b",method:.get,headers:head).responseJSON {
            response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var blockedUsers = [BlockedUsers]()
                
                for (_,subJson):(String, JSON) in json["blocklist"] {
                    let id = subJson["id"].stringValue
                    let name = subJson["username"].stringValue
                    
                    blockedUsers.append(BlockedUsers(id: id,userName: name))
                }
                
                self.blockList = blockedUsers
                completion()
            case .failure(let error):
                print(error)
                HUD.flash(.labeledError(title: "網絡錯誤", subtitle: nil), delay: 1)
            }
        }
    }*/
    
    func pageCount(postId: String, completion : @escaping (_ pageCount: Double)->Void) {
        var pageCount: Double = 0.0
        
        let par: Parameters = ["id": postId]
        let head: HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed"]
        NetworkActivityIndicatorManager.networkOperationStarted()
        Alamofire.request("https://api.hkgalden.com/f/t", method: .get, parameters: par, headers: head).responseJSON {
            response in
            NetworkActivityIndicatorManager.networkOperationFinished()
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let replies = json["topic"]["count"].doubleValue
                pageCount = ceil(replies/25.0)
                if (pageCount == 0.0) {
                    pageCount = 1.0
                }
                completion(pageCount)
            case .failure(let error):
                print(error)
                self.showError(error: error)
            }
        }
    }
    
    func sizeTagCorrection(bbcode: String) -> String {
        var code = bbcode
        code = code.replacingOccurrences(of: "/size=1", with: "/size")
        code = code.replacingOccurrences(of: "/size=2", with: "/size")
        code = code.replacingOccurrences(of: "/size=3", with: "/size")
        code = code.replacingOccurrences(of: "/size=4", with: "/size")
        code = code.replacingOccurrences(of: "/size=5", with: "/size")
        code = code.replacingOccurrences(of: "/size=6", with: "/size")
        return code
    }
    
    let iconName: [String] = ["[369]","#adore#","#yup#","O:-)",":-[","#ass#","[banghead]",":D","[bomb]","[bouncer]","[bouncy]","#bye#","[censored]","#cn#",":o)",":~(","xx(",":-]","#ng#","#fire#","[flowerface]",":-(","fuck","@_@","#good#","#hehe#","#hoho#","#kill2#","#kill#","^3^","#love#","#no#","[offtopic]",":O","[photo]","[shocking]","[slick]",":)","[sosad]","#oh#",":P",";-)","???","?_?","[yipes]","Z_Z","#lol#"]
    
    let iconURL: [String] = ["369","adore","agree","angel","angry","ass","banghead","biggrin","bomb","bouncer","bouncy","bye","censored","chicken","clown","cry","dead","devil","donno","fire","flowerface","frown","fuck","@","good","hehe","hoho","kill2","kill","kiss","love","no","offtopic","oh","photo","shocking","slick","smile","sosad","surprise","tongue","wink","wonder2","wonder","yipes","z","lol"]
    
    func iconParse(bbcode: String) -> String {
        var code = bbcode
        for index in 0..<iconName.count {
            code = code.replacingOccurrences(of: iconName[index], with: "[icon]http://hkgalden.com/face/hkg/" + iconURL[index] + ".gif[/icon]")
            }
        return code
    }
    
    func imageUpload(imageURL: URL,completion: @escaping (_ url: String)->Void) {
        Alamofire.upload(multipartFormData: {
            multipartFormData in
            multipartFormData.append(imageURL, withName: "file")
        }, to: "https://img.eservice-hk.net/api.php?version=2", encodingCompletion: {
            encodingResult in
            switch encodingResult {
            case .success(let upload,_,_):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let url = json["url"].stringValue
                        completion(url)
                    case .failure(let error):
                        print(error)
                        completion("")
                    }
                }
            case .failure(let error):
                print(error)
                self.showError(error: error)
            }
        })
    }
    
    func blockUser(uid: String,completion: @escaping (_ status: String)->Void) {
        let keychain = KeychainSwift()
        let head:HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        let par = ["bid": uid]
        NetworkActivityIndicatorManager.networkOperationStarted()
        Alamofire.request("https://api.hkgalden.com/f/bi", method: .post, parameters: par, headers: head).responseJSON {
            response in
            NetworkActivityIndicatorManager.networkOperationFinished()
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let status = json["status"].stringValue
                completion(status)
            case .failure(let error):
                print(error)
                self.showError(error: error)
            }
        }
    }
    
    func changeName(name: String,completion: @escaping (_ status: String,_ newName: String)->Void) {
        let keychain = KeychainSwift()
        let head:HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        let par = ["name": name]
        NetworkActivityIndicatorManager.networkOperationStarted()
        Alamofire.request("https://api.hkgalden.com/u/changename",method:.post,parameters:par,headers:head).responseJSON {
            response in
            NetworkActivityIndicatorManager.networkOperationFinished()
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let status = json["status"].stringValue
                let newName = json["data"]["username"].stringValue
                completion(status,newName)
            case .failure(let error):
                print(error)
                self.showError(error: error)
            }
        }
    }
    
    /*func unblockUser(uid: String,completion: @escaping (_ status: String,_ userName:String)->Void) {
        let keychain = KeychainSwift()
        let head:HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        let par = ["bid": uid]
        Alamofire.request("https://api.hkgalden.com/f/bu",method:.post,parameters:par,headers:head).responseJSON {
            response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                //print(json)
                let status = json["status"].stringValue
                let uname = json["unblocked"]["username"].stringValue
                completion(status,uname)
            case .failure(let error):
                print(error)
                HUD.flash(.labeledError(title: "網絡錯誤", subtitle: nil), delay: 1)
            }
        }
    }*/
    
    func getChannelList(completion: @escaping()->Void) {
        let head:HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed"]
        NetworkActivityIndicatorManager.networkOperationStarted()
        Alamofire.request("https://api.hkgalden.com/f/",headers:head).responseJSON {
            response in
            NetworkActivityIndicatorManager.networkOperationFinished()
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                //print(json)
                let chList = json["lists"].array
                self.chList = chList
                completion()
            case .failure(let error):
                print(error)
                self.showError(error: error)
            }
        }
    }
    
    private func showError(error: Error) {
        var attributes = EKAttributes.bottomFloat
        attributes.entryBackground = .color(color: UIColor(hexRGB: "f44336")!)
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        
        let title = EKProperty.LabelContent(text: "網絡錯誤", style: .init(font: UIFont.systemFont(ofSize: 15), color: .white))
        let description = EKProperty.LabelContent(text: error.localizedDescription, style: .init(font: UIFont.systemFont(ofSize: 12), color: .white))
        let image = EKProperty.ImageContent(image: UIImage(named: "error")!, size: CGSize(width: 35, height: 35))
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
}
