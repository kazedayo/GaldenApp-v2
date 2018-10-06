//
//  ComposeViewController.swift
//  GaldenApp
//
//  Created by 1080 on 28/9/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import PKHUD
import IQKeyboardManagerSwift
import SwiftEntryKit
import RichEditorView
import SwiftSoup
import ImageIO

class ComposeViewController: UIViewController, UITextFieldDelegate,IconKeyboardDelegate,UINavigationControllerDelegate,RichEditorDelegate,RichEditorToolbarDelegate {
    
    //MARK: Properties
    var tagID: String?
    var topicID: Int!
    var quoteID: String?
    var composeType: ComposeType!
    var contentVC: ContentViewController?
    var threadVC: ThreadListViewController?
    
    let iconKeyboard = IconKeyboard()
    
    let titleTextField = UITextField()
    let contentTextView = RichEditorView()
    lazy var selectTagLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexRGB: "aaaaaa")
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.text = "標籤: "
        return label
    }()
    lazy var tagButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor(hexRGB: "#568064")
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setTitle("選擇...", for: .normal)
        button.addTarget(self, action: #selector(tagButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = [RichEditorDefaultOption.image,RichEditorDefaultOption.link,RichEditorDefaultOption.clear,RichEditorDefaultOption.bold,RichEditorDefaultOption.italic,RichEditorDefaultOption.underline,RichEditorDefaultOption.strike,RichEditorDefaultOption.alignCenter,RichEditorDefaultOption.alignRight,RichEditorDefaultOption.header(1),RichEditorDefaultOption.header(2),RichEditorDefaultOption.header(3)]
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Do any additional setup after loading the view.
        navigationController?.isNavigationBarHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "發表", style: .done, target: self, action: #selector(submitButtonPressed(_:)))
        iconKeyboard.keyboardDelegate = self
        let insertIcon = RichEditorOptionItem(image: UIImage(named: "Icon"), title: "Icon") { toolbar in
            self.callIconKeyboard()
            return
        }
        toolbar.options.insert(insertIcon, at: 0)
        
        contentTextView.webView.isOpaque = false
        contentTextView.webView.backgroundColor = .clear
        contentTextView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        toolbar.editor = contentTextView
        toolbar.delegate = self
        contentTextView.delegate = self
        
        titleTextField.delegate = self
        titleTextField.borderStyle = .none
        titleTextField.borderColor = .clear
        titleTextField.backgroundColor = .clear
        titleTextField.attributedPlaceholder = NSAttributedString(string: "標題", attributes: [NSAttributedStringKey.foregroundColor : UIColor.lightGray])
        titleTextField.textColor = UIColor(hexRGB: "aaaaaa")
        if #available(iOS 11.0, *) {
            titleTextField.smartInsertDeleteType = .no
            titleTextField.smartQuotesType = .no
            titleTextField.smartDashesType = .no
        } else {
            // Fallback on earlier versions
        }
        view.addSubview(contentTextView)
        
        if composeType == .reply {
            self.title = "回覆"
        } else {
            self.title = "發表主題"
            view.addSubview(titleTextField)
            view.addSubview(selectTagLabel)
            view.addSubview(tagButton)
            titleTextField.snp.makeConstraints {
                (make) -> Void in
                make.top.equalTo(view.snp.topMargin).offset(10)
                make.leading.equalTo(view.snp.leadingMargin).offset(0)
                make.trailing.equalTo(view.snp.trailingMargin).offset(0)
            }
            selectTagLabel.snp.makeConstraints {
                (make) -> Void in
                make.top.equalTo(contentTextView.snp.bottom).offset(10)
                make.leading.equalTo(view.snp.leadingMargin).offset(2)
                make.bottom.equalTo(view.snp.bottomMargin).offset(-10)
            }
            tagButton.snp.makeConstraints {
                (make) -> Void in
                make.top.equalTo(contentTextView.snp.bottom).offset(10)
                make.leading.equalTo(selectTagLabel.snp.trailing).offset(10)
                make.bottom.equalTo(view.snp.bottomMargin).offset(-10)
            }
        }
        
        contentTextView.snp.makeConstraints {
            (make) -> Void in
            if composeType == .reply {
                make.top.equalTo(view.snp.topMargin).offset(10)
                make.bottom.equalTo(view.snp.bottomMargin).offset(-10)
            } else {
                make.top.equalTo(titleTextField.snp.bottom).offset(10)
            }
            make.leading.equalTo(view.snp.leadingMargin).offset(0)
            make.trailing.equalTo(view.snp.trailingMargin).offset(0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func richEditorDidLoad(_ editor: RichEditorView) {
        editor.placeholder = "內容"
        editor.setEditorBackgroundColor(UIColor(white: 0.15, alpha: 1))
        editor.setEditorFontColor(UIColor(hexRGB: "aaaaaa")!)
        editor.inputAccessoryView = toolbar
        editor.becomeFirstResponder()
    }
    
    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        let alert = UIAlertController(title: nil, message: "鏈結網址", preferredStyle: .alert)
        alert.addTextField {
            textfield in
            textfield.placeholder = "url"
        }
        let ok = UIAlertAction(title: "OK", style: .default, handler: {
            _ in
            let textfield = alert.textFields?.first
            toolbar.editor?.insertComponent("<a href=\"\((textfield?.text)!)\">\((textfield?.text)!)</a>")
        })
        let cancel = UIAlertAction(title: "不了", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert,animated: true,completion: nil)
    }
    
    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        let alert = UIAlertController(title: nil, message: "圖片網址", preferredStyle: .alert)
        alert.addTextField {
            textfield in
            textfield.placeholder = "url"
        }
        let ok = UIAlertAction(title: "OK", style: .default, handler: {
            _ in
            let textfield = alert.textFields?.first
            toolbar.editor?.insertImage((textfield?.text)!, alt: "")
        })
        let cancel = UIAlertAction(title: "不了", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert,animated: true,completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
    }
    
    //MARK: Actions
    
    @objc func submitButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if (composeType == .newThread && titleTextField.text == "") {
            let alert = UIAlertController.init(title: "注意", message: "標題不可爲空", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: {
                action in
                self.contentTextView.becomeFirstResponder()
            }))
            self.present(alert,animated: true,completion: nil)
        }
        if (contentTextView.contentHTML == "" || contentTextView.contentHTML == "<br>") {
            let alert = UIAlertController.init(title: "注意", message: "內容不可爲空", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: {
                action in
                self.contentTextView.becomeFirstResponder()
            }))
            self.present(alert,animated: true,completion: nil)
        } else {
            let parsedHtml = galdenParse(input: contentTextView.contentHTML)
            HUD.show(.progress)
            if composeType == .reply {
                let replyThreadMutation = ReplyThreadMutation(threadId: topicID, parentId: quoteID, html: parsedHtml)
                apollo.perform(mutation: replyThreadMutation) {
                    [weak self] result, error in
                    if error == nil {
                        HUD.flash(.success)
                        self?.dismiss(animated: true, completion: nil)
                        self?.contentVC?.unwindAfterReply()
                    } else {
                        HUD.flash(.error)
                        print(error!)
                    }
                }
            } else {
                if tagID == nil {
                    let alert = UIAlertController.init(title: "注意", message: "請選擇標籤", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: {
                        action in
                        self.contentTextView.becomeFirstResponder()
                    }))
                    self.present(alert,animated: true,completion: nil)
                } else {
                    let createThreadMutation = CreateThreadMutation(title: titleTextField.text!, tags: [tagID!], html: parsedHtml)
                    apollo.perform(mutation: createThreadMutation) {
                        [weak self] result, error in
                        if error == nil {
                            HUD.flash(.success)
                            self?.dismiss(animated: true, completion: nil)
                            self?.threadVC?.unwindToThreadListAfterNewPost()
                        } else {
                            HUD.flash(.error)
                            print(error!)
                        }
                    }
                }
            }
        }
    }
    
    private func galdenParse(input: String) -> String {
        let doc = try! SwiftSoup.parse(contentTextView.html)
        
        //p tag hack
        let div = try! doc.select("div")
        if div.first() != nil {
            try! div.first()!.before("<br>")
        } else {
            try! doc.body()!.append("<br>")
        }
        for i in 0 ..< div.size() {
            try! div.get(i).tagName("p")
        }
        
        //b parse
        let b = try! doc.select("b")
        for i in 0 ..< b.size() {
            try! b.get(i).attr("data-nodetype", "b")
            try! b.get(i).tagName("span")
        }
        
        //i parse
        let it = try! doc.select("i")
        for i in 0 ..< it.size() {
            try! it.get(i).attr("data-nodetype", "i")
            try! it.get(i).tagName("span")
        }
        
        //u parse
        let u = try! doc.select("u")
        for i in 0 ..< u.size() {
            try! u.get(i).attr("data-nodetype", "u")
            try! u.get(i).tagName("span")
        }
        
        //s parse
        let s = try! doc.select("strike")
        for i in 0 ..< s.size() {
            try! s.get(i).attr("data-nodetype", "s")
            try! s.get(i).tagName("span")
        }
        
        //center parse
        let center = try! doc.select("p[style=text-align: center;]")
        for i in 0 ..< center.size() {
            try! center.get(i).removeAttr("style")
            try! center.get(i).attr("data-nodetype", "center")
            try! center.get(i).tagName("p")
        }
        
        //right parse
        let right = try! doc.select("p[style=text-align: right;]")
        for i in 0 ..< right.size() {
            try! center.get(i).removeAttr("style")
            try! right.get(i).attr("data-nodetype", "right")
            try! right.get(i).tagName("p")
        }
        
        //h1 parse
        let h1 = try! doc.select("h1")
        for i in 0 ..< h1.size() {
            try! h1.get(i).attr("data-nodetype", "h1")
            try! h1.get(i).tagName("span")
        }
        
        //h2 parse
        let h2 = try! doc.select("h2")
        for i in 0 ..< h2.size() {
            try! h2.get(i).attr("data-nodetype", "h2")
            try! h2.get(i).tagName("span")
        }
        
        //h3 parse
        let h3 = try! doc.select("h3")
        for i in 0 ..< h3.size() {
            try! h3.get(i).attr("data-nodetype", "h3")
            try! h3.get(i).tagName("span")
        }
        
        //icon parse
        let icon = try! doc.select("img.icon")
        for i in 0 ..< icon.size() {
            try! icon.get(i).removeAttr("class")
            try! icon.get(i).removeAttr("src")
            try! icon.get(i).tagName("span")
        }
        
        //image parse
        let img = try! doc.select("img")
        for i in 0 ..< img.size() {
            let src = try! img.get(i).attr("src")
            try! img.removeAttr("src")
            try! img.removeAttr("alt")
            try! img.attr("data-nodetype", "img")
            try! img.attr("data-src", src)
            let url = URL(string: src)
            if let imageSource = CGImageSourceCreateWithURL(url! as CFURL, nil) {
                if let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary? {
                    let pixelWidth = imageProperties[kCGImagePropertyPixelWidth] as! Int
                    let pixelHeight = imageProperties[kCGImagePropertyPixelHeight] as! Int
                    try! img.attr("data-sx", String(pixelWidth))
                    try! img.attr("data-sy", String(pixelHeight))
                }
            }
            try! img.tagName("span")
        }
        
        //url parse
        let url = try! doc.select("a")
        for i in 0 ..< url.size() {
            let href = try! url.get(i).attr("href")
            try! url.get(i).wrap("<span data-nodetype=\"a\" data-href=\"\(href)\"></span>")
            try! url.get(i).remove()
        }
        
        var parsedHtml = "<div id=\"pmc\"><p>\(try! doc.body()!.html())</div>"
        parsedHtml = parsedHtml.replacingOccurrences(of: "<br>", with: "</p>")
        return parsedHtml
    }
    
    func keyWasTapped(character: String) {
        contentTextView.insertComponent(character)
        SwiftEntryKit.dismiss()
    }
    
    func unwindToCompose(tagName: String,tagID: String,tagColor: String) {
        self.tagID = tagID
        tagButton.setTitle(tagName, for: .normal)
        tagButton.setTitleColor(UIColor(hexRGB: tagColor), for: .normal)
    }
    
    @objc func callIconKeyboard() {
        //contentTextView.resignFirstResponder()
        let attributes = EntryAttributes.shared.iconEntry()
        SwiftEntryKit.display(entry: iconKeyboard, using: attributes)
    }
    
    @objc func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func tagButtonPressed(_ sender: UIButton) {
        let tagsVC = TagsTableViewController()
        let attributes = EntryAttributes.shared.iconEntry()
        tagsVC.composeVC = self
        SwiftEntryKit.display(entry: tagsVC, using: attributes)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            if composeType == .reply {
                contentTextView.snp.updateConstraints {
                    (make) -> Void in
                    make.bottom.equalTo(view.snp.bottomMargin).offset(-keyboardHeight)
                }
            } else {
                selectTagLabel.snp.updateConstraints {
                    (make) -> Void in
                    make.bottom.equalTo(view.snp.bottomMargin).offset(-keyboardHeight)
                }
                tagButton.snp.updateConstraints {
                    (make) -> Void in
                    make.bottom.equalTo(view.snp.bottomMargin).offset(-keyboardHeight)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        // keyboard is dismissed/hidden from the screen
        if composeType == .reply {
            contentTextView.snp.updateConstraints {
                (make) -> Void in
                make.bottom.equalTo(view.snp.bottomMargin)
            }
        } else {
            selectTagLabel.snp.updateConstraints {
                (make) -> Void in
                make.bottom.equalTo(view.snp.bottomMargin)
            }
            tagButton.snp.updateConstraints {
                (make) -> Void in
                make.bottom.equalTo(view.snp.bottomMargin)
            }
        }
    }
}
