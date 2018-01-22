//
//  ContentViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 2/10/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import JavaScriptCore
import KeychainSwift
import MarqueeLabel
import WebKit
import AXPhotoViewer
import Kingfisher
import PKHUD
import SideMenu
import RealmSwift

class ContentViewController: UIViewController,UIPopoverPresentationControllerDelegate,UINavigationControllerDelegate,WKNavigationDelegate,WKScriptMessageHandler,UISideMenuNavigationControllerDelegate {

    //MARK: Properties
    
    var threadIdReceived: String = ""
    var isRated: String = ""
    var pageNow: Int = 1
    var convertedText: String = ""
    var op = OP(title: "",name: "",level: "",content: "",contentHTML: "",avatar: "",date: "",good: "",bad: "",gender: "",channel: "",quoteID:"",userID:"")
    var comments = [Replies]()
    var replyCount = 1
    var pageCount = 0.0
    var quoteContent = ""
    var blockedUsers = [String]()
    var pageHTML = ""
    var convertedHTML = ""
    var replied = false
    var f5 = false
    var loaded = false
    var scrollPosition: CGFloat = 0.0
    var sender = ""
    private var shadowImageView: UIImageView?
    private var webView = WKWebView()
    
    @IBOutlet weak var containerView: UIView!
    
    //HKGalden API (NOT included in GitHub repo)
    var api = HKGaldenAPI()
    let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeJS()
        navigationController?.delegate = self
        
        let title = MarqueeLabel.init()
        title.textColor = .lightGray
        title.text = self.title
        title.animationDelay = 1
        title.marqueeType = .MLLeftRight
        title.fadeLength = 5
        title.frame = CGRect.init(x: 0, y: 0, width: 500, height: 44)
        title.textAlignment = .center
        navigationItem.titleView = title
        
        self.webView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 65)
        self.webView.isHidden = true
        self.webView.scrollView.showsVerticalScrollIndicator = false
        self.webView.scrollView.showsHorizontalScrollIndicator = false
        self.webView.navigationDelegate = self
        self.containerView.addSubview(webView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContentViewController.handleBBCodeToHTMLNotification(notification:)), name: NSNotification.Name("bbcodeToHTMLNotification"), object: nil)
        
        self.api.pageCount(postId: threadIdReceived, completion: {
            [weak self] count in
            self?.pageCount = count
            let realm = try! Realm()
            let thisPost = realm.object(ofType: History.self, forPrimaryKey: self?.threadIdReceived)
            if thisPost != nil && self?.sender == "cell" {
                self?.pageNow = (thisPost?.page)!
            }
            self?.updateSequence()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let menuRightNavigationController = storyboard!.instantiateViewController(withIdentifier: "ContentSideMenu") as! UISideMenuNavigationController
        SideMenuManager.default.menuRightNavigationController = menuRightNavigationController
        self.webView.configuration.userContentController.add(self, name: "quote")
        self.webView.configuration.userContentController.add(self, name: "block")
        self.webView.configuration.userContentController.add(self, name: "refresh")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let menuRightNavigationController = storyboard!.instantiateViewController(withIdentifier: "RightMenuNavigationController") as! UISideMenuNavigationController
        SideMenuManager.default.menuRightNavigationController = menuRightNavigationController
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "quote")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "block")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "refresh")
        let history = History()
        history.threadID = self.threadIdReceived
        history.page = self.pageNow
        history.position = self.webView.scrollView.contentOffset.y
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(history,update: true)
        }
        //print(realm.objects(History.self))
    }
    
    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {
        let destination = menu.viewControllers.first as! ContentSideMenuViewController
        destination.upvote = Int(self.op.good)!
        destination.downvote = Int(self.op.bad)!
        destination.opName = self.op.name
        destination.threadTitle = self.op.title
        destination.threadID = self.threadIdReceived
        destination.pageCount = Int(self.pageCount)
        destination.pageSelected = self.pageNow
        destination.rated = self.isRated
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func quoteButtonPressed(type: String) {
            if (pageNow == 1 && type == "op") {
            self.api.quote(quoteType: "t", quoteID: self.op.quoteID, completion: {
                [weak self] content in
                self?.quoteContent = content
                self?.performSegue(withIdentifier: "quote", sender: self)
            })
            } else if pageNow == 1 {
                self.api.quote(quoteType: "r", quoteID: self.comments[Int(type)! + 1].quoteID, completion: {
                    [weak self] content in
                    self?.quoteContent = content
                    self?.performSegue(withIdentifier: "quote", sender: self)
                })
            } else {
                self.api.quote(quoteType: "r", quoteID: self.comments[Int(type)!].quoteID, completion: {
                    [weak self] content in
                    self?.quoteContent = content
                    self?.performSegue(withIdentifier: "quote", sender: self)
                })
        }
    }
    
    func blockButtonPressed(type: String) {
        if (pageNow == 1 && type == "op") {
            self.api.blockUser(uid: self.op.userID, completion: {
                [weak self] status in
                if status == "true" {
                    self?.blockedUsers.append((self?.op.userID)!)
                    self?.updateSequence()
                }
            })
        } else if pageNow == 1 {
            self.api.blockUser(uid: self.comments[Int(type)! + 1].userID, completion: {
                [weak self] status in
                if status == "true" {
                    self?.blockedUsers.append((self?.comments[Int(type)! + 1].userID)!)
                    self?.updateSequence()
                }
            })
        } else {
            self.api.blockUser(uid: self.comments[Int(type)!].userID, completion: {
                [weak self] status in
                if status == "true" {
                    self?.blockedUsers.append((self?.comments[Int(type)!].userID)!)
                    self?.updateSequence()
                }
            })
        }
    }
    
    func f5buttonPressed() {
        self.f5 = true
        self.scrollPosition = self.webView.scrollView.contentOffset.y
        self.pageNow = Int(pageCount)
        HUD.show(.progress)
        self.updateSequence()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case "WriteReply"?:
            let destination = segue.destination as! ComposeViewController
            destination.topicID = self.threadIdReceived
            destination.type = "reply"
        case "quote"?:
            let destination = segue.destination as! ComposeViewController
            destination.topicID = self.threadIdReceived
            destination.content = self.quoteContent + "\n"
            destination.type = "reply"
        default:
            break
        }
    }
    
    @IBAction func unwindToContent(segue: UIStoryboardSegue) {
        let sideMenu = segue.source as! ContentSideMenuViewController
        self.pageNow = sideMenu.pageSelected!
        self.api.pageCount(postId: threadIdReceived, completion: {
            [weak self] count in
            self?.pageCount = count
            self?.updateSequence()
        })
    }
    
    @IBAction func unwindAfterReply(segue: UIStoryboardSegue) {
        self.api.pageCount(postId: threadIdReceived, completion: {
            [weak self] count in
            self?.pageCount = count
            self?.pageNow = Int((self?.pageCount)!)
            self?.replied = true
            self?.updateSequence()
        })
    }
    
    //MARK: Private Functions
    
    private func updateSequence() {
        HUD.show(.progress)
        self.webView.isHidden = true
        self.api.fetchContent(postId: threadIdReceived, pageNo: String(pageNow), completion: {
            [weak self] op,comments,rated,blocked,error in
            if (error == nil) {
                self?.op = op
                self?.comments = comments
                self?.blockedUsers = blocked
                self?.isRated = rated
                self?.navigationController?.navigationBar.shadowImage = self?.api.channelColorFunc(ch: (self?.op.channel)!).as1ptImage()
                self?.convertedHTML = ""
                if self?.pageNow == 1 {
                    self?.convertBBCodeToHTML(text: op.content)
                    self?.op.contentHTML = (self?.convertedText)!
                    self?.constructOPHeader()
                    if (self?.blockedUsers.contains((self?.op.userID)!))! {
                        self?.op.contentHTML = "<div class=\"comment\" style=\"text-align:center;color:#454545;\">已封鎖會然</div>"
                    }
                    self?.convertedHTML.append((self?.op.contentHTML)!)
                }
                
                for index in 0..<(self?.comments.count)! {
                    self?.convertBBCodeToHTML(text: comments[index].content)
                    self?.comments[index].contentHTML = (self?.convertedText)!
                    self?.constructCommentHeader(index: index)
                    if (self?.blockedUsers.contains((self?.comments[index].userID)!))! {
                        self?.comments[index].contentHTML = "<div class=\"comment\" style=\"text-align:center;color:#454545;\">已封鎖會然</div>"
                    }
                    self?.convertedHTML.append((self?.comments[index].contentHTML)!)
                }
                
                if(self?.pageNow==Int((self?.pageCount)!)) {
                    self?.convertedHTML.append("<div class=\"refresh\"><button class=\"refresh-button\" onclick=\"window.webkit.messageHandlers.refresh.postMessage('refresh requested')\"></button></div>")
                }
                
                self?.pageHTML = "<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0,user-scalable=no\"><link rel=\"stylesheet\" href=\"content.css\"></head><body>\((self?.convertedHTML)!)</body></html>"
                self?.webView.loadHTMLString((self?.pageHTML)!, baseURL: Bundle.main.bundleURL)
                //print((self?.pageHTML)!)
            }
        })
    }
    
    private func constructOPHeader() {
        let iconArray = ["https://i.imgur.com/PXPXwaRs.jpg","https://i.imgur.com/9AKjGrIs.jpg","https://i.imgur.com/sV2Q22ns.jpg"]
        let randomIndex = Int(arc4random_uniform(UInt32(iconArray.count)))
        if self.op.avatar == "" {
            self.op.contentHTML = self.op.contentHTML.replacingOccurrences(of: "avatarurl", with: iconArray[randomIndex])
        } else {
            self.op.contentHTML = self.op.contentHTML.replacingOccurrences(of: "avatarurl", with: "https://hkgalden.com/\(self.op.avatar)")
        }
        
        if self.op.gender == "male" {
            self.op.contentHTML = self.op.contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">uname</td>", with: "<td class=\"lefttext\" style=\"color:#6495ed;\">\(self.op.name)</td>")
        } else if self.op.gender == "female" {
            self.op.contentHTML = self.op.contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">uname</td>", with: "<td class=\"lefttext\" style=\"color:#ff6961;\">\(self.op.name)</td>")
        }
        
        if self.op.level == "lv1" {
            self.op.contentHTML = self.op.contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">label</td>", with: "<td class=\"lefttext\">普通會然</td>")
        } else if self.op.level == "lv2" {
            self.op.contentHTML = self.op.contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">label</td>", with: "<td class=\"lefttext\" style=\"color:#9e3e3f;\">App Developer</td>")
        } else if self.op.level == "lv3" {
            self.op.contentHTML = self.op.contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">label</td>", with: "<td class=\"lefttext\" style=\"color:#5549c9;\">肉務腸</td>")
        } else if self.op.level == "lv5" {
            self.op.contentHTML = self.op.contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">label</td>", with: "<td class=\"lefttext\" style=\"color:#4b6690;\">鴨免</td>")
        }
        
        self.op.contentHTML = self.op.contentHTML.replacingOccurrences(of: "<td class=\"righttext\">date</td>", with: "<td class=\"righttext\">\(self.op.date)</td>")
        self.op.contentHTML = self.op.contentHTML.replacingOccurrences(of: "<td class=\"righttext\">count</td>", with: "<td class=\"righttext\">OP</td>")
        
        self.op.contentHTML = self.op.contentHTML.replacingOccurrences(of: "quotetype", with: "op")
        self.op.contentHTML = self.op.contentHTML.replacingOccurrences(of: "blocktype", with: "op")
    }
    
    private func constructCommentHeader(index: Int) {
        self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "ratebutton", with: "")
        let iconArray = ["https://i.imgur.com/PXPXwaRs.jpg","https://i.imgur.com/9AKjGrIs.jpg","https://i.imgur.com/sV2Q22ns.jpg"]
        let randomIndex = Int(arc4random_uniform(UInt32(iconArray.count)))
        if self.comments[index].avatar == "" {
            self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "avatarurl", with: iconArray[randomIndex])
        } else {
            self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "avatarurl", with: "https://hkgalden.com/\(self.comments[index].avatar)")
        }
        
        if self.comments[index].gender == "male" {
            self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">uname</td>", with: "<td class=\"lefttext\" style=\"color:#6495ed;\">\(self.comments[index].name)</td>")
        } else if self.comments[index].gender == "female" {
            self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">uname</td>", with: "<td class=\"lefttext\" style=\"color:#ff6961;\">\(self.comments[index].name)</td>")
        }
        
        if self.comments[index].level == "lv1" {
            self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">label</td>", with: "<td class=\"lefttext\">普通會然</td>")
        } else if self.comments[index].level == "lv2" {
            self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">label</td>", with: "<td class=\"lefttext\" style=\"color:#9e3e3f;\">App Developer</td>")
        } else if self.comments[index].level == "lv3" {
            self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">label</td>", with: "<td class=\"lefttext\" style=\"color:#5549c9;\">肉務腸</td>")
        } else if self.comments[index].level == "lv5" {
            self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">label</td>", with: "<td class=\"lefttext\" style=\"color:#4b6690;\">鴨免</td>")
        }
        
        self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "<td class=\"righttext\">date</td>", with: "<td class=\"righttext\">\(self.comments[index].date)</td>")
        self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "<td class=\"righttext\">count</td>", with: "<td class=\"righttext\">#\(String((pageNow-1) * 25 + index + 1))</td>")
        if pageNow == 1 {
            self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "quotetype", with: "\(index - 1)")
            self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "blocktype", with: "\(index - 1)")
        } else {
            self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "quotetype", with: "\(index)")
            self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "blocktype", with: "\(index)")
        }
    }
    
    //MARK: WebView Delegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if replied == true {
            DispatchQueue.main.asyncAfter(deadline: 0.2, execute: {
                webView.evaluateJavaScript("document.body.offsetHeight", completionHandler: {(result, error) in
                    let height = result as! CGFloat
                    let scrollPoint = CGPoint(x: 0, y: height - webView.frame.size.height)
                    webView.scrollView.setContentOffset(scrollPoint, animated: false)
                    self.replied = false
                    HUD.flash(.success, delay: 1.0)
                    self.webView.isHidden = false
                })
            })
        } else if f5 == true {
            DispatchQueue.main.asyncAfter(deadline: 0.2, execute: {
                webView.evaluateJavaScript("document.body.offsetHeight", completionHandler: {(result, error) in
                    let scrollPoint = CGPoint.init(x: 0, y: self.scrollPosition)
                    webView.scrollView.setContentOffset(scrollPoint, animated: false)
                    self.f5 = false
                    HUD.hide()
                    self.webView.isHidden = false
                })
            })
        } else if loaded == false {
            DispatchQueue.main.asyncAfter(deadline: 0.2, execute: {
                let realm = try! Realm()
                let thisPost = realm.object(ofType: History.self, forPrimaryKey: self.threadIdReceived)
                if thisPost != nil && self.sender == "cell" {
                    self.webView.scrollView.setContentOffset(CGPoint.init(x: 0, y: (thisPost?.position)!), animated: false)
                }
                HUD.hide()
                self.webView.isHidden = false
                self.loaded = true
            })
        } else {
            HUD.hide()
            self.webView.isHidden = false
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            if (navigationAction.request.url?.absoluteString.contains("jpg"))! || (navigationAction.request.url?.absoluteString.contains("png"))! || (navigationAction.request.url?.absoluteString.contains("gif"))! || (navigationAction.request.url?.absoluteString.contains("holland.pk"))! {
                let url = navigationAction.request.url
                //open image viewer
                let photo = Photo(url: url)
                let dataSource = PhotosDataSource(photos: [photo])
                let photoViewController = PhotosViewController(dataSource: dataSource)
                
                self.present(photoViewController,animated: true)
                decisionHandler(.cancel)
            } else {
                let url = navigationAction.request.url
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(url!)
                }
                decisionHandler(.cancel)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "quote" {
            self.quoteButtonPressed(type: message.body as! String)
        } else if message.name == "block" {
            let alert = UIAlertController.init(title: "扑柒", message: "你確定要扑柒此會然?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction.init(title: "55", style: .destructive, handler: {
                _ in
                self.blockButtonPressed(type: message.body as! String)
            }))
            alert.addAction(UIAlertAction.init(title: "不了", style: .cancel, handler: nil))
            present(alert,animated: true)
        } else if message.name == "refresh" {
            self.f5buttonPressed()
        }
    }
    
    //regex match function
    private func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    //MARK: JavaScript BBCode Parser Related
    var jsContext: JSContext!
    
    let consoleLog: @convention(block) (String) -> Void = { logMessage in
        print("\nJS Console:", logMessage)
    }
    
    let bbcodeToHTMLHandler: @convention(block) (String) -> Void = { htmlOutput in
        NotificationCenter.default.post(name: NSNotification.Name("bbcodeToHTMLNotification"), object: htmlOutput)
    }
    
    func initializeJS() {
        self.jsContext = JSContext()
        
        // Add an exception handler.
        self.jsContext.exceptionHandler = { context, exception in
            if let exc = exception {
                print("JS Exception:", exc.toString())
            }
        }
        
        let consoleLogObject = unsafeBitCast(self.consoleLog, to: AnyObject.self)
        self.jsContext.setObject(consoleLogObject, forKeyedSubscript: "consoleLog" as (NSCopying & NSObjectProtocol))
        _ = self.jsContext.evaluateScript("consoleLog")
        
        if let jsSourcePath = Bundle.main.path(forResource: "jssource", ofType: "js") {
            do {
                let jsSourceContents = try String(contentsOfFile: jsSourcePath)
                self.jsContext.evaluateScript(jsSourceContents)
                
                
                // Fetch and evaluate the Snowdown script.
                let xbbcodeScript = try String(contentsOfFile: Bundle.main.path(forResource: "xbbcode", ofType: "js")!)
                self.jsContext.evaluateScript(xbbcodeScript)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        let htmlResultsHandler = unsafeBitCast(self.bbcodeToHTMLHandler, to: AnyObject.self)
        self.jsContext.setObject(htmlResultsHandler, forKeyedSubscript: "handleConvertedBBCode" as (NSCopying & NSObjectProtocol))
        _ = self.jsContext.evaluateScript("handleConvertedBBCode")
        
    }
    
    func convertBBCodeToHTML(text: String) {
        if let functionConvertBBCodeToHTML = self.jsContext.objectForKeyedSubscript("convertBBCodeToHTML") {
            _ = functionConvertBBCodeToHTML.call(withArguments: [text])
        }
    }
    
    @objc func handleBBCodeToHTMLNotification(notification: Notification) {
        if let html = notification.object as? String {
            let newContent = "<div class=\"comment\"><div class=\"user\"><div class=\"usertable\" id=\"image\"><table style=\"width:100%\"><tbody><tr><td align=\"center\"><img class=\"avatar\" src=\"avatarurl\"></td></tr></tbody></table></div><div class=\"usertable\" id=\"text\"><table style=\"width:100%;font-size:12px;\"><tbody><tr><td class=\"lefttext\">uname</td><td class=\"righttext\">date</td></tr><tr><td class=\"lefttext\">label</td><td class=\"righttext\">count</td></tr></tbody></table></div></div><div style=\"padding-left:10px;padding-right:10px;\">\(html)</div><div style=\"height:30px;padding-top:20px;\"><div style=\"float:right;\"><table><tbody><tr><td><button class=\"button\" onclick=\"window.webkit.messageHandlers.quote.postMessage('quotetype')\">引用</button></td><td><button class=\"button\" onclick=\"window.webkit.messageHandlers.block.postMessage('blocktype')\">封鎖/舉報</button></td></tr></tbody></table></div></div></div>"
            convertedText = newContent
        }
    }
}
