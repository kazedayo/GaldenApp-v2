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

class HKGaldenAPI {
    
    func fetchThreadList(currentChannel: String,pageNumber: String, completion : @escaping (_ threads: [ThreadList],_ blockedUsers: [String], _ error: Error?)->Void) {
        let par: Parameters = ["ident": currentChannel, "ofs": pageNumber]
        let keychain = KeychainSwift()
        let head:HTTPHeaders
        if (keychain.get("userKey") != nil) {
            head = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        } else {
            head = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed"]
        }
        Alamofire.request("https://api.hkgalden.com/f/l", method: .get, parameters: par, headers: head).responseJSON {
            response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                //debug output in console
                //print("JSON: \(json)")
                
                var fetchedContent = [ThreadList]()
                
                for (_,subJson):(String, JSON) in json["topics"] {
                    var topic: String = subJson["tle"].stringValue
                    
                    topic = topic.replacingOccurrences(of: "\n", with: "")
                    
                    let user: String = subJson["uname"].stringValue
                    let rate: String = subJson["rate"].stringValue
                    let reply: String = subJson["count"].stringValue
                    let channel: String = subJson["ident"].stringValue
                    let threadNo: String = subJson["id"].stringValue
                    let userid: String = subJson["uid"].stringValue
                    
                    fetchedContent.append(ThreadList(id: threadNo,ident: channel,title: topic,userName: user, count: reply, rate: rate, userID: userid))
                }
                
                var blockedUsers = [String]()
                
                for (_,subJson):(String, JSON) in json["blockedusers"] {
                    let blockedid = subJson.stringValue
                    blockedUsers.append(blockedid)
                }
                
                completion(fetchedContent,blockedUsers,nil)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchContent(postId: String, pageNo: String, completion : @escaping (_ op: OP,_ comments: [Replies],_ rated: String,_ blockedUsers: [String], _ error: Error?)->Void) {
        let keychain = KeychainSwift()
        let par: Parameters = ["id": postId, "ofs": pageNo]
        var head: HTTPHeaders
        if keychain.get("userKey") != nil {
            head = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        } else {
            head = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed"]
        }
        Alamofire.request("https://api.hkgalden.com/f/t", method: .get, parameters: par, headers: head).responseJSON {
            response in
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
                var content = json["topic"]["content"].stringValue
                
                content = self.sizeTagCorrection(bbcode: content)
                content = self.iconParse(bbcode: content)
                
                let avatar = json["topic"]["avatarurl"].stringValue
                let date = json["topic"]["ctime"].stringValue
                let good = json["topic"]["good"].stringValue
                let bad = json["topic"]["bad"].stringValue
                let gender = json["topic"]["gender"].stringValue
                let channel = json["topic"]["f_ident"].stringValue
                let quoteid = json["topic"]["id"].stringValue
                let userid = json["topic"]["uid"].stringValue
                
                
                let op = OP(title: title,name: name,level: level,content: content,contentHTML: "",avatar: avatar,date: date,good: good,bad: bad,gender: gender,channel: channel,quoteID: quoteid,userID: userid)
                
                //fetch reply data
                for (_,subJson):(String, JSON) in json["replys"] {
                    let name = subJson["uname"].stringValue
                    let level = subJson["badge"].stringValue
                    var content = subJson["content"].stringValue
                    
                    content = self.sizeTagCorrection(bbcode: content)
                    content = self.iconParse(bbcode: content)
                    
                    let avatar = subJson["avatar_url"].stringValue
                    let date = subJson["r_time"].stringValue
                    let gender = subJson["gender"].stringValue
                    let quoteid = subJson["r_id"].stringValue
                    let userid = subJson["uid"].stringValue
                    
                    comments.append(Replies(name: name,level: level,content: content,contentHTML: "",avatar: avatar,date: date,gender: gender,quoteID:quoteid,userID:userid))
                    
                }
                
                var blocked = [String]()
                
                for (_,subJson):(String, JSON) in json["blockeduser"] {
                    let blockedid = subJson.stringValue
                    blocked.append(blockedid)
                }
                
                let rated = json["rated"].stringValue
                
                completion(op,comments,rated,blocked,nil)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping ()->() ) {
        let par = ["dname": "1080-SIGNAL User", "email": email, "password": password, "appid": "74", "deviceid": UIDevice.current.identifierForVendor!.uuidString]
        let head: HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed"]
        Alamofire.request("https://api.hkgalden.com/u/authorize", method: .post, parameters: par, headers: head).response {
            response in
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
        Alamofire.request("https://api.hkgalden.com/u/check", method: .get,headers: head).responseJSON {
            response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let userName = json["data"]["user"]["username"].stringValue
                let id = json["data"]["user"]["id"].stringValue
                completion(userName,id)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func logout(completion: @escaping ()->() ) {
        let keychain = KeychainSwift()
        let par = ["did": UIDevice.current.identifierForVendor!.uuidString]
        let head:HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        Alamofire.request("https://api.hkgalden.com/u/unreg",method:.get,parameters:par,headers:head).response {
            response in
            keychain.delete("userKey")
            completion()
        }
    }
    
    func reply(topicID: String, content: String, completion: @escaping ()->Void ) {
        let keychain = KeychainSwift()
        let par = ["t_id": topicID,"content": content]
        let head:HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        Alamofire.request("https://api.hkgalden.com/f/r",method:.post,parameters:par,headers:head).response {
            response in
            completion()
        }
    }
    
    func submitPost(channel: String, title: String, content: String, completion: @escaping ()->Void ) {
        let keychain = KeychainSwift()
        let par = ["title": title, "content": content, "ident": channel]
        let head:HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        Alamofire.request("https://api.hkgalden.com/f/t",method:.post,parameters:par,headers:head).response {
            response in
            completion()
        }
    }
    
    func quote(quoteType: String, quoteID: String, completion: @escaping (_ content: String)->Void ) {
        let keychain = KeychainSwift()
        let par = ["q_type": quoteType, "q_id": quoteID]
        let head:HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        Alamofire.request("https://api.hkgalden.com/f/q",method:.get,parameters:par,headers:head).responseJSON {
            response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let content = json["data"]["ctnt"].stringValue
                completion(content)
            case .failure(let error):
                print(error)
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
    
    func getBlockedUsers(completion: @escaping (_ blocked: [BlockedUsers])-> Void) {
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
                
                completion(blockedUsers)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func channelNameFunc(ch: String) -> String {
        switch ch {
        case "bw":
            return "吹水臺"
        case "et":
            return "娛樂臺"
        case "ca":
            return "時事臺"
        case "fn":
            return "財經臺"
        case "gm":
            return "遊戲臺"
        case "ap":
            return "App臺"
        case "it":
            return "科技臺"
        case "mp":
            return "電話臺"
        case "sp":
            return "體育臺"
        case "lv":
            return "感情臺"
        case "sy":
            return "講故臺"
        case "ed":
            return "飲食臺"
        case "to":
            return "玩具臺"
        case "tr":
            return "旅遊臺"
        case "an":
            return "動漫臺"
        case "dc":
            return "攝影臺"
        case "mu":
            return "音樂臺"
        case "vi":
            return "影視臺"
        case "mb":
            return "站務臺"
        case "st":
            return "學術臺"
        case "ts":
            return "汽車臺"
        case "ep":
            return "創意臺"
        case "ia":
            return "內務臺"
        case "ac":
            return "活動臺"
        case "tm":
            return "番茄臺"
        default:
            return ""
        }
    }
    
    func channelColorFunc(ch: String) -> UIColor {
        switch ch {
        case "bw":
            return UIColor(red: 72/255, green: 125/255, blue: 174/255, alpha: 1)
        case "et":
            return UIColor(red: 152/255, green: 85/255, blue: 159/255, alpha: 1)
        case "ca":
            return UIColor(red: 33/255, green: 136/255, blue: 101/255, alpha: 1)
        case "fn":
            return UIColor(red: 33/255, green: 136/255, blue: 101/255, alpha: 1)
        case "gm":
            return UIColor(red: 37/255, green: 124/255, blue: 201/255, alpha: 1)
        case "ap":
            return UIColor(red: 41/255, green: 145/255, blue: 185/255, alpha: 1)
        case "it":
            return UIColor(red: 94/255, green: 106/255, blue: 125/255, alpha: 1)
        case "mp":
            return UIColor(red: 88/255, green: 100/255, blue: 174/255, alpha: 1)
        case "sp":
            return UIColor(red: 152/255, green: 64/255, blue: 81/255, alpha: 1)
        case "lv":
            return UIColor(red: 196/255, green: 53/255, blue: 94/255, alpha: 1)
        case "sy":
            return UIColor(red: 127/255, green: 112/255, blue: 106/255, alpha: 1)
        case "ed":
            return UIColor(red: 65/255, green: 143/255, blue: 66/255, alpha: 1)
        case "to":
            return UIColor(red: 148/255, green: 95/255, blue: 50/255, alpha: 1)
        case "tr":
            return UIColor(red: 97/255, green: 118/255, blue: 83/255, alpha: 1)
        case "an":
            return UIColor(red: 171/255, green: 80/255, blue: 159/255, alpha: 1)
        case "dc":
            return UIColor(red: 56/255, green: 102/255, blue: 118/255, alpha: 1)
        case "mu":
            return UIColor(red: 88/255, green: 95/255, blue: 202/255, alpha: 1)
        case "vi":
            return UIColor(red: 121/255, green: 78/255, blue: 126/255, alpha: 1)
        case "mb":
            return UIColor(red: 124/255, green: 89/255, blue: 196/255, alpha: 1)
        case "st":
            return UIColor(red: 128/255, green: 113/255, blue: 143/255, alpha: 1)
        case "ts":
            return UIColor(red: 172/255, green: 48/255, blue: 66/255, alpha: 1)
        case "ep":
            return UIColor(red: 152/255, green: 112/255, blue: 93/255, alpha: 1)
        case "ia":
            return UIColor(red: 132/255, green: 169/255, blue: 64/255, alpha: 1)
        case "ac":
            return UIColor(red: 150/255, green: 75/255, blue: 112/255, alpha: 1)
        case "tm":
            return UIColor(red: 190/255, green: 71/255, blue: 30/255, alpha: 1)
        default:
            return UIColor.black
        }
    }
    
    func pageCount(postId: String, completion : @escaping (_ pageCount: Double)->Void) {
        var pageCount: Double = 0.0
        
        let par: Parameters = ["id": postId]
        let head: HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed"]
        Alamofire.request("https://api.hkgalden.com/f/t", method: .get, parameters: par, headers: head).responseJSON {
            response in
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
            }
        }
    }
    
    func sizeTagCorrection(bbcode: String) -> String {
        var code = bbcode
        code = code.replacingOccurrences(of: "[/size=1]", with: "[/size]")
        code = code.replacingOccurrences(of: "[/size=2]", with: "[/size]")
        code = code.replacingOccurrences(of: "[/size=3]", with: "[/size]")
        code = code.replacingOccurrences(of: "[/size=4]", with: "[/size]")
        code = code.replacingOccurrences(of: "[/size=5]", with: "[/size]")
        code = code.replacingOccurrences(of: "[/size=6]", with: "[/size]")
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
            }
        })
    }
    
    func blockUser(uid: String,completion: @escaping (_ status: String)->Void) {
        let keychain = KeychainSwift()
        let head:HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        let par = ["bid": uid]
        Alamofire.request("https://api.hkgalden.com/f/bi", method: .post, parameters: par, headers: head).responseJSON {
            response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let status = json["status"].stringValue
                completion(status)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func changeName(name: String,completion: @escaping (_ status: String,_ newName: String)->Void) {
        let keychain = KeychainSwift()
        let head:HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        let par = ["name": name]
        Alamofire.request("https://api.hkgalden.com/u/changename",method:.post,parameters:par,headers:head).responseJSON {
            response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let status = json["status"].stringValue
                let newName = json["data"]["username"].stringValue
                completion(status,newName)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func unblockUser(uid: String,completion: @escaping (_ status: String,_ userName:String)->Void) {
        let keychain = KeychainSwift()
        let head:HTTPHeaders = ["X-GALAPI-KEY": "6ff50828528b419ab5b5a3de1e5ea3b5e3cd4bed", "X-GALUSER-KEY": keychain.get("userKey")!]
        let par = ["bid": uid]
        Alamofire.request("https://api.hkgalden.com/f/bu",method:.post,parameters:par,headers:head).responseJSON {
            response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                let status = json["status"].stringValue
                let uname = json["unblocked"]["username"].stringValue
                completion(status,uname)
            case .failure(let error):
                print(error)
                completion("","")
            }
        }
    }
}
