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

class ComposeViewController: UIViewController, UITextFieldDelegate,IconKeyboardDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,RichEditorDelegate {
    
    //MARK: Properties
    var channel: String!
    var content: String!
    var topicID: Int!
    var quoteID: String?
    var composeType: ComposeType!
    var contentVC: ContentViewController?
    var threadVC: ThreadListViewController?
    
    let iconKeyboard = IconKeyboard(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 265))
    
    let titleTextField = UITextField()
    let contentTextView = RichEditorView()
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = [RichEditorDefaultOption.clear,RichEditorDefaultOption.undo,RichEditorDefaultOption.redo,RichEditorDefaultOption.bold,RichEditorDefaultOption.italic,RichEditorDefaultOption.underline,RichEditorDefaultOption.strike,RichEditorDefaultOption.alignCenter,RichEditorDefaultOption.alignRight,RichEditorDefaultOption.header(1),RichEditorDefaultOption.header(2),RichEditorDefaultOption.header(3)]
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
        
        contentTextView.webView.isOpaque = false
        contentTextView.webView.backgroundColor = .clear
        contentTextView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        toolbar.editor = contentTextView
        contentTextView.delegate = self
        
        titleTextField.delegate = self
        titleTextField.borderStyle = .none
        titleTextField.backgroundColor = .white
        titleTextField.placeholder = "標題"
        titleTextField.borderStyle = .line
        if #available(iOS 11.0, *) {
            titleTextField.smartInsertDeleteType = .no
            titleTextField.smartQuotesType = .no
            titleTextField.smartDashesType = .no
        } else {
            // Fallback on earlier versions
        }
        view.addSubview(titleTextField)
        view.addSubview(contentTextView)
        
        if composeType == .reply {
            self.title = "回覆"
            titleTextField.removeFromSuperview()
        } else {
            self.title = "發表主題"
            titleTextField.snp.makeConstraints {
                (make) -> Void in
                make.top.equalTo(view.snp.topMargin).offset(10)
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
            }
        }
        
        contentTextView.snp.makeConstraints {
            (make) -> Void in
            if composeType == .reply {
                make.top.equalTo(view.snp.topMargin).offset(10)
            } else {
                make.top.equalTo(titleTextField.snp.bottom).offset(10)
            }
            make.leading.equalTo(view.snp.leadingMargin).offset(0)
            make.trailing.equalTo(view.snp.trailingMargin).offset(0)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-10)
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
            print(contentTextView.contentHTML)
            let parsedHtml = galdenParse(input: contentTextView.contentHTML)
            let replyThreadMutation = ReplyThreadMutation(threadId: topicID, parentId: quoteID, html: parsedHtml)
            HUD.show(.progress)
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
        
        var parsedHtml = "<div id=\"pmc\"><p>\(try! doc.body()!.html())</div>"
        parsedHtml = parsedHtml.replacingOccurrences(of: "<br>", with: "</p>")
        return parsedHtml
    }
    
    //MARK: ImagePickerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        HUD.show(.progress)
        if #available(iOS 11.0, *) {
            let imageURL = info[UIImagePickerControllerImageURL] as! URL
            HKGaldenAPI.shared.imageUpload(imageURL: imageURL, completion: {
                url in
                HUD.flash(.success, delay: 1.0)
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            //obtaining saving path
            let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            let imagePath = documentsPath?.appendingPathComponent("image.jpg")
            
            // extract image from the picker and save it
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                try! UIImageJPEGRepresentation(pickedImage, 1.0)?.write(to: imagePath!)
            }
            HKGaldenAPI.shared.imageUpload(imageURL: imagePath!, completion: {
                url in
                HUD.flash(.success, delay: 1.0)
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    func keyWasTapped(character: String) {
       // contentTextView.insertText("\(character) ")
    }
    
    /*@objc func callIconKeyboard(_ sender: UIButton) {
        if contentTextView.inputView == nil {
            contentTextView.resignFirstResponder()
            contentTextView.inputView = iconKeyboard
            contentTextView.becomeFirstResponder()
        } else {
            contentTextView.resignFirstResponder()
            contentTextView.inputView = nil
            contentTextView.becomeFirstResponder()
        }
    }*/
    
    @objc func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            contentTextView.snp.updateConstraints {
                (make) -> Void in
                make.bottom.equalTo(view.snp.bottomMargin).offset(-keyboardHeight)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        // keyboard is dismissed/hidden from the screen
        contentTextView.snp.updateConstraints {
            (make) -> Void in
            make.bottom.equalTo(view.snp.bottomMargin)
        }
    }
    
}
