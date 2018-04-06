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

class PreviewViewController: UIViewController {
    
    var type: String?
    var titleText: String?
    var contentText: String?
    let backgroundView = UIView()
    let titleLabel = MarqueeLabel()
    var webView = WKWebView()
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
        
        backgroundView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        backgroundView.addGestureRecognizer(swipeToDismiss)
        backgroundView.layer.cornerRadius = 10
        backgroundView.hero.modifiers = [.position(CGPoint(x: view.frame.midX, y: 1000))]
        view.addSubview(backgroundView)
        
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.animationDelay = 1
        titleLabel.marqueeType = .MLLeftRight
        titleLabel.fadeLength = 5
        if type == "reply" {
            titleLabel.text = "回覆預覽"
        } else {
            titleLabel.text = titleText!
        }
        backgroundView.addSubview(titleLabel)
        
        webView.isOpaque = false
        webView.backgroundColor = .clear
        contentText = HKGaldenAPI.shared.iconParse(bbcode: contentText!)
        xbbcodeBridge.shared.convertBBCodeToHTML(text: contentText!)
        xbbcodeBridge.shared.convertedText = HKGaldenAPI.shared.iconParse(bbcode: xbbcodeBridge.shared.convertedText!)
        webView.loadHTMLString("<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0,user-scalable=no\"><link rel=\"stylesheet\" href=\"content.css\"></head><body>\((xbbcodeBridge.shared.convertedText!))</body></html>", baseURL: Bundle.main.bundleURL)
        backgroundView.addSubview(webView)
        
        backgroundView.snp.makeConstraints {
            (make) -> Void in
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.bottom.equalTo(-15)
            make.height.equalTo(450)
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
    
}
