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
    let api = HKGaldenAPI()
    
    let iconKeyboard = IconKeyboard(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 265))
    
    @IBOutlet weak var channelLabel: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: IQTextView!
    @IBOutlet weak var bottomConstrain: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationCapturesStatusBarAppearance = true
        // Do any additional setup after loading the view.
        iconKeyboard.delegate = self
        titleTextField.delegate = self
        contentTextView.delegate = self
        contentTextView.placeholder = "內容"
        channelLabel.setTitle(api.channelNameFunc(ch: channel), for: .normal)
        channelLabel.backgroundColor = api.channelColorFunc(ch: channel)
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
        if type == "newThread" {
            let destination = segue.destination as! PreviewViewController
            destination.channel = self.channel
            destination.threadTitle = self.titleTextField.text
            destination.content = content
            destination.type = "newThread"
        } else if type == "reply" {
            let destination = segue.destination as! PreviewViewController
            destination.content = content
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
            self.contentTextView.insertText("[#ff0000]text[/#ff0000]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"橙色",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[#ffa500]text[/#ffa500]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"黃色",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[#ffff00]text[/#ffff00]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"綠色",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[#008000]text[/#008000]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"藍色",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[#0000ff]text[/#0000ff]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"靛色",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[#4b0082]text[/#4b0082]")
            let range = self.contentTextView.text.range(of: "text")
            let nsRange = self.contentTextView.text.nsRange(from: range!)
            self.contentTextView.selectedRange = nsRange
            self.contentTextView.select(nsRange)
        }))
        actionsheet.addAction(UIAlertAction(title:"紫色",style:.default,handler: {
            _ in
            self.contentTextView.insertText("[#800080]text[/#800080]")
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
        let imageURL = info[UIImagePickerControllerImageURL] as! URL
        api.imageUpload(imageURL: imageURL, completion: {
            url in
            HUD.flash(.success, delay: 1.0)
            self.dismiss(animated: true, completion: nil)
            self.contentTextView.insertText("[img]" + url + "[/img]\n")
        })
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        bottomConstrain.constant += 300
        self.view.layoutIfNeeded()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        bottomConstrain.constant -= 300
        self.view.layoutIfNeeded()
        content = textView.text
    }
    
}
