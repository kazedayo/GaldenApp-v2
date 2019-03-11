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
import IGColorPicker
import Alamofire
import SwiftyJSON

class ComposeViewController: UIViewController, UITextFieldDelegate,IconKeyboardDelegate,UINavigationControllerDelegate,RichEditorDelegate,RichEditorToolbarDelegate,ColorPickerViewDelegate,ColorPickerViewDelegateFlowLayout,UIImagePickerControllerDelegate {
    
    //MARK: Properties
    var topicID: Int!
    var quoteID: String?
    var contentVC: ContentViewController?
    var keyboardHeight: CGFloat = 0
    
    let iconKeyboard = IconKeyboard()
    
    let contentTextView = RichEditorView()
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 55))
        toolbar.options = [RichEditorDefaultOption.clear,RichEditorDefaultOption.image,RichEditorDefaultOption.link,RichEditorDefaultOption.textColor,RichEditorDefaultOption.bold,RichEditorDefaultOption.italic,RichEditorDefaultOption.underline,RichEditorDefaultOption.strike,RichEditorDefaultOption.alignLeft,RichEditorDefaultOption.alignCenter,RichEditorDefaultOption.alignRight,RichEditorDefaultOption.header(1),RichEditorDefaultOption.header(2),RichEditorDefaultOption.header(3)]
        return toolbar
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
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
        contentTextView.webView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        self.automaticallyAdjustsScrollViewInsets = false
        contentTextView.webView.scrollView.clipsToBounds = true
        if #available(iOS 11.0, *) {
            contentTextView.webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        contentTextView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        toolbar.editor = contentTextView
        toolbar.delegate = self
        contentTextView.delegate = self
        
        view.addSubview(contentTextView)
        
        self.title = "回覆"
        
        contentTextView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(view.snp.topMargin).offset(10)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-10)
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
        let link = UIAlertAction(title: "插入鏈結", style: .default, handler: {
            _ in
            let textfield = alert.textFields?.first
            toolbar.editor?.insertComponent("<a href=\"\((textfield?.text)!)\">\((textfield?.text)!)</a>")
        })
        let image = UIAlertAction(title: "插入圖片", style: .default, handler: {
            _ in
            let textfield = alert.textFields?.first
            toolbar.editor?.insertImage((textfield?.text)!, alt: "")
        })
        let cancel = UIAlertAction(title: "不了", style: .cancel, handler: nil)
        alert.addAction(link)
        alert.addAction(image)
        alert.addAction(cancel)
        present(alert,animated: true,completion: nil)
    }
    
    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        let imagePicker = UIImagePickerController()
        imagePicker.navigationBar.tintColor = .lightGray
        imagePicker.navigationBar.barStyle = .black
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker,animated: true,completion: nil)
    }
    
    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        let colorPicker = ColorPickerView()
        colorPicker.delegate = self
        colorPicker.layoutDelegate = self
        colorPicker.colors = [UIColor(hexRGB: "ffffff"),UIColor(hexRGB: "f44f44"),UIColor(hexRGB: "ff8f00"),UIColor(hexRGB: "eecc28"),UIColor(hexRGB: "f6ef1b"),UIColor(hexRGB: "c1e823"),UIColor(hexRGB: "85e41d"),UIColor(hexRGB: "64b31c"),UIColor(hexRGB: "0ad849"),UIColor(hexRGB: "0ee6b4"),UIColor(hexRGB: "22b4e0"),UIColor(hexRGB: "208ce8"),UIColor(hexRGB: "4c5aff"),UIColor(hexRGB: "8858fd"),UIColor(hexRGB: "bb7ef2"),UIColor(hexRGB: "d800ff"),UIColor(hexRGB: "ff50b0"),UIColor(hexRGB: "ffc7c7"),UIColor(hexRGB: "808080"),UIColor(hexRGB: "000000")] as! [UIColor]
        var attributes = EntryAttributes.shared.iconEntry()
        attributes.positionConstraints.verticalOffset = keyboardHeight-50
        SwiftEntryKit.display(entry: colorPicker, using: attributes)
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        // A color has been selected
        self.contentTextView.setTextColor(colorPickerView.colors[indexPath.item])
        DispatchQueue.main.asyncAfter(deadline: 0.5, execute:  {
            SwiftEntryKit.dismiss()
        })
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        // Space between cells
        return 10
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        // Space between rows
        return 10
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
                self.contentTextView.becomeFirstResponder()
            }))
            self.present(alert,animated: true,completion: nil)
        } else {
            HUD.show(.progress)
            let parsedHtml = galdenParse(input: contentTextView.contentHTML)
            let replyThreadMutation = ReplyThreadMutation(threadId: topicID, parentId: quoteID, html: parsedHtml)
            apollo.perform(mutation: replyThreadMutation) {
                [weak self] result, error in
                if error == nil {
                    DispatchQueue.main.asyncAfter(deadline: 0.2, execute: {
                        HUD.flash(.success)
                        self?.dismiss(animated: true, completion: {
                            self?.contentVC?.unwindAfterReply()
                        })
                    })
                } else {
                    HUD.flash(.error)
                    print(error!)
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
        //contentTextView.resignFirstResponder()
        var attributes = EntryAttributes.shared.iconEntry()
        attributes.positionConstraints.verticalOffset = keyboardHeight-50
        SwiftEntryKit.display(entry: iconKeyboard, using: attributes)
    }
    
    @objc func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            contentTextView.snp.updateConstraints {
                (make) -> Void in
                if UIDevice.current.userInterfaceIdiom == .pad {
                    make.bottom.equalTo(view.snp.bottomMargin).offset(-keyboardHeight+(UIScreen.main.bounds.height*0.18))
                } else {
                    make.bottom.equalTo(view.snp.bottomMargin).offset(-keyboardHeight)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        // keyboard is dismissed/hidden from the screen
        if UIDevice.current.userInterfaceIdiom == .pad {
            contentTextView.snp.updateConstraints {
                (make) -> Void in
                make.bottom.equalTo(view.snp.bottomMargin).offset(-10)
            }
        }
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
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if #available(iOS 11.0, *) {
            let imageURL = info[UIImagePickerController.InfoKey.imageURL] as! URL
            imageUpload(imageURL: imageURL, completion: {
                url in
                self.dismiss(animated: true, completion: {
                    self.toolbar.editor?.insertImage(url, alt: "")
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
                    self.toolbar.editor?.insertImage(url, alt: "")
                })
            })
        }
    }
}
