//
//  ContentViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 2/10/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import KeychainSwift
import MarqueeLabel
import WebKit
import RealmSwift
import GoogleMobileAds
import SwiftyJSON
import Kingfisher
import SKPhotoBrowser
import SwiftEntryKit
import SwiftSoup

class ContentViewController: UIViewController,UIPopoverPresentationControllerDelegate,UINavigationControllerDelegate,WKNavigationDelegate,WKScriptMessageHandler,GADBannerViewDelegate {
    
    //MARK: Properties
    
    var threadIdReceived: String!
    var tID: Int!
    var isRated: Bool!
    var pageNow: Int = 1
    var op: OP!
    var poll: Poll?
    var comments = [Replies]()
    var replyCount: Int!
    var pageCount: Double!
    var quoteContent: String?
    var blockedUsers = [String]()
    var pageHTML: String!
    var convertedHTML: String!
    var navType: NavigationType = .normal
    var scrollPosition: String?
    var sender: String?
    var ident: String?
    var titleLabel = MarqueeLabel()
    private var webView: WKWebView!
    
    //HKGalden API (NOT included in GitHub repo)
    let keychain = KeychainSwift()
    
    let adBannerView = GADBannerView()
    let activityIndicator = UIActivityIndicatorView()
    lazy var flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    lazy var replyButton = UIBarButtonItem(image: UIImage(named: "Reply"), style: .plain, target: self, action: #selector(replyButtonPressed))
    lazy var moreButton = UIBarButtonItem(image: UIImage(named: "more"), style: .plain, target: self, action: #selector(moreButtonPressed))
    lazy var pageButton = UIBarButtonItem(title: "撈緊...", style: .plain, target: self, action: #selector(pageButtonPressed))
    lazy var prevButton = UIBarButtonItem(image: UIImage(named: "previous"), style: .plain, target: self, action: #selector(prevButtonPressed(_:)))
    lazy var nextButton = UIBarButtonItem(image: UIImage(named: "next"), style: .plain, target: self, action: #selector(nextButtonPressed(_:)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        xbbcodeBridge.shared.sender = "content"
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.processPool = WKProcessPool()
        webView = WKWebView(frame: self.view.bounds, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.navigationDelegate = self
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = true
        }
        view.addSubview(webView)
        
        navigationController?.delegate = self
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.barStyle = .black
        navigationController?.toolbar.tintColor = .white
        prevButton.isEnabled = false
        nextButton.isEnabled = false
        replyButton.isEnabled = false
        pageButton.isEnabled = false
        moreButton.isEnabled = false
        toolbarItems = [prevButton,flexibleSpace,replyButton,flexibleSpace,pageButton,flexibleSpace,moreButton,flexibleSpace,nextButton]
        
        adBannerView.adUnitID = "ca-app-pub-6919429787140423/1613095078"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        view.addSubview(adBannerView)
        
        activityIndicator.snp.makeConstraints {
            (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        webView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        adBannerView.snp.makeConstraints {
            (make) -> Void in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.snp.bottomMargin)
            } else {
                make.bottom.equalTo(view.snp.bottom).offset(-44)
            }
            make.height.equalTo(50)
        }
        
        /*HKGaldenAPI.shared.pageCount(postId: threadIdReceived, completion: {
            count in
            self.pageCount = count
            let realm = try! Realm()
            let thisPost = realm.object(ofType: History.self, forPrimaryKey: self.threadIdReceived)
            if thisPost != nil && self.sender == "cell" {
                self.pageNow = thisPost!.page
            }
            self.updateSequence()
        })*/
        self.updateSequence()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //prevButton.isEnabled = false
        //nextButton.isEnabled = false
        webView.configuration.userContentController.add(self, name: "quote")
        webView.configuration.userContentController.add(self, name: "block")
        webView.configuration.userContentController.add(self, name: "refresh")
        webView.configuration.userContentController.add(self, name: "imageView")
        if (keychain.getBool("noAd") == true) {
            adBannerView.removeFromSuperview()
        } else {
            adBannerView.load(GADRequest())
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SwiftEntryKit.dismiss()
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "quote")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "block")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "refresh")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "imageView")
        /*self.webView.evaluateJavaScript("$(\".showing\").last().attr(\"id\")", completionHandler: {
            result,error in
            if error == nil {
                let position = result as? String
                let history = History()
                history.threadID = self.threadIdReceived
                history.page = self.pageNow
                history.replyCount = self.replyCount
                if position != nil {
                    history.position = position!
                } else if self.pageNow == 1 {
                    history.position = "0"
                } else {
                    history.position = String((self.pageNow-1) * 25 + 1)
                }
                let realm = try! Realm()
                try! realm.write {
                    realm.add(history,update: true)
                }
            }
        })*/
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (keychain.getBool("noAd") == false) {
            webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, adBannerView.frame.height, 0)
        }
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
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        //print("Banner loaded successfully")
        // Reposition the banner ad to create a slide down effect
        let translateTransform = CGAffineTransform(translationX: 0, y: bannerView.bounds.size.height)
        bannerView.transform = translateTransform
        
        UIView.animate(withDuration: 0.5) {
            bannerView.transform = CGAffineTransform.identity
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        //print("Fail to receive ads")
        print(error)
    }
    
    func quoteButtonPressed(type: String) {
            if (pageNow == 1 && type == "op") {
                self.quoteContent = "[quote]\(self.op.contentOriginal)[/quote]"
                self.quote()
            } else if pageNow == 1 {
                self.quoteContent = "[quote]\(self.comments[Int(type)! + 1].contentOriginal)[/quote]"
                self.quote()
            } else {
                self.quoteContent = "[quote]\(self.comments[Int(type)!].contentOriginal)[/quote]"
                self.quote()
        }
    }
    
    func blockButtonPressed(type: String) {
        if (pageNow == 1 && type == "op") {
            HKGaldenAPI.shared.blockUser(uid: self.op.userID, completion: {
                status in
                if status == "true" {
                    self.blockedUsers.append(self.op.userID)
                    self.navType = .refresh
                    self.scrollPosition = "0"
                    self.updateSequence()
                }
            })
        } else if pageNow == 1 {
            HKGaldenAPI.shared.blockUser(uid: self.comments[Int(type)! + 1].userID, completion: {
                status in
                if status == "true" {
                    self.blockedUsers.append(self.comments[Int(type)! + 1].userID)
                    self.navType = .refresh
                    self.scrollPosition = type
                    self.updateSequence()
                }
            })
        } else {
            HKGaldenAPI.shared.blockUser(uid: self.comments[Int(type)!].userID, completion: {
                status in
                if status == "true" {
                    self.blockedUsers.append(self.comments[Int(type)!].userID)
                    self.navType = .refresh
                    self.scrollPosition = type
                    self.updateSequence()
                }
            })
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
    
    @objc func moreButtonPressed() {
        
    }
    
    @objc func pageButtonPressed() {
        let pageVC = PagePopoverTableViewController()
        //pageVC.modalPresentationStyle = .popover
        //pageVC.popoverPresentationController?.delegate = self
        //pageVC.popoverPresentationController?.barButtonItem = pageButton
        //pageVC.preferredContentSize = CGSize(width: 150, height: 200)
        //pageVC.popoverPresentationController?.backgroundColor = UIColor(hexRGB: "#262626")!
        pageVC.threadID = self.threadIdReceived
        pageVC.pageCount = Int(self.pageCount)
        pageVC.pageSelected = self.pageNow
        pageVC.mainVC = self
        //present(pageVC, animated: true, completion: nil)
        SwiftEntryKit.display(entry: pageVC, using: EntryAttributes.shared.bottomEntry())
    }
    
    @objc func replyButtonPressed() {
        let composeVC = ComposeViewController()
        let composeNav = UINavigationController(rootViewController: composeVC)
        composeVC.topicID = self.threadIdReceived
        composeVC.composeType = .reply
        composeVC.contentVC = self
        //SwiftEntryKit.display(entry: composeVC, using: EntryAttributes.shared.centerEntry())
        present(composeNav, animated: true, completion: nil)
    }
    
    func quote() {
        let composeVC = ComposeViewController()
        composeVC.topicID = self.threadIdReceived
        composeVC.content = self.quoteContent! + "\n"
        composeVC.composeType = .reply
        composeVC.contentVC = self
        SwiftEntryKit.display(entry: composeVC, using: EntryAttributes.shared.centerEntry())
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
        HKGaldenAPI.shared.pageCount(postId: threadIdReceived, completion: {
            count in
            self.pageCount = count
            self.updateSequence()
        })
    }
    
    func unwindAfterReply() {
        HKGaldenAPI.shared.pageCount(postId: threadIdReceived, completion: {
            count in
            self.pageCount = count
            self.pageNow = Int(self.pageCount)
            self.pageButton.title = "第\(self.pageNow)頁"
            self.navType = .reply
            xbbcodeBridge.shared.sender = "content"
            self.updateSequence()
        })
    }
    
    func share(shareContent: String) {
        let shareView = UIActivityViewController(activityItems:[shareContent],applicationActivities:nil)
        shareView.excludedActivityTypes = [.airDrop,.addToReadingList,.assignToContact,.openInIBooks,.saveToCameraRoll]
        DispatchQueue.main.asyncAfter(deadline: 0.5, execute: {
            if UIDevice.current.userInterfaceIdiom == .pad {
                shareView.popoverPresentationController?.sourceView = self.view
                shareView.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
                shareView.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0) //Removes arrow as I dont want it
            }
            self.present(shareView, animated: true, completion: nil)
        })
    }
    
    func lm() {
        let alert = UIAlertController.init(title: "一鍵留名", message: "確定?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction.init(title: "55", style: .destructive, handler: {
            _ in
            HKGaldenAPI.shared.reply(topicID: self.threadIdReceived, content: self.keychain.get("LeaveNameText")!, completion: {
                error in
                if error == nil {
                    HKGaldenAPI.shared.pageCount(postId: self.threadIdReceived, completion: {
                        count in
                        self.pageCount = count
                        self.pageNow = Int(self.pageCount)
                        self.pageButton.title = "第\(self.pageNow)頁"
                        self.navType = .reply
                        self.updateSequence()
                    })
                }
            })
        }))
        alert.addAction(UIAlertAction.init(title: "不了", style: .cancel, handler: nil))
        DispatchQueue.main.asyncAfter(deadline: 0.5, execute: {
            self.present(alert,animated: true)
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
        let getThreadContentQuery = GetThreadContentQuery(id: tID, sorting: .dateAsc, page: pageNow)
        apollo.fetch(query: getThreadContentQuery) {
            [weak self] result,error in
            guard let thread = result?.data?.thread else { return }
            var contentHTML = self?.constructComments(thread: thread)
            self?.titleLabel.text = thread.title
            self?.titleLabel.textColor = .white
            self?.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
            self?.titleLabel.animationDelay = 1
            self?.titleLabel.marqueeType = .MLLeftRight
            self?.titleLabel.fadeLength = 5
            self?.titleLabel.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
            self?.titleLabel.textAlignment = .center
            self?.navigationItem.titleView = self?.titleLabel
            self?.pageButton.title = "第\(self?.pageNow ?? 1)頁"
            
            /*if (self?.pageNow==Int((self?.pageCount)!)) {
                contentHTML!.append("<div class=\"refresh\"><button class=\"refresh-button\" onclick=\"window.webkit.messageHandlers.refresh.postMessage('refresh requested')\"></button></div>")
            }*/
            
            var threadHTML = ""
            threadHTML = "<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0,user-scalable=0\"><link rel=\"stylesheet\" href=\"content.css\"><script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js\"></script><script src=\"https://cdn.rawgit.com/kazedayo/js_for_GaldenApp/87d964a5/GaldenApp.js\"></script></head><body>\(contentHTML!)<script src=\"https://cdn.jsdelivr.net/blazy/latest/blazy.min.js\"></script></body></html>"
            
            let doc = try! SwiftSoup.parse(threadHTML)
            
            //img parse
            let img = try! doc.select("span[data-nodetype=img]")
            let imgURL = try! img.attr("data-src")
            try! img.wrap("<img class=\"b-lazy\" src=\"https://img.eservice-hk.net/upload/2018/05/17/213108_b95f899cf42b6a9472e11ab7f8c64f89.gif\" data-src=\"\(imgURL)\" onclick=\"window.webkit.messageHandlers.imageView.postMessage('\(imgURL)');\">")
            try! doc.select("span[data-nodetype=img]").remove()
            
            //url parse
            let a = try! doc.select("span[data-nodetype=a]")
            let url = try! a.attr("data-href")
            try! a.wrap("<a href=\"\(url)\">\(url)</a>")
            try! doc.select("span[data-nodetype=a]").remove()
            
            threadHTML = try! doc.outerHtml()
                
            self?.webView.loadHTMLString(threadHTML, baseURL: Bundle.main.bundleURL)
            NetworkActivityIndicatorManager.networkOperationStarted()
        }
    }
    
    private func constructComments(thread: GetThreadContentQuery.Data.Thread) -> String {
        let iconArray = ["https://i.imgur.com/PXPXwaRs.jpg","https://i.imgur.com/9AKjGrIs.jpg","https://i.imgur.com/sV2Q22ns.jpg"]
        let randomIndex = Int(arc4random_uniform(UInt32(iconArray.count)))
        var completedHTML = ""
        for i in 0 ..< thread.replies.count {
            var avatarurl = ""
            if thread.replies[i].author.avatar == nil {
                avatarurl = iconArray[randomIndex]
            } else {
                avatarurl = thread.replies[i].author.avatar!
            }
            
            var genderColor = ""
            if thread.replies[i].author.gender == UserGender.m {
                genderColor = "#6495ed"
            } else if thread.replies[i].author.gender == UserGender.f {
                genderColor = "#ff6961"
            }
            
            let templateHTML = "<div class=\"comment\" id=\"\(thread.replies[i].floor)\"><div class=\"user\"><div class=\"usertable\" id=\"image\"><table style=\"width:100%\"><tbody><tr><td align=\"center\"><img class=\"avatar\" src=\"\(avatarurl)\"></td></tr></tbody></table></div><div class=\"usertable\" id=\"text\"><table style=\"width:100%;font-size:12px;\"><tbody><tr><td class=\"lefttext\" style=\"color:\(genderColor);\">\(thread.replies[i].author.nickname)</td><td class=\"righttext\">\(thread.replies[i].date)</td></tr><tr><td class=\"lefttext\">label</td><td class=\"righttext\">#\(thread.replies[i].floor)</td></tr></tbody></table></div></div><div style=\"padding-left:10px;padding-right:10px;\">\(thread.replies[i].content)</div><div style=\"height:30px;padding-top:20px;\"><div style=\"float:right;\"><table><tbody><tr><td><button class=\"button\" onclick=\"window.webkit.messageHandlers.quote.postMessage('\(i)')\">引用</button></td><td><button class=\"button\" onclick=\"window.webkit.messageHandlers.block.postMessage('\(i)')\">封鎖/舉報</button></td></tr></tbody></table></div></div></div>"
            completedHTML.append(templateHTML)
        }
        return completedHTML
    }
    
    //MARK: WebView Delegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.isHidden = true
        replyButton.isEnabled = true
        pageButton.isEnabled = true
        moreButton.isEnabled = true
        webView.evaluateJavaScript("document.body.style.webkitTouchCallout='none';")
        webView.evaluateJavaScript("new Blazy();", completionHandler: {
            result,error in
            DispatchQueue.main.asyncAfter(deadline: 0.3, execute: {
                switch self.navType {
                case .reply:
                    webView.evaluateJavaScript("window.scrollTo(0,document.body.scrollHeight);", completionHandler: {(result, error) in
                        NetworkActivityIndicatorManager.networkOperationFinished()
                        webView.isHidden = false
                        self.navType = .normal
                    })
                case .refresh:
                    webView.evaluateJavaScript("$(\"#\((self.scrollPosition!))\").get(0).scrollIntoView();", completionHandler: {
                        result,error in
                        DispatchQueue.main.asyncAfter(deadline: 0.2, execute: {
                            NetworkActivityIndicatorManager.networkOperationFinished()
                            webView.isHidden = false
                            self.navType = .normal
                        })
                    })
                case .normal:
                    /*let realm = try! Realm()
                    let thisPost = realm.object(ofType: History.self, forPrimaryKey: self.threadIdReceived)
                    if thisPost != nil && self.sender == "cell" {
                        self.webView.evaluateJavaScript("$(\"#\((thisPost?.position)!)\").get(0).scrollIntoView();", completionHandler: {
                            result,error in
                            DispatchQueue.main.asyncAfter(deadline: 0.2, execute: {
                                NetworkActivityIndicatorManager.networkOperationFinished()
                                webView.isHidden = false
                            })
                        })
                    } else {
                        NetworkActivityIndicatorManager.networkOperationFinished()
                        webView.isHidden = false
                    }*/
                    NetworkActivityIndicatorManager.networkOperationFinished()
                    webView.isHidden = false
                }
            })
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            if (navigationAction.request.url?.absoluteString.contains("hkgalden.com/view/"))! {
                navigator.pushURL(navigationAction.request.url!)
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
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        NetworkActivityIndicatorManager.networkOperationFinished()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "quote" {
            self.quoteButtonPressed(type: message.body as! String)
        } else if message.name == "block" {
            let alert = UIAlertController.init(title: "扑柒", message: "你確定要扑柒此會然?", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "55", style: .destructive, handler: {
                _ in
                self.blockButtonPressed(type: message.body as! String)
            }))
            alert.addAction(UIAlertAction.init(title: "不了", style: .cancel, handler: nil))
            present(alert,animated: true)
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
}
