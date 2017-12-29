//
//  NewPostPreviewViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 17/11/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import JavaScriptCore
import MarqueeLabel
import WebKit
import PKHUD

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var viewTitle: MarqueeLabel!
    @IBOutlet weak var previewContent: WKWebView!
    @IBOutlet weak var submitButton: UIButton!
    
    var threadTitle: String?
    var content: String?
    var channel: String?
    var convertedText: String?
    var topicID: String?
    var type: String?
    
    let api = HKGaldenAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeJS()
        NotificationCenter.default.addObserver(self, selector: #selector(ContentViewController.handleBBCodeToHTMLNotification(notification:)), name: NSNotification.Name("bbcodeToHTMLNotification"), object: nil)
        var contentPreviewText = content!
        contentPreviewText = api.sizeTagCorrection(bbcode: contentPreviewText)
        contentPreviewText = api.iconParse(bbcode: contentPreviewText)
        convertBBCodeToHTML(text: contentPreviewText)
        previewContent.loadHTMLString(convertedText!, baseURL: Bundle.main.bundleURL)
        viewTitle.text = threadTitle
        if type == "reply" {
            viewTitle.text = "回覆預覽"
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
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        HUD.show(.progress)
        if type == "newThread" {
            api.submitPost(channel: channel!, title: threadTitle!, content: content!, completion: {
                [weak self] in
                self?.performSegue(withIdentifier: "unwindToThreadListAfterNewPost", sender: self)
            })
        } else if type == "reply" {
            api.reply(topicID: topicID!, content: content!, completion: {
                [weak self] in
                self?.performSegue(withIdentifier: "unwindAfterReply", sender: self)
            })
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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
            let newContent = "<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"><link rel=\"stylesheet\" href=\"content.css\"></head><body>\(html)</body></html>"
            convertedText = newContent
        }
    }
    
}
