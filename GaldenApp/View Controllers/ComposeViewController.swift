//
//  ComposeViewController.swift
//  GaldenApp
//
//  Created by 1080 on 28/9/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import PKHUD
import SwiftEntryKit
import RichEditorView
import SwiftSoup
import ImageIO
import Alamofire
import SwiftyJSON
import Typist

class ComposeViewController: UIViewController, UITextFieldDelegate,IconKeyboardDelegate,UINavigationControllerDelegate,RichEditorDelegate,UIImagePickerControllerDelegate {
    
    //MARK: Properties
    var topicID: Int!
    var quoteID: String?
    var contentVC: ContentViewController?
    var iconKeyboardShowing = false
    
    let iconKeyboard = IconKeyboard()
    
    let contentTextView = RichEditorView()
    let stackView = UIStackView()
    let keyboard = Typist()
    lazy var imageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "camera.on.rectangle"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(imageButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    lazy var linkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "link"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(linkButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    lazy var iconButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "smiley"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(callIconKeyboard), for: .touchUpInside)
        return button
    }()
    
    /*override var preferredContentSize: CGSize {
        get {
            if let fullSize = self.presentingViewController?.view.bounds.size {
                return CGSize(width: fullSize.width * 0.75, height: fullSize.height * 0.75)
            }
            return super.preferredContentSize
        }
        set {
            super.preferredContentSize = newValue
        }
    }*/
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            contentTextView.setEditorFontColor(.label)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Do any additional setup after loading the view.
        navigationController?.isNavigationBarHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "發表", style: .done, target: self, action: #selector(submitButtonPressed(_:)))
        iconKeyboard.keyboardDelegate = self
        
        contentTextView.webView.isOpaque = false
        contentTextView.webView.backgroundColor = .systemBackground
        contentTextView.backgroundColor = .systemBackground
        contentTextView.webView.scrollView.clipsToBounds = true
        if #available(iOS 11.0, *) {
            contentTextView.webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        contentTextView.delegate = self
        
        view.addSubview(contentTextView)
        
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 15
        stackView.addArrangedSubview(imageButton)
        stackView.addArrangedSubview(linkButton)
        stackView.addArrangedSubview(iconButton)
        view.addSubview(stackView)
        
        self.title = "回覆"
        
        contentTextView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(view.snp.topMargin).offset(15)
            make.leading.equalTo(view.snp.leadingMargin).offset(0)
            make.trailing.equalTo(view.snp.trailingMargin).offset(0)
        }
        
        stackView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(contentTextView.snp.bottomMargin).offset(15)
            make.bottom.equalTo(view.snp.bottom).offset(-15)
            make.leading.equalTo(view.snp.leadingMargin)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureKeyboard()
        contentTextView.becomeFirstResponder()
        UIBarButtonItem.appearance().tintColor = .label
        navigationItem.leftBarButtonItem?.tintColor = .systemGreen
        navigationItem.rightBarButtonItem?.tintColor = .systemGreen

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboard.clear()
        self.view.endEditing(true)
        self.contentTextView.resignFirstResponder()
        UIBarButtonItem.appearance().tintColor = .systemGreen
    }
    
    func richEditorDidLoad(_ editor: RichEditorView) {
        editor.placeholder = "內容"
        //editor.setEditorBackgroundColor(.secondarySystemBackground)
        editor.setEditorFontColor(.label)
    }
    
    @objc func linkButtonPressed(_ button: UIButton) {
        let alert = UIAlertController(title: nil, message: "鏈結網址", preferredStyle: .alert)
        alert.addTextField {
            textfield in
            textfield.placeholder = "url"
        }
        let link = UIAlertAction(title: "插入鏈結", style: .default, handler: {
            _ in
            let textfield = alert.textFields?.first
            self.contentTextView.insertComponent("<a href=\"\((textfield?.text)!)\">\((textfield?.text)!)</a>")
        })
        let image = UIAlertAction(title: "插入圖片", style: .default, handler: {
            _ in
            let textfield = alert.textFields?.first
            self.contentTextView.insertImage((textfield?.text)!, alt: "")
        })
        let cancel = UIAlertAction(title: "不了", style: .cancel, handler: nil)
        alert.addAction(link)
        alert.addAction(image)
        alert.addAction(cancel)
        present(alert,animated: true,completion: nil)
    }
    
    @objc func imageButtonPressed(_ button: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker,animated: true,completion: nil)
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
        if (contentTextView.contentHTML == "" || contentTextView.contentHTML == "<br>") {
            let alert = UIAlertController.init(title: "注意", message: "內容不可爲空", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: {
                action in
                //self.contentTextView.resignFirstResponder()
                self.contentTextView.becomeFirstResponder()
            }))
            self.present(alert,animated: true,completion: nil)
        } else {
            HUD.show(.progress)
            let parsedHtml = galdenParse(input: contentTextView.contentHTML)
            let replyThreadMutation = ReplyThreadMutation(threadId: topicID, parentId: quoteID, html: parsedHtml)
            apollo.perform(mutation: replyThreadMutation) {
                [weak self] result in
                switch result {
                case .success(_):
                    HUD.flash(.success)
                    self?.dismiss(animated: true, completion: {
                        self?.contentTextView.html = ""
                        self?.contentVC?.unwindAfterReply()
                    })
                case .failure(let error):
                    HUD.flash(.error)
                    print(error)
                }
            }
        }
    }
    
    func galdenParse(input: String) -> String {
        let doc = try! SwiftSoup.parse(contentTextView.html)
        
        //p tag hack
        let div = try! doc.select("div")
        if div.first() != nil {
            try! div.first()!.before("<hr>")
            //try! div.first()!.after("<hr>")
        }
        //try! div.first()!.before("<hr>")
        //try! div.first()!.after("<hr>")
        //try! doc.body()!.append("<br>")
        for el in div {
            try! el.tagName("p")
        }
        
        //color highlight parse
        let highlight = try! doc.select("span[style]")
        for el in highlight {
            var color = try! el.attr("style")
            color = color.replacingOccurrences(of: "color: ", with: "")
            color = color.replacingOccurrences(of: ";", with: "")
            let colorUI = UIColor(rgbString: color)
            if colorUI != nil {
                var colorHex = rgbToHex(color: colorUI!)
                colorHex = colorHex.replacingOccurrences(of: "#", with: "")
                try! el.removeAttr("style")
                try! el.attr("data-nodetype", "color")
                try! el.attr("data-value", colorHex)
            }
        }
        
        //color parse
        let color = try! doc.select("font[color]")
        for el in color {
            var hex = try! el.attr("color")
            hex = hex.replacingOccurrences(of: "#", with: "")
            try! el.removeAttr("color")
            try! el.attr("data-nodetype", "color")
            try! el.attr("data-value", hex)
            try! el.tagName("span")
        }
        
        //b parse
        let b = try! doc.select("b")
        for el in b {
            try! el.attr("data-nodetype", "b")
            try! el.tagName("span")
        }
        
        //i parse
        let it = try! doc.select("i")
        for el in it {
            try! el.attr("data-nodetype", "i")
            try! el.tagName("span")
        }
        
        //u parse
        let u = try! doc.select("u")
        for el in u {
            try! el.attr("data-nodetype", "u")
            try! el.tagName("span")
        }
        
        //s parse
        let s = try! doc.select("strike")
        for el in s {
            try! el.attr("data-nodetype", "s")
            try! el.tagName("span")
        }
        
        //left parse
        let left = try! doc.select("[style=text-align: left;]")
        for el in left {
            try! el.removeAttr("style")
            if el.tagName() != "p" {
                try! el.wrap("<p></p>")
            }
        }
        
        //center parse
        let center = try! doc.select("[style=text-align: center;]")
        for el in center {
            try! el.removeAttr("style")
            if el.tagName() == "p" {
                try! el.attr("data-nodetype", "center")
            } else {
                try! el.wrap("<p data-nodetype=\"center\"></p>")
            }
        }
        
        //right parse
        let right = try! doc.select("[style=text-align: right;]")
        for el in right {
            try! el.removeAttr("style")
            if el.tagName() == "p" {
                try! el.attr("data-nodetype", "right")
            } else {
               try! el.wrap("<p data-nodetype=\"right\"></p>")
            }
        }
        
        //h1 parse
        let h1 = try! doc.select("h1")
        for el in h1 {
            try! el.attr("data-nodetype", "h1")
            try! el.tagName("span")
        }
        
        //h2 parse
        let h2 = try! doc.select("h2")
        for el in h2 {
            try! el.attr("data-nodetype", "h2")
            try! el.tagName("span")
        }
        
        //h3 parse
        let h3 = try! doc.select("h3")
        for el in h3 {
            try! el.attr("data-nodetype", "h3")
            try! el.tagName("span")
        }
        
        //icon parse
        let icon = try! doc.select("img.icon")
        for el in icon {
            try! el.removeAttr("class")
            try! el.removeAttr("src")
            try! el.tagName("span")
        }
        
        //image parse
        let img = try! doc.select("img")
        for el in img {
            let src = try! el.attr("src")
            try! el.removeAttr("src")
            try! el.removeAttr("alt")
            try! el.attr("data-nodetype", "img")
            try! el.attr("data-src", src)
            let url = URL(string: src)!
            if let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) {
                if let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary? {
                    let pixelWidth = imageProperties[kCGImagePropertyPixelWidth] as! Int
                    let pixelHeight = imageProperties[kCGImagePropertyPixelHeight] as! Int
                    try! el.attr("data-sx", String(pixelWidth))
                    try! el.attr("data-sy", String(pixelHeight))
                }
            }
            try! el.tagName("span")
        }
        
        //url parse
        let url = try! doc.select("a")
        for el in url {
            let href = try! el.attr("href")
            try! el.wrap("<span data-nodetype=\"a\" data-href=\"\(href)\"></span>")
            try! el.remove()
        }
        
        var parsedHtml = "<div id=\"pmc\"><p>\(try! doc.body()!.html())</div>"
        //parsedHtml = parsedHtml.replacingOccurrences(of: "<br>", with: "")
        parsedHtml = parsedHtml.replacingOccurrences(of: "<hr>", with: "</p>")
        
        //remove empty p tag
        //let parsedDoc = try! SwiftSoup.parse(parsedHtml)
        //let p = try! parsedDoc.select("p")
        //try! p.last()?.remove()
        
        //remove style for all el
        //let el = try! doc.getAllElements()
        //try! el.removeAttr("style")
        
        //parsedHtml = try! parsedDoc.body()!.html()
        
        return parsedHtml
    }
    
    func keyWasTapped(character: String) {
        contentTextView.insertComponent(character)
    }
    
    @objc func callIconKeyboard() {
        if iconKeyboardShowing == false {
            view.endEditing(true)
            //contentTextView.resignFirstResponder()
            view.addSubview(iconKeyboard)
            iconKeyboard.snp.makeConstraints {
                (make) -> Void in
                make.top.equalTo(stackView.snp.bottom).offset(20)
                make.bottom.equalTo(view.snp.bottom).offset(-20)
                make.leading.equalTo(view.snp.leadingMargin).offset(0)
                make.trailing.equalTo(view.snp.trailingMargin).offset(0)
            }
            iconKeyboardShowing = true
        } else {
            iconKeyboard.removeFromSuperview()
            iconKeyboardShowing = false
            contentTextView.becomeFirstResponder()
        }
    }
    
    @objc func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: {
            self.contentTextView.html = ""
        })
    }
    
    func configureKeyboard() {
        keyboard
            .on(event: .willShow) { (options) in
                self.stackView.snp.updateConstraints {
                    (make) -> Void in
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        make.bottom.equalTo(self.view.snp.bottom).offset(-options.endFrame.height + (UIScreen.main.bounds.height*0.18)-15)
                    } else {
                        make.bottom.equalTo(self.view.snp.bottom).offset(-options.endFrame.height-15)
                    }
                }
            }
            .on(event: .willChangeFrame) { (options) in
                self.stackView.snp.updateConstraints {
                    (make) -> Void in
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        make.bottom.equalTo(self.view.snp.bottom).offset(-options.endFrame.height + (UIScreen.main.bounds.height*0.18)-15)
                    } else {
                        make.bottom.equalTo(self.view.snp.bottom).offset(-options.endFrame.height-15)
                    }
                }
            }
            /*.on(event: .willHide) { (options) in
                self.stackView.snp.updateConstraints {
                    (make) -> Void in
                    make.bottom.equalTo(self.view.snp.bottom).offset(-15)
                }
            }*/
            .start()
    }
    
    func rgbToHex(color: UIColor) -> String {
        
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb)
    }
    
    //image upload function
    func imageUpload(imageURL: URL,completion: @escaping (_ url: String)->Void) {
        HUD.show(.progress)
        Alamofire.upload(multipartFormData: {
            multipartFormData in
            multipartFormData.append(imageURL, withName: "image")
        }, to: "https://api.na.cx/upload", encodingCompletion: {
            encodingResult in
            switch encodingResult {
            case .success(let upload,_,_):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let url = json["url"].stringValue
                        HUD.flash(.success)
                        completion(url)
                    case .failure(let error):
                        print(error)
                        HUD.flash(.error)
                        completion("")
                    }
                }
            case .failure(let error):
                HUD.flash(.error)
                print(error)
            }
        })
    }
    
    //MARK: ImagePickerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: {
            self.contentTextView.becomeFirstResponder()
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if #available(iOS 11.0, *) {
            let imageURL = info[UIImagePickerController.InfoKey.imageURL] as! URL
            imageUpload(imageURL: imageURL, completion: {
                url in
                self.dismiss(animated: true, completion: {
                    self.contentTextView.insertImage(url, alt: "")
                    self.contentTextView.becomeFirstResponder()
                })
            })
        } else {
            //obtaining saving path
            let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            let imagePath = documentsPath?.appendingPathComponent("image.jpg")
            
            // extract image from the picker and save it
            var pickedImage: UIImage?
            if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                pickedImage = editedImage
            } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                pickedImage = originalImage
            }
            try! pickedImage!.jpegData(compressionQuality: 1.0)?.write(to: imagePath!)
            imageUpload(imageURL: imagePath!, completion: {
                url in
                self.dismiss(animated: true, completion: {
                    self.contentTextView.insertImage(url, alt: "")
                    //self.contentTextView.resignFirstResponder()
                    self.contentTextView.becomeFirstResponder()
                })
            })
        }
    }
}
