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
    
    func fetchThreadList(currentChannel: String,pageNumber: String, completion : @escaping (_ threads: [ThreadList], _ error: Error?)->Void) {
        let par: Parameters = ["ident": currentChannel, "ofs": pageNumber]
        let keychain = KeychainSwift()
        let head:HTTPHeaders
        if (keychain.get("userKey") != nil) {
            head = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        } else {
            head = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed"]
        }
        NetworkActivityIndicatorManager.networkOperationStarted()
        Alamofire.request("https://api.hkgalden.com/f/l", method: .get, parameters: par, headers: head).responseJSON {
            response in
            NetworkActivityIndicatorManager.networkOperationFinished()
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                //debug output in console
                //print("JSON: \(json)")
                
                var blockedUsers = [String]()
                
                for (_,subJson):(String, JSON) in json["blockedusers"] {
                    let blockedid = subJson.stringValue
                    blockedUsers.append(blockedid)
                }
                
                var fetchedContent = [ThreadList]()
                
                for (_,subJson):(String, JSON) in json["topics"] {
                    var topic: String = subJson["tle"].stringValue
                    topic = topic.replacingOccurrences(of: "\n", with: "")
                    var user: String = subJson["uname"].stringValue
                    user = user.replacingOccurrences(of: "\n", with: "")
                    let rate: String = subJson["rate"].stringValue
                    let reply: Int = subJson["count"].intValue
                    let channel: String = subJson["ident"].stringValue
                    let threadNo: String = subJson["id"].stringValue
                    let userid: String = subJson["uid"].stringValue
                    var isBlocked: Bool = false
                    if (blockedUsers.contains(subJson["uid"].stringValue)) {
                        isBlocked = true
                    }
                    fetchedContent.append(ThreadList(id: threadNo,ident: channel,title: topic,userName: user, count: reply, rate: rate, userID: userid,isBlocked: isBlocked))
                }
                
                completion(fetchedContent,nil)
                
            case .failure(let error):
                print(error)
                self.showError(error: error)
                completion([ThreadList](),error)
            }
        }
    }
    
    func fetchContent(postId: String, pageNo: String, completion : @escaping (_ op: OP?,_ comments: [Replies]?,_ rated: Bool?,_ blockedUsers: [String]?,_ poll: Poll?, _ error: Error?)->Void) {
        let keychain = KeychainSwift()
        let par: Parameters = ["id": postId, "ofs": pageNo]
        var head: HTTPHeaders
        if keychain.get("userKey") != nil {
            head = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        } else {
            head = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed"]
        }
        NetworkActivityIndicatorManager.networkOperationStarted()
        Alamofire.request("https://api.hkgalden.com/f/t", method: .get, parameters: par, headers: head).responseJSON {
            response in
            NetworkActivityIndicatorManager.networkOperationFinished()
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                var comments = [Replies]()
                //debug output in console
                //print("JSON: \(json)")
                
                //fetch OP data
                let title = json["topic"]["title"].stringValue
                let name = json["topic"]["uname"].stringValue
                let level = json["topic"]["badge"].stringValue
                let contentOriginal = json["topic"]["content"].stringValue
                
                var content = self.sizeTagCorrection(bbcode: contentOriginal)
                content = self.iconParse(bbcode: content)
                
                let avatar = json["topic"]["avatarurl"].stringValue
                let date = json["topic"]["ctime"].stringValue
                let good = json["topic"]["good"].stringValue
                let bad = json["topic"]["bad"].stringValue
                let gender = json["topic"]["gender"].stringValue
                let channel = json["topic"]["f_ident"].stringValue
                let userid = json["topic"]["uid"].stringValue
                let ident = json["topic"]["f_ident"].stringValue
                let count = json["topic"]["count"].intValue
                
                let op = OP(title: title,name: name,level: level,content: content,contentHTML: "",contentOriginal: contentOriginal,avatar: avatar,date: date,good: good,bad: bad,gender: gender,channel: channel,userID: userid,ident: ident,count: count)
                
                //fetch reply data
                for (_,subJson):(String, JSON) in json["replys"] {
                    let name = subJson["uname"].stringValue
                    let level = subJson["badge"].stringValue
                    let contentOriginal = subJson["content"].stringValue
                    
                    var content = self.sizeTagCorrection(bbcode: contentOriginal)
                    content = self.iconParse(bbcode: content)
                    
                    let avatar = subJson["avatar_url"].stringValue
                    let date = subJson["r_time"].stringValue
                    let gender = subJson["gender"].stringValue
                    let userid = subJson["uid"].stringValue
                    
                    comments.append(Replies(name: name,level: level,content: content,contentHTML: "",contentOriginal: contentOriginal,avatar: avatar,date: date,gender: gender,userID:userid))
                    
                }
                
                var blocked = [String]()
                
                for (_,subJson):(String, JSON) in json["blockeduser"] {
                    let blockedid = subJson.stringValue
                    blocked.append(blockedid)
                }
                
                let rated = json["rated"].boolValue
                
                let pollid = json["polls"]["p_id"].stringValue
                let optionString = json["polls"]["options"].stringValue
                var options = [String:String]()
                if optionString != "" {
                    if let dataFromString = optionString.data(using: .utf8, allowLossyConversion: false) {
                        let json = try! JSON(data: dataFromString)
                        options = json.dictionaryObject! as! [String:String]
                    }
                }
                let maxchoice = json["polls"]["max_choice"].intValue
                let pollleak = json["polls"]["poll_leak"].intValue
                let ended = json["polls"]["ended"].intValue
                
                let poll = Poll(pollID: pollid,options: options,maxChoice: maxchoice,pollleak: pollleak,ended: ended)
                
                completion(op,comments,rated,blocked,poll,nil)
                
            case .failure(let error):
                print(error)
                self.showError(error: error)
                completion(nil,nil,nil,nil,nil,error)
            }
        }
    }
    
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
