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
    let channelLabel = UILabel()
    let titleTextField = UITextField()
    let contentTextView = IQTextView()
    let previewButton = UIButton()
    
    let fontSizeButton = UIButton()
    let fontColorButton = UIButton()
    let fontStyleButton = UIButton()
    let imageButton = UIButton()
    let urlButton = UIButton()
    let iconButton = UIButton()
    
    lazy var swipeToDismiss = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler(_:)))
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    var backgroundViewOriginalPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundViewOriginalPoint = CGPoint(x: backgroundView.frame.minX, y: backgroundView.frame.minY)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addGestureRecognizer(swipeToDismiss)
        
        // Do any additional setup after loading the view.
        iconKeyboard.keyboardDelegate = self
        backgroundView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        backgroundView.layer.cornerRadius = 10
        backgroundView.hero.modifiers = [.position(CGPoint(x: view.frame.midX, y: 1000))]
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOpacity = 1
        backgroundView.layer.shadowOffset = CGSize.zero
        backgroundView.layer.shadowRadius = 10
        view.addSubview(backgroundView)
        
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
        previewButton.backgroundColor = UIColor(hexRGB: "0076ff")
        previewButton.addTarget(self, action: #selector(previewButtonPressed(_:)), for: .touchUpInside)
        backgroundView.addSubview(previewButton)
        
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
        backgroundView.addSubview(stackView)
        
        backgroundView.snp.makeConstraints {
            (make) -> Void in
            make.bottom.equalTo(view.snp.bottomMargin).offset(-15)
            make.height.equalTo(300)
            make.width.lessThanOrEqualTo(500)
            make.leadingMargin.greaterThanOrEqualTo(15)
            make.trailingMargin.greaterThanOrEqualTo(-15)
            make.centerX.equalToSuperview()
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
            make.top.equalTo(stackView.snp.bottom).offset(10)
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
        }
        
        stackView.snp.makeConstraints {
            (make) -> Void in
            if type == "reply" {
                make.top.equalTo(channelLabel.snp.bottom).offset(10)
            } else {
                make.top.equalTo(titleTextField.snp.bottom).offset(10)
            }
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
        }
        
        previewButton.snp.makeConstraints {
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
        actionsheet.popoverPresentationController?.sourceView = fontSizeButton
        actionsheet.popoverPresentationController?.sourceRect = fontSizeButton.bounds
        actionsheet.addAction(UIAlertAction(title:"超大",style:.default,handler: {
            _ in
            self.insertTag(tag: "size=6")
        }))
        actionsheet.addAction(UIAlertAction(title:"特大",style:.default,handler: {
            _ in
            self.insertTag(tag: "size=5")
        }))
        actionsheet.addAction(UIAlertAction(title:"大",style:.default,handler: {
            _ in
            self.insertTag(tag: "size=4")
        }))
        actionsheet.addAction(UIAlertAction(title:"一般",style:.default,handler: {
            _ in
            self.insertTag(tag: "size=3")
        }))
        actionsheet.addAction(UIAlertAction(title:"小",style:.default,handler: {
            _ in
            self.insertTag(tag: "size=2")
        }))
        actionsheet.addAction(UIAlertAction(title:"特小",style:.default,handler: {
            _ in
            self.insertTag(tag: "size=1")
        }))
        actionsheet.addAction(UIAlertAction(title:"冇嘢啦",style:.cancel,handler:nil))
        self.present(actionsheet,animated: true,completion: nil)
    }
    
    @objc func fontStyleButtonPressed(_ sender: UIButton) {
        let actionsheet = UIAlertController(title:"字體格式", message: nil, preferredStyle: .actionSheet)
        actionsheet.popoverPresentationController?.sourceView = fontStyleButton
        actionsheet.popoverPresentationController?.sourceRect = fontStyleButton.bounds
        actionsheet.addAction(UIAlertAction(title:"粗體",style:.default,handler: {
            _ in
            self.insertTag(tag: "b")
        }))
        actionsheet.addAction(UIAlertAction(title:"斜體",style:.default,handler: {
            _ in
            self.insertTag(tag: "i")
        }))
        actionsheet.addAction(UIAlertAction(title:"底線",style:.default,handler: {
            _ in
            self.insertTag(tag: "u")
        }))
        actionsheet.addAction(UIAlertAction(title:"刪除線",style:.default,handler: {
            _ in
            self.insertTag(tag: "s")
        }))
        actionsheet.addAction(UIAlertAction(title:"置左",style:.default,handler: {
            _ in
            self.insertTag(tag: "left")
        }))
        actionsheet.addAction(UIAlertAction(title:"置中",style:.default,handler: {
            _ in
            self.insertTag(tag: "center")
        }))
        actionsheet.addAction(UIAlertAction(title:"置右",style:.default,handler: {
            _ in
            self.insertTag(tag: "right")
        }))
        actionsheet.addAction(UIAlertAction(title:"冇嘢啦",style:.cancel,handler:nil))
        self.present(actionsheet,animated: true,completion: nil)
    }
    
    @objc func fontColorButtonPressed(_ sender: UIButton) {
        let actionsheet = UIAlertController(title:"揀顏色", message: nil, preferredStyle: .actionSheet)
        actionsheet.popoverPresentationController?.sourceView = fontColorButton
        actionsheet.popoverPresentationController?.sourceRect = fontColorButton.bounds
        actionsheet.addAction(UIAlertAction(title:"紅色",style:.default,handler: {
            _ in
            self.insertTag(tag: "red")
        }))
        actionsheet.addAction(UIAlertAction(title:"橙色",style:.default,handler: {
            _ in
            self.insertTag(tag: "orange")
        }))
        actionsheet.addAction(UIAlertAction(title:"綠色",style:.default,handler: {
            _ in
            self.insertTag(tag: "green")
        }))
        actionsheet.addAction(UIAlertAction(title:"藍色",style:.default,handler: {
            _ in
            self.insertTag(tag: "blue")
        }))
        actionsheet.addAction(UIAlertAction(title:"紫色",style:.default,handler: {
            _ in
            self.insertTag(tag: "purple")
        }))
        actionsheet.addAction(UIAlertAction(title:"冇嘢啦",style:.cancel,handler:nil))
        present(actionsheet,animated: true,completion: nil)
    }
    
    @objc func imageButtonPressed(_ sender: UIButton) {
        let actionsheet = UIAlertController(title:"噏圖(powered by eService-HK)",message:"你想...",preferredStyle:.actionSheet)
        actionsheet.popoverPresentationController?.sourceView = imageButton
        actionsheet.popoverPresentationController?.sourceRect = imageButton.bounds
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
            self.insertTag(tag: "img")
        }))
        actionsheet.addAction(UIAlertAction(title:"冇嘢啦",style:.cancel,handler:nil))
        present(actionsheet,animated: true,completion: nil)
    }
    
    @objc func urlButtonPressed(_ sender: UIButton) {
        let actionsheet = UIAlertController(title:"特別格式",message:nil,preferredStyle:.actionSheet)
        actionsheet.popoverPresentationController?.sourceView = urlButton
        actionsheet.popoverPresentationController?.sourceRect = urlButton.bounds
        actionsheet.addAction(UIAlertAction(title: "[url] tag", style: .default, handler: {
            _ in
            self.insertTag(tag: "url")
        }))
        actionsheet.addAction(UIAlertAction(title: "[quote] tag", style: .default, handler: {
            _ in
            self.insertTag(tag: "quote")
        }))
        actionsheet.addAction(UIAlertAction(title: "[hide] tag", style: .default, handler: {
            _ in
            self.insertTag(tag: "hide")
        }))
        actionsheet.addAction(UIAlertAction(title:"冇嘢啦",style:.cancel,handler:nil))
        present(actionsheet,animated: true,completion: nil)
    }
    
    @objc func previewButtonPressed(_ sender: UIButton) {
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
            let previewVC = PreviewViewController()
            previewVC.modalPresentationStyle = .overCurrentContext
            previewVC.type = type
            previewVC.contentText = contentTextView.text
            previewVC.composeVC = self
            if type != "reply" {
                previewVC.titleText = titleTextField.text
                previewVC.channel = self.channel
            } else {
                previewVC.topicID = self.topicID
            }
            present(previewVC, animated: true, completion: nil)
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
    
    private func insertTag(tag: String) {
        if self.contentTextView.text(in: self.contentTextView.selectedTextRange!) != "" {
            let text = self.contentTextView.text(in: self.contentTextView.selectedTextRange!)
            self.contentTextView.insertText("[\(tag)]\(text!)[/\(tag)]")
            let range = self.contentTextView.text.range(of: "\(text!)")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        } else {
            self.contentTextView.insertText("[\(tag)]text[/\(tag)]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }
    }
}
