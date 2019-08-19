//
//  ContentViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 2/10/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import MarqueeLabel
import WebKit
import RealmSwift
import Kingfisher
import SKPhotoBrowser
import SwiftEntryKit
import SwiftSoup
import SwiftDate
import SafariServices
import Foundation

class ContentViewController: UIViewController,UIPopoverPresentationControllerDelegate,UINavigationControllerDelegate,WKNavigationDelegate,WKScriptMessageHandler,UIScrollViewDelegate {
    
    //MARK: Properties
    
    var tID: Int!
    var pageNow: Int = 1
    var pageCount: Double!
    var totalReplies: Int?
    var pageHTML: String!
    var convertedHTML: String!
    var navType: NavigationType = .normal
    var scrollPosition: String?
    var sender: String?
    var comments: [CommentsRecursive]?
    var titleLabel = MarqueeLabel()
    private var webView: WKWebView!
    
    let activityIndicator = UIActivityIndicatorView()
    let composeVC = ComposeViewController()
    lazy var flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    lazy var replyButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(replyButtonPressed))
    lazy var shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
    lazy var pageButton = UIBarButtonItem(title: "撈緊...", style: .plain, target: self, action: #selector(pageButtonPressed))
    lazy var prevButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(prevButtonPressed(_:)))
    lazy var nextButton = UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: self, action: #selector(nextButtonPressed(_:)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
        
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        composeVC.view.layoutSubviews()
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.processPool = WKProcessPool()
        webView = WKWebView(frame: self.view.bounds, configuration: config)
        webView.backgroundColor = .systemBackground
        //user agent spoof for icon
        //webView.customUserAgent = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:15.0) Gecko/20100101 Firefox/15.0.1"
        webView.navigationDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.scrollView.delegate = self
        view.addSubview(webView)
        
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.delegate = self
        navigationController?.isToolbarHidden = false
        
        prevButton.isEnabled = false
        nextButton.isEnabled = false
        replyButton.isEnabled = false
        pageButton.isEnabled = false
        pageButton.tintColor = .label
        shareButton.isEnabled = false
        toolbarItems = [prevButton,flexibleSpace,replyButton,flexibleSpace,pageButton,flexibleSpace,shareButton,flexibleSpace,nextButton]
        
        titleLabel.textColor = .label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.animationDelay = 1
        titleLabel.type = .leftRight
        titleLabel.fadeLength = 5
        titleLabel.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
        titleLabel.textAlignment = .center
        
        activityIndicator.snp.makeConstraints {
            (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        webView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        let realm = try! Realm()
        let thisPost = realm.object(ofType: History.self, forPrimaryKey: self.tID)
        if thisPost != nil && self.sender == "cell" {
            self.pageNow = thisPost!.page
        }
        self.updateSequence()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isToolbarHidden = false
        webView.configuration.userContentController.add(self, name: "quote")
        webView.configuration.userContentController.add(self, name: "block")
        webView.configuration.userContentController.add(self, name: "refresh")
        webView.configuration.userContentController.add(self, name: "imageView")
        webView.configuration.userContentController.add(self, name: "user")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SwiftEntryKit.dismiss()
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "quote")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "block")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "refresh")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "imageView")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "user")
        self.webView.evaluateJavaScript("$(\".showing\").last().attr(\"id\")", completionHandler: {
            result,error in
            if error == nil {
                let position = result as? String
                let history = History()
                history.threadID = self.tID
                history.page = self.pageNow
                history.replyCount = self.totalReplies!
                if position != nil {
                    history.position = position!
                } else {
                    history.position = String((self.pageNow-1) * 50)
                }
                let realm = try! Realm()
                try! realm.write {
                    realm.add(history,update: true)
                }
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if webView.isLoading == true {
            webView.stopLoading()
            NetworkActivityIndicatorManager.networkOperationFinished()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func quoteButtonPressed(id: String) {
        let composeNav = UINavigationController(rootViewController: composeVC)
        composeNav.modalPresentationStyle = .formSheet
        composeVC.title = "引用回覆"
        composeVC.topicID = self.tID
        composeVC.quoteID = id
        composeVC.contentVC = self
        present(composeNav, animated: true, completion: nil)
    }
    
    func blockButtonPressed(id: String) {
        let blockUserMutation = BlockUserMutation(id: id)
        apollo.perform(mutation: blockUserMutation) {
            [weak self] result in
            guard let data = try? result.get().data else { return }
            if data.blockUser == true {
                let getSessionUserQuery = GetSessionUserQuery()
                apollo.fetch(query: getSessionUserQuery,cachePolicy: .fetchIgnoringCacheData) {
                    [weak self] result in
                    guard let data = try? result.get().data else { return }
                    sessionUser = data.sessionUser
                    let alert = UIAlertController(title: "成功", message: "你已封鎖此會員", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel, handler: {
                        action in
                        self?.updateSequence()
                    })
                    alert.addAction(action)
                    self?.present(alert,animated: true,completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "失敗", message: "請再試", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(action)
                self?.present(alert,animated: true,completion: nil)
            }
        }
    }
    
    func f5buttonPressed() {
        self.navType = .refresh
        self.webView.evaluateJavaScript("$(\".comment\").last().attr(\"id\")", completionHandler: {
            result,error in
            let position = result as! String
            self.scrollPosition = position
            self.updateSequence()
        })
    }
    
    @objc func pageButtonPressed() {
        let pageVC = PagePopoverTableViewController()
        pageVC.modalPresentationStyle = .popover
        pageVC.popoverPresentationController?.delegate = self
        pageVC.popoverPresentationController?.barButtonItem = pageButton
        pageVC.preferredContentSize = CGSize(width: 150, height: 200)
        pageVC.popoverPresentationController?.backgroundColor = .secondarySystemBackground
        pageVC.threadID = self.tID
        pageVC.pageCount = Int(self.pageCount)
        pageVC.pageSelected = self.pageNow
        pageVC.mainVC = self
        present(pageVC, animated: true, completion: nil)
        //SwiftEntryKit.display(entry: pageVC, using: EntryAttributes.shared.bottomEntry())
    }
    
    @objc func replyButtonPressed() {
        if keychain.get("userKey") != nil {
            let composeNav = UINavigationController(rootViewController: composeVC)
            composeVC.title = "回覆"
            composeVC.topicID = self.tID
            composeVC.quoteID = nil
            composeVC.contentVC = self
            composeNav.modalPresentationStyle = .formSheet
            present(composeNav, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: nil, message: "請先登入", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            present(alert,animated: true,completion: nil)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case "quote"?:
            
        default:
            break
        }
    }*/
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func unwindToContent(pageSelected: Int) {
        self.pageNow = pageSelected
        self.pageButton.title = "第\(self.pageNow)頁"
        self.prevButton.isEnabled = false
        self.nextButton.isEnabled = false
        self.updateSequence()
    }
    
    func unwindAfterReply() {
        self.navType = .reply
        self.updateSequence()
    }
    
    @objc func share() {
        let shareView = UIActivityViewController(activityItems:["https://hkgalden.org/forum/thread/\(tID!)/\(pageNow)"],applicationActivities:nil)
        DispatchQueue.main.asyncAfter(deadline: 0.5, execute: {
            if UIDevice.current.userInterfaceIdiom == .pad {
                shareView.popoverPresentationController?.sourceView = self.view
                shareView.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
                shareView.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0) //Removes arrow as I dont want it
            }
            self.present(shareView, animated: true, completion: nil)
        })
    }
    
    @objc func prevButtonPressed(_ sender: UIBarButtonItem) {
        pageNow -= 1
        prevButton.isEnabled = false
        nextButton.isEnabled = false
        updateSequence()
    }
    
    @objc func nextButtonPressed(_ sender: UIBarButtonItem) {
        pageNow += 1
        prevButton.isEnabled = false
        nextButton.isEnabled = false
        updateSequence()
    }
    
    //MARK: Private Functions
    
    private func buttonLogic() {
        if (self.pageNow == 1 && self.pageNow != Int(pageCount)) {
            prevButton.isEnabled = false
            nextButton.isEnabled = true
        }
        else if (self.pageNow == 1 && self.pageNow == Int(pageCount)) {
            prevButton.isEnabled = false
            nextButton.isEnabled = false
        }
        else if (self.pageNow == Int(pageCount)) {
            prevButton.isEnabled = true
            nextButton.isEnabled = false
        }
        else {
            prevButton.isEnabled = true
            nextButton.isEnabled = true
        }
    }
    
    private func updateSequence() {
        webView.isHidden = true
        activityIndicator.isHidden = false
        NetworkActivityIndicatorManager.networkOperationStarted()
        //if reply is next page
        if (navType==NavigationType.reply){
            if (totalReplies!%50==0){
                pageNow+=1
            }
        }
        let getThreadContentQuery = GetThreadContentQuery(id: tID, sorting: .dateAsc, page: pageNow)
        apollo.fetch(query: getThreadContentQuery,cachePolicy: .fetchIgnoringCacheData) {
            [weak self] result in
            guard let data = try? result.get().data else { return }
            var contentHTML: String?
            guard let thread = data.thread else { return }
            let totalPage = ceil(Double(thread.totalReplies)/50.0)
            //print(thread.totalReplies)
            //print(totalPage)
            self?.pageCount = totalPage
            self?.totalReplies = thread.totalReplies
            
            DispatchQueue.main.async {
                let titleTrim = thread.title.trimmingCharacters(in: .whitespacesAndNewlines)
                self?.titleLabel.text = titleTrim
                self?.navigationItem.titleView = self?.titleLabel
                self?.pageButton.title = "第\(self?.pageNow ?? 1)頁"
                self?.buttonLogic()
            }
            
            contentHTML = self?.constructComments(thread: thread)
            if (self?.pageNow==Int(totalPage)) {
                contentHTML?.append("<div class=\"refresh\"><button class=\"refresh-button\" onclick=\"window.webkit.messageHandlers.refresh.postMessage('refresh requested')\"></button></div>")
            }
            
            let threadHTML = "<html lang=\"zh-Hant\"><head><meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0,maximum-scale=1.0,minimum-scale=1.0,user-scalable=no\"><link rel=\"stylesheet\" href=\"content.css\"><script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js\"></script><script src=\"https://rawcdn.githack.com/kazedayo/js_for_GaldenApp/5954e3b3859ebd54e3bfa1be38d2d856f36d6b87/GaldenApp.js\"></script></head><body>\(contentHTML ?? "")<script src=\"https://cdn.jsdelivr.net/blazy/latest/blazy.min.js\"></script></body></html>"
            
            self?.webView.loadHTMLString(threadHTML, baseURL: Bundle.main.bundleURL)
        }
    }
    
    private func constructComments(thread: GetThreadContentQuery.Data.Thread) -> String {
        var completedHTML = ""
        var comment = thread.replies.map {$0.fragments.commentsRecursive}
        var blockedUserIds = [String]()
        if keychain.get("userKey") != nil {
            blockedUserIds = (sessionUser?.blockedUserIds)!
            comment = comment.filter {!blockedUserIds.contains($0.fragments.commentFields.author.id)}
        }
        self.comments = comment
        for commentObj in comment {
            var avatarurl = ""
            if commentObj.fragments.commentFields.author.avatar == nil {
                avatarurl = "https://i.imgur.com/2lya6uS.png"
            } else {
                avatarurl = commentObj.fragments.commentFields.author.avatar!
            }
            
            var genderColor = ""
            if commentObj.fragments.commentFields.author.gender == UserGender.m {
                genderColor = "#22c1fe"
            } else if commentObj.fragments.commentFields.author.gender == UserGender.f {
                genderColor = "#ff7aab"
            }
            
            var groupColor = "#aaaaaa"
            var groupName = "郊登仔"
            if commentObj.fragments.commentFields.author.groups.isEmpty == false {
                if commentObj.fragments.commentFields.author.groups[0].id == "DEVELOPER" {
                    groupColor = "#e0561d"
                    groupName = commentObj.fragments.commentFields.author.groups[0].name
                } else if commentObj.fragments.commentFields.author.groups[0].id == "ADMIN" {
                    groupColor = "#7435a0"
                    groupName = commentObj.fragments.commentFields.author.groups[0].name
                }
            }
            
            let date = (commentObj.fragments.commentFields.date.toISODate()! + 8.hours).toString(DateToStringStyles.dateTime(.short))
            
            //quote recursive
            var quoteHTML = ""
            var rootParent = commentObj.parent
            let firstLayer = rootParent?.parent
            let secondLayer = firstLayer?.parent
            let thirdLayer = secondLayer?.parent
            
            //construct quote chain
            var doc = try! SwiftSoup.parse(quoteHTML)
            //root
            if (rootParent?.fragments.commentFields.content != nil && blockedUserIds.contains((rootParent?.fragments.commentFields.author.id)!) == false) {
                try! doc.body()!.prepend("<blockquote><p class='quoteName'>\(rootParent!.fragments.commentFields.authorNickname) 說:</p>\(rootParent!.fragments.commentFields.content)</blockquote>")
            }
            //first
            if (firstLayer?.fragments.commentFields.content != nil && blockedUserIds.contains((firstLayer?.fragments.commentFields.author.id)!) == false) {
                if try! doc.select("blockquote").last() == nil {
                    try! doc.body()!.prepend("<blockquote><p class='quoteName'>\(firstLayer!.fragments.commentFields.authorNickname) 說:</p>\(firstLayer!.fragments.commentFields.content)</blockquote>")
                } else {
                    try! doc.select("blockquote").last()!.prepend("<blockquote><p class='quoteName'>\(firstLayer!.fragments.commentFields.authorNickname) 說:</p>\(firstLayer!.fragments.commentFields.content)</blockquote>")
                }
            }
            //second
            if (secondLayer?.fragments.commentFields.content != nil && blockedUserIds.contains((secondLayer?.fragments.commentFields.author.id)!) == false) {
                if try! doc.select("blockquote").last() == nil {
                    try! doc.body()!.prepend("<blockquote><p class='quoteName'>\(secondLayer!.fragments.commentFields.authorNickname) 說:</p>\(secondLayer!.fragments.commentFields.content)</blockquote>")
                } else {
                    try! doc.select("blockquote").last()!.prepend("<blockquote><p class='quoteName'>\(secondLayer!.fragments.commentFields.authorNickname) 說:</p>\(secondLayer!.fragments.commentFields.content)</blockquote>")
                }
            }
            //third
            if (thirdLayer?.fragments.commentFields.content != nil && blockedUserIds.contains((thirdLayer?.fragments.commentFields.author.id)!) == false) {
                if try! doc.select("blockquote").last() == nil {
                    try! doc.body()!.prepend("<blockquote><p class='quoteName'>\(thirdLayer!.fragments.commentFields.authorNickname) 說:</p>\(thirdLayer!.fragments.commentFields.content)</blockquote>")
                } else {
                    try! doc.select("blockquote").last()!.prepend("<blockquote><p class='quoteName'>\(thirdLayer!.fragments.commentFields.authorNickname) 說:</p>\(thirdLayer!.fragments.commentFields.content)</blockquote>")
                }
            }
                
            doc = galdenParser(doc: doc)
            quoteHTML = try! doc.body()!.html()
            
            var templateHTML = "<div class=\"comment\" id=\"\(commentObj.fragments.commentFields.floor)\"><div class=\"user\"><div class=\"usertable\" id=\"image\"><table style=\"width:100%\"><tbody><tr><td align=\"center\"><img class=\"avatar\" onclick=\"window.webkit.messageHandlers.user.postMessage('\(commentObj.fragments.commentFields.author.id)')\" src=\"\(avatarurl)\"></td></tr></tbody></table></div><div class=\"usertable\" id=\"text\"><table style=\"width:100%;font-size:12px;\"><tbody><tr><td class=\"lefttext\" style=\"color:\(genderColor);\">\(commentObj.fragments.commentFields.authorNickname)</td><td class=\"righttext\">\(date)</td></tr><tr><td class=\"lefttext\" style=\"color:\(groupColor)\">\(groupName)</td><td class=\"righttext\">#\(commentObj.fragments.commentFields.floor)</td></tr></tbody></table></div></div><div style=\"padding-left:10px;padding-right:10px;\">\(quoteHTML)\(commentObj.fragments.commentFields.content)</div><div style=\"height:30px;padding-top:20px;\"><div style=\"float:right;\"><table><tbody><tr><td><button class=\"button\" onclick=\"window.webkit.messageHandlers.quote.postMessage('\(commentObj.fragments.commentFields.id)')\">引用</button></td><td><button class=\"button\" onclick=\"window.webkit.messageHandlers.block.postMessage('\(commentObj.fragments.commentFields.author.id)')\">封鎖/舉報</button></td></tr></tbody></table></div></div></div>"
            doc = try! SwiftSoup.parse(templateHTML)
            doc = galdenParser(doc: doc)
            templateHTML = try! doc.body()!.html()
            completedHTML.append(templateHTML)
        }
        return completedHTML
    }
    
    func galdenParser(doc: Document) -> Document {
        //img parse
        let img = try! doc.select("span[data-nodetype=img]")
        for i in 0 ..< img.size() {
            if keychain.getBool("loadImage") == true {
                let imgURL = try! img.get(i).attr("data-src")
                try! img.get(i).wrap("<img class=\"b-lazy\" src=\"https://img.eservice-hk.net/upload/2018/05/17/213108_b95f899cf42b6a9472e11ab7f8c64f89.gif\" data-src=\"\(imgURL)\" onclick=\"window.webkit.messageHandlers.imageView.postMessage('\(imgURL)');\">")
                try! img.get(i).remove()
            } else {
                let imgURL = try! img.get(i).attr("data-src")
                try! img.get(i).wrap("<img onclick=\"redrawImg($(this),'\(imgURL)');\" src=\"https://i.imgur.com/n06vC2w.png\">")
                try! img.get(i).remove()
            }
        }
        
        //color parse
        let color = try! doc.select("span[data-nodetype=color]")
        for el in color {
            let colorHex = try! el.attr("data-value")
            try! el.removeAttr("data-nodetype")
            try! el.removeAttr("data-value")
            try! el.attr("color", "#\(colorHex)")
            try! el.tagName("font")
        }
        
        //url parse
        let a = try! doc.select("span[data-nodetype=a]")
        for el in a {
            let url = try! el.attr("data-href")
            try! el.removeAttr("data-nodetype")
            try! el.removeAttr("data-href")
            try! el.attr("href", url)
            try! el.text(url)
            try! el.tagName("a")
        }
        
        //b parse
        let b = try! doc.select("span[data-nodetype=b]")
        for el in b {
            try! el.removeAttr("data-nodetype")
            try! el.tagName("b")
        }
        
        //i parse
        let it = try! doc.select("span[data-nodetype=i]")
        for el in it {
            try! el.removeAttr("data-nodetype")
            try! el.tagName("i")
        }
        
        //u parse
        let u = try! doc.select("span[data-nodetype=u]")
        for el in u {
            try! el.removeAttr("data-nodetype")
            try! el.tagName("u")
        }
        
        //s parse
        let s = try! doc.select("span[data-nodetype=s]")
        for el in s {
            try! el.removeAttr("data-nodetype")
            try! el.tagName("s")
        }
        
        //center parse
        let center = try! doc.select("p[data-nodetype=center]")
        for el in center {
            try! el.removeAttr("data-nodetype")
            try! el.attr("align", "center")
            try! el.tagName("div")
        }
        
        //right parse
        let right = try! doc.select("p[data-nodetype=right]")
        for el in right {
            try! el.removeAttr("data-nodetype")
            try! el.attr("align", "right")
            try! el.tagName("div")
        }
        
        //h1 parse
        let h1 = try! doc.select("span[data-nodetype=h1]")
        for el in h1 {
            try! el.removeAttr("data-nodetype")
            try! el.tagName("font")
            try! el.addClass("h1")
        }
        
        //h2 parse
        let h2 = try! doc.select("span[data-nodetype=h2]")
        for el in h2 {
            try! el.removeAttr("data-nodetype")
            try! el.tagName("font")
            try! el.addClass("h2")
        }
        
        //h3 parse
        let h3 = try! doc.select("span[data-nodetype=h3]")
        for el in h3 {
            try! el.removeAttr("data-nodetype")
            try! el.tagName("font")
            try! el.addClass("h3")
        }
        
        //icon parse
        let icon = try! doc.select("span[data-nodetype=smiley]")
        for el in icon {
            let pack = try! el.attr("data-pack-id")
            let id = try! el.attr("data-id")
            let width = try! el.attr("data-sx")
            let height = try! el.attr("data-sy")
            try! el.wrap("<img src=\"https://s.hkgalden.org/smilies/\(pack)/\(id).gif\" width=\"\(width)\" height=\"\(height)\">")
            try! el.remove()
        }
        
        //empty p to br
        let p = try! doc.select("p")
        for el in p {
            if try! el.html().isEmpty == true {
                try! el.tagName("br")
            }
        }
        
        return doc
    }
    
    //MARK: WebView Delegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.isHidden = true
        replyButton.isEnabled = true
        pageButton.isEnabled = true
        shareButton.isEnabled = true
        //webView.evaluateJavaScript("document.body.style.webkitTouchCallout='none';")
        webView.evaluateJavaScript("new Blazy();", completionHandler: {
            result,error in
            switch self.navType {
            case .reply:
                webView.evaluateJavaScript("window.scrollTo(0,document.body.scrollHeight);", completionHandler: {(result, error) in
                    NetworkActivityIndicatorManager.networkOperationFinished()
                    DispatchQueue.main.asyncAfter(deadline: 0.2, execute: {
                        webView.isHidden = false
                    })
                    self.navType = .normal
                })
            case .refresh:
                webView.evaluateJavaScript("$(\"#\((self.scrollPosition!))\").get(0).scrollIntoView();", completionHandler: {
                    result,error in
                    NetworkActivityIndicatorManager.networkOperationFinished()
                    DispatchQueue.main.asyncAfter(deadline: 0.2, execute: {
                        webView.isHidden = false
                    })
                    self.navType = .normal
                })
            case .normal:
                let realm = try! Realm()
                let thisPost = realm.object(ofType: History.self, forPrimaryKey: self.tID)
                if thisPost != nil && self.sender == "cell" {
                    self.webView.evaluateJavaScript("$(\"#\((thisPost?.position)!)\").get(0).scrollIntoView();", completionHandler: {
                        result,error in
                        NetworkActivityIndicatorManager.networkOperationFinished()
                        DispatchQueue.main.asyncAfter(deadline: 0.2, execute: {
                            webView.isHidden = false
                        })
                    })
                } else {
                    NetworkActivityIndicatorManager.networkOperationFinished()
                    DispatchQueue.main.asyncAfter(deadline: 0.2, execute: {
                        webView.isHidden = false
                    })
                }
            }
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            if (navigationAction.request.url?.absoluteString.contains("hkgalden.org"))! {
                navigationController?.pushViewController(navigator.viewController(for: navigationAction.request.url!)!, animated: true)
                decisionHandler(.cancel)
            } else {
                let url = navigationAction.request.url
                /*if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(url!)
                }*/
                let sfVC = SFSafariViewController(url: url!)
                sfVC.preferredControlTintColor = .systemGreen
                present(sfVC, animated: true, completion: nil)
                decisionHandler(.cancel)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        NetworkActivityIndicatorManager.networkOperationFinished()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "quote" {
            if keychain.get("userKey") != nil {
                self.quoteButtonPressed(id: message.body as! String)
            } else {
                let alert = UIAlertController(title: nil, message: "請先登入", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(ok)
                present(alert,animated: true,completion: nil)
            }
        } else if message.name == "block" {
            if keychain.get("userKey") != nil {
                let alert = UIAlertController.init(title: "封鎖會員", message: "你確定要封鎖此會員?", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "55", style: .destructive, handler: {
                    _ in
                    self.blockButtonPressed(id: message.body as! String)
                }))
                alert.addAction(UIAlertAction.init(title: "不了", style: .cancel, handler: nil))
                present(alert,animated: true)
            } else {
                let alert = UIAlertController(title: nil, message: "請先登入", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(ok)
                present(alert,animated: true,completion: nil)
            }
        } else if message.name == "refresh" {
            self.f5buttonPressed()
        } else if message.name == "imageView" {
            let urlString = message.body as! String
            var images = [SKPhoto]()
            let photo = SKPhoto.photoWithImageURL(urlString)
            images.append(photo)
            let browser = SKPhotoBrowser(photos: images)
            browser.initializePageIndex(0)
            present(browser,animated: true,completion: nil)
        } else if message.name == "user" {
            let uid = message.body as! String
            let userVC = UserViewController()
            userVC.uid = uid
            navigationController?.pushViewController(userVC, animated: true)
        }
    }
    
    //scroll hack
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.x > 0 || scrollView.contentOffset.x < 0){
            scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y)
        }
    }
}
