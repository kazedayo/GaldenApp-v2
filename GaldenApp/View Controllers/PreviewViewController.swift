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
    var composeVC: ComposeViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "發表", style: .done, target: self, action: #selector(sendButtonPressed(_:)))
        
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
        navigationItem.titleView = titleLabel
        
        webView.isOpaque = false
        webView.backgroundColor = .clear
        previewText = contentText!
        previewText = HKGaldenAPI.shared.sizeTagCorrection(bbcode: previewText!)
        previewText = HKGaldenAPI.shared.iconParse(bbcode: previewText!)
        view.addSubview(webView)
        
        webView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(view.snp.topMargin).offset(10)
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-10)
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.style.webkitTouchCallout='none';")
        webView.evaluateJavaScript("new Blazy();")
    }
    
}
