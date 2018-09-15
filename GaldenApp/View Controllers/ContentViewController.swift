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
import GoogleMobileAds
import SwiftyJSON
import Kingfisher
import SKPhotoBrowser
import SwiftEntryKit
import SwiftSoup
import SwiftDate

class ContentViewController: UIViewController,UIPopoverPresentationControllerDelegate,UINavigationControllerDelegate,WKNavigationDelegate,WKScriptMessageHandler,GADBannerViewDelegate {
    
    //MARK: Properties
    
    var tID: Int!
    var isRated: Bool!
    var pageNow: Int = 1
    var pageCount: Double!
    var totalReplies: Int?
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
        pageButton.tintColor = .white
        moreButton.isEnabled = false
        toolbarItems = [prevButton,flexibleSpace,replyButton,flexibleSpace,pageButton,flexibleSpace,moreButton,flexibleSpace,nextButton]
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.animationDelay = 1
        titleLabel.marqueeType = .MLLeftRight
        titleLabel.fadeLength = 5
        titleLabel.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
        titleLabel.textAlignment = .center
        
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
        self.updateSequence()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prevButton.isEnabled = false
        nextButton.isEnabled = false
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
        
    }
    
    func blockButtonPressed(type: String) {
        
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
        pageVC.threadID = self.tID
        pageVC.pageCount = Int(self.pageCount)
        pageVC.pageSelected = self.pageNow
        pageVC.mainVC = self
        //present(pageVC, animated: true, completion: nil)
        SwiftEntryKit.display(entry: pageVC, using: EntryAttributes.shared.bottomEntry())
    }
    
    @objc func replyButtonPressed() {
        /*let composeVC = ComposeViewController()
        let composeNav = UINavigationController(rootViewController: composeVC)
        composeVC.topicID = self.threadIdReceived
        composeVC.composeType = .reply
        composeVC.contentVC = self
        //SwiftEntryKit.display(entry: composeVC, using: EntryAttributes.shared.centerEntry())
        present(composeNav, animated: true, completion: nil)*/
    }
    
    func quote() {
        /*let composeVC = ComposeViewController()
        composeVC.topicID = self.threadIdReceived
        composeVC.content = self.quoteContent! + "\n"
        composeVC.composeType = .reply
        composeVC.contentVC = self
        SwiftEntryKit.display(entry: composeVC, using: EntryAttributes.shared.centerEntry())*/
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
        self.updateSequence()
    }
    
    func unwindAfterReply() {
        /*HKGaldenAPI.shared.pageCount(postId: threadIdReceived, completion: {
            count in
            self.pageCount = count
            self.pageNow = Int(self.pageCount)
            self.pageButton.title = "第\(self.pageNow)頁"
            self.navType = .reply
            self.updateSequence()
        })*/
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
        /*let alert = UIAlertController.init(title: "一鍵留名", message: "確定?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction.init(title: "55", style: .destructive, handler: {
            _ in
            HKGaldenAPI.shared.reply(topicID: self.threadIdReceived, content: keychain.get("LeaveNameText")!, completion: {
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
        })*/
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
        let realm = try! Realm()
        let thisPost = realm.object(ofType: History.self, forPrimaryKey: self.tID)
        if thisPost != nil && self.sender == "cell" {
            self.pageNow = thisPost!.page
        }
        let getThreadContentQuery = GetThreadContentQuery(id: tID, sorting: .dateAsc, page: pageNow)
        apollo.fetch(query: getThreadContentQuery,cachePolicy: .fetchIgnoringCacheData) {
            [weak self] result,error in
            guard let thread = result?.data?.thread else { return }
            var contentHTML = self?.constructComments(thread: thread)
            self?.titleLabel.text = thread.title
            self?.navigationItem.titleView = self?.titleLabel
            self?.pageCount = (Double(thread.totalReplies)/50.0).rounded(.up)
            self?.totalReplies = thread.totalReplies
            self?.pageButton.title = "第\(self?.pageNow ?? 1)頁"
            self?.buttonLogic()
            
            if (self?.pageNow==Int((self?.pageCount)!)) {
                contentHTML!.append("<div class=\"refresh\"><button class=\"refresh-button\" onclick=\"window.webkit.messageHandlers.refresh.postMessage('refresh requested')\"></button></div>")
            }
            
            var threadHTML = ""
            threadHTML = "<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0,user-scalable=0\"><link rel=\"stylesheet\" href=\"content.css\"><script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js\"></script><script src=\"https://cdn.rawgit.com/kazedayo/js_for_GaldenApp/87d964a5/GaldenApp.js\"></script></head><body>\(contentHTML!)<script src=\"https://cdn.jsdelivr.net/blazy/latest/blazy.min.js\"></script></body></html>"
                
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
            let comment = thread.replies.map {$0.fragments.commentsRecursive}
            if comment[i].fragments.commentFields.author.avatar == nil {
                avatarurl = iconArray[randomIndex]
            } else {
                avatarurl = comment[i].fragments.commentFields.author.avatar!
            }
            
            var genderColor = ""
            if comment[i].fragments.commentFields.author.gender == UserGender.m {
                genderColor = "#6495ed"
            } else if comment[i].fragments.commentFields.author.gender == UserGender.f {
                genderColor = "#ff6961"
            }
            
            let date = (comment[i].fragments.commentFields.date.toISODate()! + 8.hours).toString(DateToStringStyles.dateTime(.short))
            
            //quote recursive
            var quoteHTML = ""
            let rootParent = comment[i].parent
            let firstLayer = rootParent?.parent
            let secondLayer = firstLayer?.parent
            let thirdLayer = secondLayer?.parent
            if (rootParent?.fragments.commentFields.content != nil) {
                quoteHTML = "<blockquote id=\"1\">\(rootParent!.fragments.commentFields.content)</blockquote>"
                var doc = try! SwiftSoup.parse(quoteHTML)
                var quote = try! doc.select("blockquote#1")
                if (firstLayer?.fragments.commentFields.content != nil) {
                    try! quote.prepend("<blockquote id=\"2\">\(firstLayer!.fragments.commentFields.content)</blockquote>")
                    if (secondLayer?.fragments.commentFields.content != nil) {
                        quote = try! doc.select("blockquote#2")
                        try! quote.prepend("<blockquote id=\"3\">\(secondLayer!.fragments.commentFields.content)</blockquote>")
                        if (thirdLayer?.fragments.commentFields.content != nil) {
                            quote = try! doc.select("blockquote#3")
                            try! quote.prepend("<blockquote id=\"4\">\(thirdLayer!.fragments.commentFields.content)</blockquote>")
                        }
                    }
                }
                doc = galdenParser(doc: doc)
                quoteHTML = try! doc.html()
            }
            
            var templateHTML = "<div class=\"comment\" id=\"\(comment[i].fragments.commentFields.floor)\"><div class=\"user\"><div class=\"usertable\" id=\"image\"><table style=\"width:100%\"><tbody><tr><td align=\"center\"><img class=\"avatar\" src=\"\(avatarurl)\"></td></tr></tbody></table></div><div class=\"usertable\" id=\"text\"><table style=\"width:100%;font-size:12px;\"><tbody><tr><td class=\"lefttext\" style=\"color:\(genderColor);\">\(comment[i].fragments.commentFields.author.nickname)</td><td class=\"righttext\">\(date)</td></tr><tr><td class=\"lefttext\">郊登仔</td><td class=\"righttext\">#\(comment[i].fragments.commentFields.floor)</td></tr></tbody></table></div></div><div style=\"padding-left:10px;padding-right:10px;\">\(quoteHTML)\(comment[i].fragments.commentFields.content)</div><div style=\"height:30px;padding-top:20px;\"><div style=\"float:right;\"><table><tbody><tr><td><button class=\"button\" onclick=\"window.webkit.messageHandlers.quote.postMessage('\(i)')\">引用</button></td><td><button class=\"button\" onclick=\"window.webkit.messageHandlers.block.postMessage('\(i)')\">封鎖/舉報</button></td></tr></tbody></table></div></div></div>"
            var doc = try! SwiftSoup.parse(templateHTML)
            doc = galdenParser(doc: doc)
            templateHTML = try! doc.html()
            completedHTML.append(templateHTML)
        }
        return completedHTML
    }
    
    func galdenParser(doc: Document) -> Document {
        //img parse
        let img = try! doc.select("span[data-nodetype=img]")
        for i in 0 ..< img.size() {
            let imgURL = try! img.get(i).attr("data-src")
            try! img.get(i).wrap("<img class=\"b-lazy\" src=\"https://img.eservice-hk.net/upload/2018/05/17/213108_b95f899cf42b6a9472e11ab7f8c64f89.gif\" data-src=\"\(imgURL)\" onclick=\"window.webkit.messageHandlers.imageView.postMessage('\(imgURL)');\">")
            try! img.get(i).remove()
        }
        
        //url parse
        let a = try! doc.select("span[data-nodetype=a]")
        for i in 0 ..< a.size() {
            let url = try! a.get(i).attr("data-href")
            try! a.get(i).wrap("<a href=\"\(url)\">\(url)</a>")
            try! a.get(i).remove()
        }
        
        //b parse
        let b = try! doc.select("span[data-nodetype=b]")
        for i in 0 ..< b.size() {
            let textB = try! b.get(i).text()
            try! b.get(i).wrap("<b>\(textB)</b>")
            try! b.get(i).remove()
        }
        
        //i parse
        let it = try! doc.select("span[data-nodetype=i]")
        for i in 0 ..< it.size() {
            let textI = try! it.get(i).text()
            try! it.get(i).wrap("<i>\(textI)</i>")
            try! it.get(i).remove()
        }
        
        //u parse
        let u = try! doc.select("span[data-nodetype=u]")
        for i in 0 ..< u.size() {
            let textU = try! u.get(i).text()
            try! u.get(i).wrap("<u>\(textU)</u>")
            try! u.get(i).remove()
        }
        
        //s parse
        let s = try! doc.select("span[data-nodetype=s]")
        for i in 0 ..< s.size() {
            let textS = try! s.get(i).text()
            try! s.get(i).wrap("<s>\(textS)</s>")
            try! s.get(i).remove()
        }
        
        //center parse
        let center = try! doc.select("span[data-nodetype=center]")
        for i in 0 ..< center.size() {
            let textCenter = try! center.get(i).text()
            try! center.get(i).wrap("<div align=\"center\">\(textCenter)</div>")
            try! center.get(i).remove()
        }
        
        //right parse
        let right = try! doc.select("span[data-nodetype=right]")
        for i in 0 ..< right.size() {
            let textRight = try! right.get(i).text()
            try! right.get(i).wrap("<div align=\"right\">\(textRight)</div>")
            try! right.get(i).remove()
        }
        
        //h1 parse
        let h1 = try! doc.select("span[data-nodetype=h1]")
        for i in 0 ..< h1.size() {
            let textH1 = try! h1.get(i).text()
            try! h1.get(i).wrap("<h1>\(textH1)</h1>")
            try! h1.get(i).remove()
        }
        
        //h2 parse
        let h2 = try! doc.select("span[data-nodetype=h2]")
        for i in 0 ..< h2.size() {
            let textH2 = try! h2.get(i).text()
            try! h2.get(i).wrap("<h2>\(textH2)</h2>")
            try! h2.get(i).remove()
        }
        
        //h3 parse
        let h3 = try! doc.select("span[data-nodetype=h3]")
        for i in 0 ..< h3.size() {
            let textH3 = try! h3.get(i).text()
            try! h3.get(i).wrap("<h3>\(textH3)</h3>")
            try! h3.get(i).remove()
        }
        
        //icon parse
        let icon = try! doc.select("span[data-nodetype=smiley]")
        for i in 0..<icon.size() {
            let pack = try! icon.get(i).attr("data-pack-id")
            let id = try! icon.get(i).attr("data-id")
            try! icon.get(i).wrap("<img src=\"https://s.hkgalden.org/smilies/\(pack)/\(id).png\">")
            try! icon.get(i).remove()
        }
        
        return doc
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
                    let realm = try! Realm()
                    let thisPost = realm.object(ofType: History.self, forPrimaryKey: self.tID)
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
                    }
                    NetworkActivityIndicatorManager.networkOperationFinished()
                    webView.isHidden = false
                }
            })
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            if (navigationAction.request.url?.absoluteString.contains("hkgalden.org"))! {
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
