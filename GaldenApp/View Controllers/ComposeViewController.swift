//
//  ComposeViewController.swift
//  GaldenApp
//
//  Created by 1080 on 28/9/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import KeychainSwift
import PKHUD
import IQKeyboardManagerSwift

protocol ComposeViewControllerDelegate: class {
    func unwindToThreadListAfterNewPost()
    func unwindAfterReply()
}

class ComposeViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate,IconKeyboardDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    //MARK: Properties
    var channel = 0
    var content = ""
    var topicID = ""
    var type = ""
    var kheight: CGFloat = 0
    var contentVC: ContentViewController?
    var threadVC: ThreadListViewController?
    
    let iconKeyboard = IconKeyboard(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 265))
    
    let backgroundView = UIView()
    let secondaryBackgroundView = UIView()
    let channelLabel = UILabel()
    let titleTextField = UITextField()
    let contentTextView = IQTextView()
    let previewButton = UIButton()
    let sendButton = UIButton()
    
    let fontSizeButton = UIButton()
    let fontColorButton = UIButton()
    let fontStyleButton = UIButton()
    let imageButton = UIButton()
    let urlButton = UIButton()
    let iconButton = UIButton()
    
    lazy var tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerHandler(_:)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addGestureRecognizer(tapToDismiss)
        
        // Do any additional setup after loading the view.
        iconKeyboard.keyboardDelegate = self
        if type == "reply" {
            backgroundView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        } else {
            backgroundView.backgroundColor = UIColor(hexRGB: HKGaldenAPI.shared.chList![channel]["color"].stringValue)
        }
        backgroundView.layer.cornerRadius = 10
        backgroundView.hero.modifiers = [.position(CGPoint(x: view.frame.midX, y: 1000))]
        view.addSubview(backgroundView)
        
        secondaryBackgroundView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        secondaryBackgroundView.layer.cornerRadius = 10
        secondaryBackgroundView.hero.modifiers = [.position(CGPoint(x: view.frame.midX, y: 0))]
        view.addSubview(secondaryBackgroundView)
        
        channelLabel.text = HKGaldenAPI.shared.chList![channel]["name"].stringValue
        channelLabel.textColor = .white
        backgroundView.addSubview(channelLabel)
        
        titleTextField.delegate = self
        titleTextField.borderStyle = .roundedRect
        titleTextField.placeholder = "標題"
        contentTextView.delegate = self
        contentTextView.layer.cornerRadius = 5
        contentTextView.placeholder = "內容"
        if #available(iOS 11.0, *) {
            titleTextField.smartInsertDeleteType = .no
            titleTextField.smartQuotesType = .no
            titleTextField.smartDashesType = .no
            contentTextView.smartDashesType = .no
            contentTextView.smartQuotesType = .no
            contentTextView.smartInsertDeleteType = .no
        } else {
            // Fallback on earlier versions
        }
        backgroundView.addSubview(titleTextField)
        backgroundView.addSubview(contentTextView)
        
        if type == "reply" {
            titleTextField.removeFromSuperview()
            channelLabel.text = "回覆"
            contentTextView.text = content
        }
        
        previewButton.setTitle("預覽", for: .normal)
        previewButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        previewButton.cornerRadius = 5
        previewButton.borderWidth = 1
        previewButton.borderColor = .white
        previewButton.addTarget(self, action: #selector(previewButtonPressed(_:)), for: .touchUpInside)
        
        sendButton.setTitle("發表", for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        sendButton.cornerRadius = 5
        sendButton.borderWidth = 1
        sendButton.borderColor = .white
        sendButton.addTarget(self, action: #selector(sendButtonPressed(_:)), for: .touchUpInside)
        
        let stackViewNew = UIStackView()
        stackViewNew.axis = .horizontal
        stackViewNew.distribution = .fillEqually
        stackViewNew.alignment = .center
        stackViewNew.spacing = 10
        stackViewNew.addArrangedSubview(previewButton)
        stackViewNew.addArrangedSubview(sendButton)
        backgroundView.addSubview(stackViewNew)
        
        fontSizeButton.setImage(UIImage(named: "FontSize"), for: .normal)
        fontSizeButton.tintColor = .white
        fontSizeButton.imageView?.contentMode = .scaleAspectFit
        fontSizeButton.addTarget(self, action: #selector(fontSizeButtonPressed(_:)), for: .touchUpInside)
        
        fontColorButton.setImage(UIImage(named: "FontColor"), for: .normal)
        fontColorButton.tintColor = .white
        fontColorButton.imageView?.contentMode = .scaleAspectFit
        fontColorButton.addTarget(self, action: #selector(fontColorButtonPressed(_:)), for: .touchUpInside)
        
        fontStyleButton.setImage(UIImage(named: "FontStyle"), for: .normal)
        fontStyleButton.tintColor = .white
        fontStyleButton.imageView?.contentMode = .scaleAspectFit
        fontStyleButton.addTarget(self, action: #selector(fontStyleButtonPressed(_:)), for: .touchUpInside)
        
        imageButton.setImage(UIImage(named: "Image"), for: .normal)
        imageButton.tintColor = .white
        imageButton.imageView?.contentMode = .scaleAspectFit
        imageButton.addTarget(self, action: #selector(imageButtonPressed(_:)), for: .touchUpInside)
        
        urlButton.setImage(UIImage(named: "Url"), for: .normal)
        urlButton.tintColor = .white
        urlButton.imageView?.contentMode = .scaleAspectFit
        urlButton.addTarget(self, action: #selector(urlButtonPressed(_:)), for: .touchUpInside)
        
        iconButton.setImage(UIImage(named: "Icon"), for: .normal)
        iconButton.tintColor = .white
        iconButton.imageView?.contentMode = .scaleAspectFit
        iconButton.addTarget(self, action: #selector(callIconKeyboard(_:)), for: .touchUpInside)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 15
        stackView.addArrangedSubview(fontSizeButton)
        stackView.addArrangedSubview(fontColorButton)
        stackView.addArrangedSubview(fontStyleButton)
        stackView.addArrangedSubview(imageButton)
        stackView.addArrangedSubview(urlButton)
        stackView.addArrangedSubview(iconButton)
        secondaryBackgroundView.addSubview(stackView)
        
        backgroundView.snp.makeConstraints {
            (make) -> Void in
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.bottom.equalTo(-15)
            make.height.equalTo(250)
        }
        
        secondaryBackgroundView.snp.makeConstraints {
            (make) -> Void in
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.bottom.equalTo(backgroundView.snp.top).offset(-20)
            make.height.equalTo(65)
        }
        
        channelLabel.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(10)
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
        }
        
        if type != "reply" {
            titleTextField.snp.makeConstraints {
                (make) -> Void in
                make.top.equalTo(channelLabel.snp.bottom).offset(10)
                make.leading.equalTo(15)
                make.trailing.equalTo(-15)
            }
        }
        
        contentTextView.snp.makeConstraints {
            (make) -> Void in
            if type == "reply" {
                make.top.equalTo(channelLabel.snp.bottom).offset(10)
            } else {
                make.top.equalTo(titleTextField.snp.bottom).offset(10)
            }
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
        }
        
        stackView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(10)
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.bottom.equalTo(-15)
        }
        
        stackViewNew.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(contentTextView.snp.bottom).offset(10)
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.bottom.equalTo(-10)
        }
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

    @objc func fontSizeButtonPressed(_ sender: UIButton) {
        let actionsheet = UIAlertController(title:"揀大細", message: nil, preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title:"超大",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[size=6]text[/size=6]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"特大",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[size=5]text[/size=5]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"大",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[size=4]text[/size=4]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"一般",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[size=3]text[/size=3]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"小",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[size=2]text[/size=2]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"特小",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[size=1]text[/size=1]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"冇嘢啦",style:.cancel,handler:nil))
        self.present(actionsheet,animated: true,completion: nil)
    }
    
    @objc func fontStyleButtonPressed(_ sender: UIButton) {
        let actionsheet = UIAlertController(title:"字體格式", message: nil, preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title:"粗體",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[b]text[/b]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"斜體",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[i]text[/i]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"底線",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[u]text[/u]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"刪除線",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[s]text[/s]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"置左",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[left]text[/left]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"置中",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[center]text[/center]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"置右",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[right]text[/right]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"冇嘢啦",style:.cancel,handler:nil))
        self.present(actionsheet,animated: true,completion: nil)
    }
    
    @objc func fontColorButtonPressed(_ sender: UIButton) {
        let actionsheet = UIAlertController(title:"揀顏色", message: nil, preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title:"紅色",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[red]text[/red]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"橙色",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[orange]text[/orange]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"綠色",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[green]text[/green]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"藍色",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[blue]text[/blue]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"紫色",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[purple]text[/purple]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"冇嘢啦",style:.cancel,handler:nil))
        present(actionsheet,animated: true,completion: nil)
    }
    
    @objc func imageButtonPressed(_ sender: UIButton) {
        let actionsheet = UIAlertController(title:"噏圖(powered by eService-HK)",message:"你想...",preferredStyle:.actionSheet)
        actionsheet.addAction(UIAlertAction(title:"揀相",style:.default,handler: {
            _ in
            let imagePicker = UIImagePickerController()
            imagePicker.navigationBar.tintColor = .lightGray
            imagePicker.navigationBar.barStyle = .black
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker,animated: true,completion: nil)
        }))
        actionsheet.addAction(UIAlertAction(title:"[img] tag",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[img]text[/img]\n")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"冇嘢啦",style:.cancel,handler:nil))
        present(actionsheet,animated: true,completion: nil)
    }
    
    @objc func urlButtonPressed(_ sender: UIButton) {
        self.contentTextView.insertText("[url]text[/url]")
        let range = self.contentTextView.text.range(of: "text")
        let nsRange = self.contentTextView.text.nsRange(from: range!)
        self.contentTextView.selectedRange = nsRange
        self.contentTextView.select(nsRange)
    }
    
    @objc func previewButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let previewVC = PreviewViewController()
        previewVC.modalPresentationStyle = .overCurrentContext
        previewVC.type = type
        previewVC.contentText = contentTextView.text
        if type != "reply" {
            previewVC.titleText = titleTextField.text
        }
        present(previewVC, animated: true, completion: nil)
    }
    
    @objc func sendButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if (type == "newThread" && titleTextField.text == "") {
            let alert = UIAlertController.init(title: "注意", message: "標題不可爲空", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
            self.present(alert,animated: true,completion: nil)
        }
        if (contentTextView.text == "") {
            let alert = UIAlertController.init(title: "注意", message: "內容不可爲空", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
            self.present(alert,animated: true,completion: nil)
        } else {
            contentTextView.endEditing(true)
            HUD.show(.progress)
            if type == "newThread" {
                HKGaldenAPI.shared.submitPost(channel: HKGaldenAPI.shared.chList![channel]["ident"].stringValue, title: titleTextField.text!, content: contentTextView.text!, completion: {
                    [weak self] error in
                    if error == nil {
                        HUD.flash(.success,delay:1)
                        self?.dismiss(animated: true, completion: nil)
                        DispatchQueue.main.async {
                            self?.threadVC?.unwindToThreadListAfterNewPost()
                        }
                    } else {
                        HUD.flash(.error,delay: 1)
                    }
                })
            } else if type == "reply" {
                HKGaldenAPI.shared.reply(topicID: topicID, content: contentTextView.text!, completion: {
                    [weak self] error in
                    if error == nil {
                        HUD.flash(.success,delay:1)
                        self?.dismiss(animated: true, completion: {xbbcodeBridge.shared.sender = "content"})
                        DispatchQueue.main.async {
                            self?.contentVC?.unwindAfterReply()
                        }
                    } else {
                        HUD.flash(.error,delay: 1)
                    }
                })
            }
        }
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
                self.contentTextView.insertText("[img]" + url + "[/img]\n")
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
                self.contentTextView.insertText("[img]" + url + "[/img]\n")
            })
        }
    }
    
    func keyWasTapped(character: String) {
        contentTextView.insertText("\(character) ")
    }
    
    @objc func callIconKeyboard(_ sender: UIButton) {
        if contentTextView.inputView == nil {
            contentTextView.resignFirstResponder()
            contentTextView.inputView = iconKeyboard
            contentTextView.becomeFirstResponder()
        } else {
            contentTextView.resignFirstResponder()
            contentTextView.inputView = nil
            contentTextView.becomeFirstResponder()
        }
    }
    
    @objc func tapGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
