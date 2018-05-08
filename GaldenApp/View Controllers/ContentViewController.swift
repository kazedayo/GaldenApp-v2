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
import Agrume
import SwiftyJSON
import Kingfisher
import GSMessages

class ContentViewController: UIViewController,UIPopoverPresentationControllerDelegate,UINavigationControllerDelegate,WKNavigationDelegate,WKScriptMessageHandler,GADBannerViewDelegate {
    
    //MARK: Properties
    
    var threadIdReceived: String = ""
    var isRated: Bool = false
    var pageNow: Int = 1
    var op = OP(title: "",name: "",level: "",content: "",contentHTML: "",avatar: "",date: "",good: "",bad: "",gender: "",channel: "",quoteID:"",userID:"",ident:"")
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
    var ident = ""
    var titleLabel = MarqueeLabel()
    private var shadowImageView: UIImageView?
    private var webView: WKWebView!
    
    //HKGalden API (NOT included in GitHub repo)
    let keychain = KeychainSwift()
    
    var activityIndicator = UIActivityIndicatorView()
    var reloadButton = UIButton()
    let adBannerView = GADBannerView()
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
        toolbarItems = [prevButton,flexibleSpace,replyButton,flexibleSpace,pageButton,flexibleSpace,moreButton,flexibleSpace,nextButton]
        
        adBannerView.adUnitID = "ca-app-pub-6919429787140423/1613095078"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        view.addSubview(adBannerView)
        
        webView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
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
        
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        reloadButton.center = self.view.center
        reloadButton.setTitle("重新載入", for: .normal)
        reloadButton.addTarget(self, action: #selector(reloadButtonPressed(_:)), for: .touchUpInside)
        
        HKGaldenAPI.shared.pageCount(postId: threadIdReceived, completion: {
            count in
            self.pageCount = count
            let realm = try! Realm()
            let thisPost = realm.object(ofType: History.self, forPrimaryKey: self.threadIdReceived)
            if thisPost != nil && self.sender == "cell" {
                self.pageNow = thisPost!.page
            }
            self.updateSequence()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prevButton.isEnabled = false
        nextButton.isEnabled = false
        webView.configuration.userContentController.add(self, name: "quote")
        webView.configuration.userContentController.add(self, name: "block")
        webView.configuration.userContentController.add(self, name: "refresh")
        webView.configuration.userContentController.add(self, name: "imageView")
        for subJson in HKGaldenAPI.shared.chList! {
            if subJson["ident"].stringValue == self.ident {
                self.navigationController?.navigationBar.barTintColor = UIColor(hexRGB:subJson["color"].stringValue)
            }
        }
        if (keychain.getBool("noAd") == true) {
            adBannerView.removeFromSuperview()
        } else {
            adBannerView.load(GADRequest())
            webView.scrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: (navigationController?.toolbar.frame.height)! + adBannerView.frame.height, right: 0)
            webView.scrollView.scrollIndicatorInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: (navigationController?.toolbar.frame.height)! + adBannerView.frame.height, right: 0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "quote")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "block")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "refresh")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "imageView")
        self.hideMessage()
        let history = History()
        history.threadID = self.threadIdReceived
        history.page = self.pageNow
        history.position = self.webView.scrollView.contentOffset.y
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(history,update: true)
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
            HKGaldenAPI.shared.quote(quoteType: "t", quoteID: self.op.quoteID, completion: {
                content in
                self.quoteContent = content
                self.quote()
            })
            } else if pageNow == 1 {
                HKGaldenAPI.shared.quote(quoteType: "r", quoteID: self.comments[Int(type)! + 1].quoteID, completion: {
                    content in
                    self.quoteContent = content
                    self.quote()
                })
            } else {
                HKGaldenAPI.shared.quote(quoteType: "r", quoteID: self.comments[Int(type)!].quoteID, completion: {
                    content in
                    self.quoteContent = content
                    self.quote()
                })
        }
    }
    
    func blockButtonPressed(type: String) {
        if (pageNow == 1 && type == "op") {
            HKGaldenAPI.shared.blockUser(uid: self.op.userID, completion: {
                status in
                if status == "true" {
                    self.blockedUsers.append(self.op.userID)
                    self.updateSequence()
                }
            })
        } else if pageNow == 1 {
            HKGaldenAPI.shared.blockUser(uid: self.comments[Int(type)! + 1].userID, completion: {
                status in
                if status == "true" {
                    self.blockedUsers.append(self.comments[Int(type)! + 1].userID)
                    self.updateSequence()
                }
            })
        } else {
            HKGaldenAPI.shared.blockUser(uid: self.comments[Int(type)!].userID, completion: {
                status in
                if status == "true" {
                    self.blockedUsers.append(self.comments[Int(type)!].userID)
                    self.updateSequence()
                }
            })
        }
    }
    
    func f5buttonPressed() {
        self.f5 = true
        self.scrollPosition = self.webView.scrollView.contentOffset.y
        self.updateSequence()
    }
    
    @objc func moreButtonPressed() {
        let menuVC = ContentMenuViewController()
        menuVC.modalPresentationStyle = .overFullScreen
        menuVC.upvote = Int(self.op.good)!
        menuVC.downvote = Int(self.op.bad)!
        menuVC.opName = self.op.name
        menuVC.threadTitle = self.op.title
        menuVC.threadID = self.threadIdReceived
        menuVC.rated = self.isRated
        menuVC.hero.isEnabled = true
        menuVC.hero.modalAnimationType = .fade
        menuVC.mainVC = self
        present(menuVC, animated: true, completion: nil)
    }
    
    @objc func pageButtonPressed() {
        let pageVC = PagePopoverTableViewController()
        pageVC.modalPresentationStyle = .overFullScreen
        pageVC.threadID = self.threadIdReceived
        pageVC.pageCount = Int(self.pageCount)
        pageVC.pageSelected = self.pageNow
        pageVC.hero.isEnabled = true
        pageVC.hero.modalAnimationType = .fade
        pageVC.mainVC = self
        present(pageVC, animated: true, completion: nil)
    }
    
    @objc func replyButtonPressed() {
        let composeVC = ComposeViewController()
        composeVC.topicID = self.threadIdReceived
        composeVC.type = "reply"
        composeVC.modalPresentationStyle = .overFullScreen
        composeVC.hero.isEnabled = true
        composeVC.hero.modalAnimationType = .fade
        composeVC.contentVC = self
        present(composeVC, animated: true, completion: nil)
    }
    
    func quote() {
        let composeVC = ComposeViewController()
        composeVC.topicID = self.threadIdReceived
        composeVC.content = self.quoteContent + "\n"
        composeVC.type = "reply"
        composeVC.modalPresentationStyle = .overFullScreen
        composeVC.hero.isEnabled = true
        composeVC.hero.modalAnimationType = .fade
        composeVC.contentVC = self
        present(composeVC, animated: true, completion: nil)
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
            self.replied = true
            xbbcodeBridge.shared.sender = "content"
            self.updateSequence()
        })
    }
    
    func share(shareContent: String) {
        let shareView = UIActivityViewController(activityItems:[shareContent],applicationActivities:nil)
        shareView.excludedActivityTypes = [.airDrop,.addToReadingList,.assignToContact,.openInIBooks,.saveToCameraRoll]
        DispatchQueue.main.asyncAfter(deadline: 0.5, execute: {
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
                        self.replied = true
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
        updateSequence()
    }
    
    @objc func nextButtonPressed(_ sender: UIBarButtonItem) {
        pageNow += 1
        updateSequence()
    }
    
    @objc func reloadButtonPressed(_ sender: UIButton) {
        self.updateSequence()
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
        self.view.addSubview(activityIndicator)
        self.prevButton.isEnabled = false
        self.nextButton.isEnabled = false
        HKGaldenAPI.shared.pageCount(postId: threadIdReceived, completion: {
            count in
            self.pageCount = count
            self.buttonLogic()
        })
        pageButton.title = "第\(self.pageNow)頁"
        HKGaldenAPI.shared.fetchContent(postId: threadIdReceived, pageNo: String(pageNow), completion: {
            op,comments,rated,blocked,error in
            if (error == nil) {
                self.reloadButton.removeFromSuperview()
                self.op = op!
                self.comments = comments!
                self.blockedUsers = blocked!
                self.isRated = rated!
                self.titleLabel.text = self.op.title
                self.titleLabel.textColor = .white
                self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
                self.titleLabel.animationDelay = 1
                self.titleLabel.marqueeType = .MLLeftRight
                self.titleLabel.fadeLength = 5
                self.titleLabel.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
                self.titleLabel.textAlignment = .center
                for subJson in HKGaldenAPI.shared.chList! {
                    if subJson["ident"].stringValue == self.op.ident {
                        self.navigationController?.navigationBar.barTintColor = UIColor(hexRGB:subJson["color"].stringValue)
                    }
                }
                self.navigationItem.titleView = self.titleLabel
                self.convertedHTML = ""
                if self.pageNow == 1 {
                    xbbcodeBridge.shared.convertBBCodeToHTML(text: op!.content)
                    self.op.contentHTML = (xbbcodeBridge.shared.convertedText)!
                    self.constructOPHeader()
                    if (self.blockedUsers.contains(self.op.userID)) {
                        self.op.contentHTML = "<div class=\"comment\" style=\"text-align:center;color:#454545;\">已封鎖</div>"
                    }
                    self.convertedHTML.append(self.op.contentHTML)
                }
                
                for index in 0..<self.comments.count {
                    xbbcodeBridge.shared.convertBBCodeToHTML(text: comments![index].content)
                    self.comments[index].contentHTML = (xbbcodeBridge.shared.convertedText)!
                    self.constructCommentHeader(index: index)
                    if (self.blockedUsers.contains(self.comments[index].userID)) {
                        self.comments[index].contentHTML = "<div class=\"comment\" style=\"text-align:center;color:#454545;\">已封鎖</div>"
                    }
                    self.convertedHTML.append(self.comments[index].contentHTML)
                }
                
                if (self.pageNow==Int(self.pageCount)) {
                    self.convertedHTML.append("<div class=\"refresh\"><button class=\"refresh-button\" onclick=\"window.webkit.messageHandlers.refresh.postMessage('refresh requested')\"></button></div>")
                }
                
                self.pageHTML = "<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0,user-scalable=no\"><link rel=\"stylesheet\" href=\"content.css\"><script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js\"></script><script type=\"text/javascript\" src=\"redrawImg.js\"></script></head><body>\(self.convertedHTML)</body></html>"
                self.webView.loadHTMLString(self.pageHTML, baseURL: Bundle.main.bundleURL)
                NetworkActivityIndicatorManager.networkOperationStarted()
            } else {
                self.activityIndicator.removeFromSuperview()
                self.view.addSubview(self.reloadButton)
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
            self.op.contentHTML = self.op.contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">label</td>", with: "<td class=\"lefttext\">\(self.op.userID)</td>")
        } else if self.op.level == "lv2" {
            self.op.contentHTML = self.op.contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">label</td>", with: "<td class=\"lefttext\" style=\"color:#9e3e3f;\">\(self.op.userID)</td>")
        } else if self.op.level == "lv3" {
            self.op.contentHTML = self.op.contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">label</td>", with: "<td class=\"lefttext\" style=\"color:#5549c9;\">\(self.op.userID)</td>")
        } else if self.op.level == "lv5" {
            self.op.contentHTML = self.op.contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">label</td>", with: "<td class=\"lefttext\" style=\"color:#4b6690;\">\(self.op.userID)</td>")
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
            self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">label</td>", with: "<td class=\"lefttext\">\(self.comments[index].userID)</td>")
        } else if self.comments[index].level == "lv2" {
            self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">label</td>", with: "<td class=\"lefttext\" style=\"color:#9e3e3f;\">\(self.comments[index].userID)</td>")
        } else if self.comments[index].level == "lv3" {
            self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">label</td>", with: "<td class=\"lefttext\" style=\"color:#5549c9;\">\(self.comments[index].userID)</td>")
        } else if self.comments[index].level == "lv5" {
            self.comments[index].contentHTML = self.comments[index].contentHTML.replacingOccurrences(of: "<td class=\"lefttext\">label</td>", with: "<td class=\"lefttext\" style=\"color:#4b6690;\">\(self.comments[index].userID)</td>")
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
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.activityIndicator.removeFromSuperview()
        webView.isHidden = false
        self.showMessage("撈緊...(超過~10秒代表post內圖片可能死圖)", type: .error, options: [.autoHide(false)])
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        NetworkActivityIndicatorManager.networkOperationFinished()
        webView.evaluateJavaScript("document.body.style.webkitTouchCallout='none';")
        DispatchQueue.main.asyncAfter(deadline: 0.3, execute: {
            self.hideMessage()
            if self.replied == true {
                webView.evaluateJavaScript("document.body.offsetHeight", completionHandler: {(result, error) in
                    let height = result as! CGFloat
                    let scrollPoint = CGPoint(x: 0, y: height - webView.frame.size.height)
                    webView.scrollView.setContentOffset(scrollPoint, animated: true)
                    self.showMessage("回覆成功!(移到頁尾)", type: .info)
                    self.replied = false
                })
            } else if self.f5 == true {
                webView.evaluateJavaScript("document.body.offsetHeight", completionHandler: {(result, error) in
                    let scrollPoint = CGPoint.init(x: 0, y: self.scrollPosition)
                    webView.scrollView.setContentOffset(scrollPoint, animated: true)
                    self.showMessage("撈完!(移到頁尾)", type: .info)
                    self.f5 = false
                })
            } else if self.loaded == false {
                let realm = try! Realm()
                let thisPost = realm.object(ofType: History.self, forPrimaryKey: self.threadIdReceived)
                if thisPost != nil && self.sender == "cell" {
                    self.webView.scrollView.setContentOffset(CGPoint.init(x: 0, y: (thisPost?.position)!), animated: true)
                    self.showMessage("撈完!(移到最後觀看位置)", type: .info)
                } else {
                    self.showMessage("撈完!", type: .info)
                }
                self.loaded = true
            } else {
                self.showMessage("撈完!", type: .info)
            }
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            let imageType = ["jpg","png","gif","jpeg","jpg-large","png-large","jpg:large","png:large"]
            if imageType.contains((navigationAction.request.url?.pathExtension)!) {
                let url = navigationAction.request.url
                //open image viewer
                let agrume = Agrume(imageUrl: url!)
                agrume.showFrom(self)
                decisionHandler(.cancel)
            } else if (navigationAction.request.url?.absoluteString.contains("hkgalden.com/view/"))! {
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
            let alert = UIAlertController.init(title: "扑柒", message: "你確定要扑柒此會然?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction.init(title: "55", style: .destructive, handler: {
                _ in
                self.blockButtonPressed(type: message.body as! String)
            }))
            alert.addAction(UIAlertAction.init(title: "不了", style: .cancel, handler: nil))
            present(alert,animated: true)
        } else if message.name == "refresh" {
            self.f5buttonPressed()
        } else if message.name == "imageView" {
            let url = message.body as! URL
            let agrume = Agrume(imageUrl: url)
            agrume.showFrom(self)
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
