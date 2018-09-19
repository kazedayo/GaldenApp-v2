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

class ComposeViewController: UIViewController, UITextFieldDelegate,IconKeyboardDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    //MARK: Properties
    var channel: String!
    var content: String!
    var topicID: String!
    var composeType: ComposeType!
    var contentVC: ContentViewController?
    var threadVC: ThreadListViewController?
    
    let iconKeyboard = IconKeyboard(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 265))
    
    let titleTextField = UITextField()
    let contentTextView = RichEditorView()
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = [RichEditorDefaultOption.clear,RichEditorDefaultOption.undo,RichEditorDefaultOption.redo,RichEditorDefaultOption.bold,RichEditorDefaultOption.italic,RichEditorDefaultOption.underline,RichEditorDefaultOption.strike,RichEditorDefaultOption.alignCenter,RichEditorDefaultOption.alignRight,RichEditorDefaultOption.header(1),RichEditorDefaultOption.header(2),RichEditorDefaultOption.header(3),RichEditorDefaultOption.link,RichEditorDefaultOption.image]
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
        
        toolbar.editor = contentTextView
        
        titleTextField.delegate = self
        titleTextField.borderStyle = .none
        titleTextField.backgroundColor = .white
        titleTextField.placeholder = "標題"
        titleTextField.borderStyle = .line
        //contentTextView.delegate = self
        contentTextView.clipsToBounds = true
        contentTextView.placeholder = "內容"
        contentTextView.perform(
            #selector(becomeFirstResponder),
            with: nil,
            afterDelay: 0.1
        )
        contentTextView.inputAccessoryView = toolbar
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
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.bottomMargin).offset(-10)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
        /*if (composeType == .newThread && titleTextField.text == "") {
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
            previewVC.composeType = composeType
            previewVC.contentText = contentTextView.text
            previewVC.composeVC = self
            if composeType != .reply {
                previewVC.titleText = titleTextField.text
                previewVC.channel = self.channel
            } else {
                previewVC.topicID = self.topicID
            }
            self.navigationController?.pushViewController(previewVC, animated: true)
        }*/
        print(contentTextView.contentHTML)
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
