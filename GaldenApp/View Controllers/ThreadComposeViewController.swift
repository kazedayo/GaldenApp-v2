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

class ThreadComposeViewController: ComposeViewController,UIPopoverPresentationControllerDelegate {
    
    var tagID: String?
    var threadVC: ThreadListViewController?
    
    let titleTextField = UITextField()
    lazy var tagButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setTitle("選擇標籤...", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: #selector(tagButtonPressed(_:)), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        contentTextView.snp.removeConstraints()
        titleTextField.delegate = self
        titleTextField.borderStyle = .none
        titleTextField.borderColor = .clear
        titleTextField.backgroundColor = .systemBackground
        titleTextField.attributedPlaceholder = NSAttributedString(string: "標題", attributes: [NSAttributedString.Key.foregroundColor : UIColor.secondaryLabel])
        titleTextField.textColor = .label
        if #available(iOS 11.0, *) {
            titleTextField.smartInsertDeleteType = .no
            titleTextField.smartQuotesType = .no
            titleTextField.smartDashesType = .no
        } else {
            // Fallback on earlier versions
        }
        
        self.title = "發表主題"
        view.addSubview(titleTextField)
        view.addSubview(tagButton)
        titleTextField.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(view.snp.topMargin).offset(15)
            make.leading.equalTo(view.snp.leadingMargin).offset(0)
            make.trailing.equalTo(view.snp.trailingMargin).offset(0)
        }
        tagButton.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(titleTextField.snp.bottom).offset(15)
            make.leading.equalTo(view.snp.leadingMargin).offset(0)
        }
        contentTextView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(tagButton.snp.bottom).offset(15)
            make.leading.equalTo(view.snp.leadingMargin).offset(0)
            make.trailing.equalTo(view.snp.trailingMargin).offset(0)
        }
        
        stackView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(contentTextView.snp.bottomMargin).offset(15)
            make.bottom.equalTo(view.snp.bottom).offset(-15)
            make.leading.equalTo(view.snp.leadingMargin)
        }
        // Do any additional setup after loading the view.
    }
    
    override func submitButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if (contentTextView.contentHTML == "" || contentTextView.contentHTML == "<br>") {
            let alert = UIAlertController.init(title: "注意", message: "內容不可爲空", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: {
                action in
                self.contentTextView.resignFirstResponder()
                self.contentTextView.becomeFirstResponder()
            }))
            self.present(alert,animated: true,completion: nil)
        } else if (titleTextField.text == "") {
            let alert = UIAlertController.init(title: "注意", message: "標題不可爲空", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: {
                action in
                self.contentTextView.resignFirstResponder()
                self.contentTextView.becomeFirstResponder()
            }))
            self.present(alert,animated: true,completion: nil)
        } else if tagID == nil {
            let alert = UIAlertController.init(title: "注意", message: "請選擇標籤", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: {
                action in
                self.contentTextView.resignFirstResponder()
                self.contentTextView.becomeFirstResponder()
            }))
            self.present(alert,animated: true,completion: nil)
        } else {
            HUD.show(.progress)
            let parsedHtml = galdenParse(input: contentTextView.contentHTML)
            let createThreadMutation = CreateThreadMutation(title: titleTextField.text!, tags: [tagID!], html: parsedHtml)
            apollo.perform(mutation: createThreadMutation) {
                [weak self] result in
                switch result {
                case .success(_):
                    HUD.flash(.success)
                    self?.dismiss(animated: true, completion: {
                        self?.contentTextView.html = ""
                        self?.titleTextField.text = ""
                        self?.tagButton.setTitleColor(.label, for: .normal)
                        self?.tagButton.setTitle("選擇標籤...", for: .normal)
                        self?.threadVC?.unwindToThreadListAfterNewPost()
                    })
                case .failure(let error):
                    HUD.flash(.error)
                    print(error)
                }
            }
        }
    }
    
    @objc override func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: {
            self.contentTextView.html = ""
            self.titleTextField.text = ""
            self.tagButton.setTitleColor(.label, for: .normal)
            self.tagButton.setTitle("選擇標籤...", for: .normal)
        })
    }
    
    /*override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            selectTagLabel.snp.updateConstraints {
                (make) -> Void in
                if UIDevice.current.userInterfaceIdiom == .pad {
                    make.bottom.equalTo(view.snp.bottomMargin).offset(-keyboardHeight+(UIScreen.main.bounds.height*0.18))
                } else {
                    make.bottom.equalTo(view.snp.bottomMargin).offset(-keyboardHeight)
                }
            }
            tagButton.snp.updateConstraints {
                (make) -> Void in
                if UIDevice.current.userInterfaceIdiom == .pad {
                    make.bottom.equalTo(view.snp.bottomMargin).offset(-keyboardHeight+(UIScreen.main.bounds.height*0.18))
                } else {
                    make.bottom.equalTo(view.snp.bottomMargin).offset(-keyboardHeight)
                }
            }
        }
    }
    
    override func keyboardWillHide(notification: Notification) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            selectTagLabel.snp.updateConstraints {
                (make) -> Void in
                make.bottom.equalTo(view.snp.bottomMargin).offset(-20)
            }
            tagButton.snp.updateConstraints {
                (make) -> Void in
                make.bottom.equalTo(view.snp.bottomMargin).offset(-20)
            }
        }
    }*/
    
    func unwindToCompose(tagName: String,tagID: String,tagColor: String) {
        self.tagID = tagID
        tagButton.setTitle(tagName, for: .normal)
        tagButton.setTitleColor(UIColor(hexRGB: tagColor), for: .normal)
    }
    
    @objc func tagButtonPressed(_ sender: UIButton) {
        let tagsVC = TagsTableViewController()
        tagsVC.composeVC = self
        tagsVC.modalPresentationStyle = .popover
        tagsVC.popoverPresentationController?.delegate = self
        tagsVC.popoverPresentationController?.sourceView = tagButton
        tagsVC.popoverPresentationController?.sourceRect = tagButton.bounds
        tagsVC.popoverPresentationController?.backgroundColor = .systemFill
        tagsVC.preferredContentSize = CGSize(width: 200, height: 200)
        self.present(tagsVC, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
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
