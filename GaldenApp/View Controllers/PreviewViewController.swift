//
//  PreviewViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 6/4/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import UIKit
import WebKit
import MarqueeLabel
import PKHUD
import SwiftEntryKit

class PreviewViewController: UIViewController,WKNavigationDelegate {
    
    var composeType: ComposeType!
    var topicID: String?
    var channel: Int?
    var titleText: String?
    var contentText: String?
    var previewText: String?
    let backgroundView = UIView()
    let titleLabel = MarqueeLabel()
    var webView = WKWebView()
    let sendButton = UIButton()
    let backButton = UIButton()
    var composeVC: ComposeViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        xbbcodeBridge.shared.sender = "preview"
        webView.navigationDelegate = self
        
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.animationDelay = 1
        titleLabel.marqueeType = .MLLeftRight
        titleLabel.fadeLength = 5
        if composeType == .reply {
            titleLabel.text = "回覆預覽"
        } else {
            titleLabel.text = titleText!
        }
        view.addSubview(titleLabel)
        
        webView.isOpaque = false
        webView.backgroundColor = .clear
        previewText = contentText!
        previewText = HKGaldenAPI.shared.sizeTagCorrection(bbcode: previewText!)
        previewText = HKGaldenAPI.shared.iconParse(bbcode: previewText!)
        xbbcodeBridge.shared.convertBBCodeToHTML(text: previewText!)
        webView.loadHTMLString("<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0,user-scalable=no\"><link rel=\"stylesheet\" href=\"content.css\"><script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js\"></script><script src=\"https://cdn.rawgit.com/kazedayo/js_for_GaldenApp/87d964a5/GaldenApp.js\"></script></head><body>\((xbbcodeBridge.shared.convertedText!))<script src=\"https://cdn.jsdelivr.net/blazy/latest/blazy.min.js\"></script></body></html>", baseURL: Bundle.main.bundleURL)
        view.addSubview(webView)
        
        sendButton.setTitle("發表", for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        sendButton.cornerRadius = 5
        sendButton.borderWidth = 1
        sendButton.backgroundColor = UIColor(hexRGB: "0076ff")
        sendButton.addTarget(self, action: #selector(sendButtonPressed(_:)), for: .touchUpInside)
        view.addSubview(sendButton)
        
        backButton.setTitle("返回", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        backButton.cornerRadius = 5
        backButton.borderWidth = 1
        backButton.backgroundColor = .red
        backButton.addTarget(self, action: #selector(backButtonPressed(_:)), for: .touchUpInside)
        view.addSubview(backButton)
        
        titleLabel.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(15)
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
        }
        
        webView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
        }
        
        sendButton.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(webView.snp.bottom).offset(10)
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
        }
        
        backButton.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(sendButton.snp.bottom).offset(10)
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.bottom.equalTo(-15)
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func sendButtonPressed(_ sender: UIButton) {
        HUD.show(.progress)
        if composeType == .newThread {
            HKGaldenAPI.shared.submitPost(channel: HKGaldenAPI.shared.chList![channel!]["ident"].stringValue, title: titleText!, content: contentText!, completion: {
                error in
                if error == nil {
                    SwiftEntryKit.dismiss()
                    self.composeVC.threadVC?.unwindToThreadListAfterNewPost()
                }
            })
        } else {
            HKGaldenAPI.shared.reply(topicID: topicID!, content: contentText!, completion: {
                error in
                if error == nil {
                    SwiftEntryKit.dismiss()
                    self.composeVC.contentVC?.unwindAfterReply()
                }
            })
        }
    }
    
    @objc func backButtonPressed(_ sender: UIButton) {
        var attributes = EKAttributes()
        attributes.position = .bottom
        attributes.displayPriority = .normal
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.9)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.constant(value: 350)
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        attributes.positionConstraints.verticalOffset = 20
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.displayDuration = .infinity
        attributes.screenInteraction = .absorbTouches
        attributes.screenBackground = .visualEffect(style: .dark)
        attributes.entryBackground = .color(color: UIColor(white: 0.2, alpha: 1))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 10, offset: .zero))
        attributes.roundCorners = .all(radius: 10)
        attributes.entranceAnimation = .init(translate: EKAttributes.Animation.Translate.init(duration: 0.5, anchorPosition: .bottom, delay: 0, spring: EKAttributes.Animation.Spring.init(damping: 1, initialVelocity: 0)), scale: nil, fade: nil)
        SwiftEntryKit.display(entry: composeVC, using: attributes)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.style.webkitTouchCallout='none';")
        webView.evaluateJavaScript("new Blazy();")
    }
    
}
