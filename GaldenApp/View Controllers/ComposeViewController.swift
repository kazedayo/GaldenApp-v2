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

class ComposeViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate,IconKeyboardDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    //MARK: Properties
    var channel: String = ""
    var content = ""
    var topicID = ""
    var type = ""
    var kheight: CGFloat = 0
    
    let iconKeyboard = IconKeyboard(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 265))
    
    @IBOutlet weak var channelLabel: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: IQTextView!
    @IBOutlet weak var bottomConstrain: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        if type == "reply" {
            contentTextView.becomeFirstResponder()
        } else {
            titleTextField.becomeFirstResponder()
        }
    }
    
    //MARK: - getKayboardHeight
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        // do whatever you want with this keyboard height
        self.kheight = keyboardHeight
        bottomConstrain.constant = (kheight + 20)
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        // keyboard is dismissed/hidden from the screen
        bottomConstrain.constant -= kheight
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resignFirstResponder()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationCapturesStatusBarAppearance = true
        // Do any additional setup after loading the view.
        iconKeyboard.delegate = self
        titleTextField.delegate = self
        contentTextView.delegate = self
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
        channelLabel.setTitle(HKGaldenAPI.shared.channelNameFunc(ch: channel), for: .normal)
        channelLabel.backgroundColor = HKGaldenAPI.shared.channelColorFunc(ch: channel)
        if type == "reply" {
            titleTextField.isHidden = true
            channelLabel.isHidden = true
            contentTextView.text = content
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
        contentTextView.endEditing(true)
        if type == "newThread" {
            let destination = segue.destination as! PreviewViewController
            destination.channel = self.channel
            destination.threadTitle = self.titleTextField.text
            destination.content = contentTextView.text
            destination.type = "newThread"
        } else if type == "reply" {
            let destination = segue.destination as! PreviewViewController
            destination.content = contentTextView.text
            destination.topicID = topicID
            destination.type = "reply"
        }
    }
    
    //MARK: Actions

    @IBAction func fontSizeButtonPressed(_ sender: UIButton) {
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
    
    @IBAction func fontStyleButtonPressed(_ sender: UIButton) {
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
    
    @IBAction func fontColorButtonPressed(_ sender: UIButton) {
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
    
    @IBAction func imageButtonPressed(_ sender: UIButton) {
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
    
    @IBAction func urlButtonPressed(_ sender: UIButton) {
        self.contentTextView.insertText("[url]text[/url]")
        let range = self.contentTextView.text.range(of: "text")
        let nsRange = self.contentTextView.text.nsRange(from: range!)
        self.contentTextView.selectedRange = nsRange
        self.contentTextView.select(nsRange)
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
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
            performSegue(withIdentifier: "preview", sender: self)
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
        contentTextView.insertText(character)
    }
    
    @IBAction func callIconKeyboard(_ sender: UIButton) {
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
}
