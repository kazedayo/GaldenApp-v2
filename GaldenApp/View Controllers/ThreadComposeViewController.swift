//
//  ThreadComposeViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 12/10/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import UIKit
import PKHUD
import SwiftEntryKit

class ThreadComposeViewController: ComposeViewController {
    
    var tagID: String?
    var threadVC: ThreadListViewController?
    
    let titleTextField = UITextField()
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

    override func viewDidLoad() {
        super.viewDidLoad()
        contentTextView.snp.removeConstraints()
        
        titleTextField.delegate = self
        titleTextField.borderStyle = .none
        titleTextField.borderColor = .clear
        titleTextField.backgroundColor = .clear
        titleTextField.attributedPlaceholder = NSAttributedString(string: "標題", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        titleTextField.textColor = UIColor(hexRGB: "aaaaaa")
        if #available(iOS 11.0, *) {
            titleTextField.smartInsertDeleteType = .no
            titleTextField.smartQuotesType = .no
            titleTextField.smartDashesType = .no
        } else {
            // Fallback on earlier versions
        }
        
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
            make.bottom.equalTo(view.snp.bottomMargin).offset(-20)
        }
        tagButton.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(contentTextView.snp.bottom).offset(10)
            make.leading.equalTo(selectTagLabel.snp.trailing).offset(10)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-20)
        }
        contentTextView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(titleTextField.snp.bottom).offset(10)
            make.leading.equalTo(view.snp.leadingMargin).offset(0)
            make.trailing.equalTo(view.snp.trailingMargin).offset(0)
        }
        // Do any additional setup after loading the view.
    }
    
    override func submitButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if (contentTextView.contentHTML == "" || contentTextView.contentHTML == "<br>") {
            let alert = UIAlertController.init(title: "注意", message: "內容不可爲空", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: {
                action in
                self.contentTextView.becomeFirstResponder()
            }))
            self.present(alert,animated: true,completion: nil)
        } else if (titleTextField.text == "") {
            let alert = UIAlertController.init(title: "注意", message: "標題不可爲空", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: {
                action in
                self.contentTextView.becomeFirstResponder()
            }))
            self.present(alert,animated: true,completion: nil)
        } else {
            let parsedHtml = galdenParse(input: contentTextView.contentHTML)
            HUD.show(.progress)
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
                        self?.dismiss(animated: true, completion: {
                            self?.threadVC?.unwindToThreadListAfterNewPost()
                        })
                    } else {
                        HUD.flash(.error)
                        print(error!)
                    }
                }
            }
        }
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
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
    
    override func keyboardWillHide(notification: Notification) {
        selectTagLabel.snp.updateConstraints {
            (make) -> Void in
            make.bottom.equalTo(view.snp.bottomMargin)
        }
        tagButton.snp.updateConstraints {
            (make) -> Void in
            make.bottom.equalTo(view.snp.bottomMargin)
        }
    }
    
    func unwindToCompose(tagName: String,tagID: String,tagColor: String) {
        self.tagID = tagID
        tagButton.setTitle(tagName, for: .normal)
        tagButton.setTitleColor(UIColor(hexRGB: tagColor), for: .normal)
    }
    
    @objc func tagButtonPressed(_ sender: UIButton) {
        let tagsVC = TagsTableViewController()
        let attributes = EntryAttributes.shared.iconEntry()
        tagsVC.composeVC = self
        SwiftEntryKit.display(entry: tagsVC, using: attributes)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
