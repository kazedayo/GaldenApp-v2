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
    var composeVC: ComposeViewController!
    
    lazy var swipeToDismiss = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler(_:)))
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    var backgroundViewOriginalPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundViewOriginalPoint = CGPoint(x: backgroundView.frame.minX, y: backgroundView.frame.minY)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        xbbcodeBridge.shared.sender = "preview"
        view.addGestureRecognizer(swipeToDismiss)
        webView.navigationDelegate = self
        
        backgroundView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        backgroundView.layer.cornerRadius = 10
        backgroundView.hero.modifiers = [.position(CGPoint(x: view.frame.midX, y: 1000))]
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOpacity = 1
        backgroundView.layer.shadowOffset = CGSize.zero
        backgroundView.layer.shadowRadius = 10
        view.addSubview(backgroundView)
        
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
        backgroundView.addSubview(titleLabel)
        
        webView.isOpaque = false
        webView.backgroundColor = .clear
        previewText = contentText!
        previewText = HKGaldenAPI.shared.sizeTagCorrection(bbcode: previewText!)
        previewText = HKGaldenAPI.shared.iconParse(bbcode: previewText!)
        xbbcodeBridge.shared.convertBBCodeToHTML(text: previewText!)
        webView.loadHTMLString("<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0,user-scalable=no\"><link rel=\"stylesheet\" href=\"content.css\"><script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js\"></script><script src=\"https://cdn.rawgit.com/kazedayo/js_for_GaldenApp/87d964a5/GaldenApp.js\"></script></head><body>\((xbbcodeBridge.shared.convertedText!))<script src=\"https://cdn.jsdelivr.net/blazy/latest/blazy.min.js\"></script></body></html>", baseURL: Bundle.main.bundleURL)
        backgroundView.addSubview(webView)
        
        sendButton.setTitle("發表", for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        sendButton.cornerRadius = 5
        sendButton.borderWidth = 1
        sendButton.backgroundColor = UIColor(hexRGB: "0076ff")
        sendButton.addTarget(self, action: #selector(sendButtonPressed(_:)), for: .touchUpInside)
        backgroundView.addSubview(sendButton)
        
        backgroundView.snp.makeConstraints {
            (make) -> Void in
            make.bottom.equalTo(view.snp.bottomMargin).offset(-15)
            make.height.equalTo(400)
            make.width.lessThanOrEqualTo(500)
            make.leadingMargin.greaterThanOrEqualTo(15)
            make.trailingMargin.greaterThanOrEqualTo(-15)
            make.centerX.equalToSuperview()
        }
        
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
    
    @objc func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        
        if sender.state == UIGestureRecognizerState.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizerState.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.backgroundView.frame = CGRect(x: backgroundViewOriginalPoint.x, y: backgroundViewOriginalPoint.y + (touchPoint.y - initialTouchPoint.y), width: self.backgroundView.frame.size.width, height: self.backgroundView.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            if touchPoint.y - initialTouchPoint.y > 100 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.backgroundView.frame = CGRect(x: self.backgroundViewOriginalPoint.x, y: self.backgroundViewOriginalPoint.y, width: self.backgroundView.frame.size.width, height: self.backgroundView.frame.size.height)
                })
            }
        }
    }
    
    @objc func sendButtonPressed(_ sender: UIButton) {
        HUD.show(.progress)
        if composeType == .newThread {
            HKGaldenAPI.shared.submitPost(channel: HKGaldenAPI.shared.chList![channel!]["ident"].stringValue, title: titleText!, content: contentText!, completion: {
                error in
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                    self.composeVC.dismiss(animated: true, completion: nil)
                    self.composeVC.threadVC?.unwindToThreadListAfterNewPost()
                }
            })
        } else {
            HKGaldenAPI.shared.reply(topicID: topicID!, content: contentText!, completion: {
                error in
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                    self.composeVC.dismiss(animated: true, completion: nil)
                    xbbcodeBridge.shared.sender = "content"
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
