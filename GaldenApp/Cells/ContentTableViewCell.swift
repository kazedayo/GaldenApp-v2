//
//  ContentTableViewCell.swift
//  
//
//  Created by Kin Wa Lam on 2/10/2017.
//

import UIKit
import WebKit
import Kingfisher

class ContentTableViewCell: UITableViewCell {
    
    //MARK: Properties
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLevelLabel: UILabel!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var replyCountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var quoteButton: UIButton!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureOP(opData: OP) {
        
        userNameLabel.text = opData.name
        
        if(opData.gender == "male") {
            userNameLabel.textColor = UIColor(red:0.68, green:0.78, blue:0.81, alpha:1.0)
        }
        else {
            userNameLabel.textColor = UIColor(red:1.00, green:0.41, blue:0.38, alpha:1.0)
        }
        
        if(opData.level == "lv1") {
            userLevelLabel.text = "普通會然"
            userLevelLabel.backgroundColor = UIColor.darkGray
        }
        else if (opData.level == "lv2") {
            userLevelLabel.text = "迷の存在"
            userLevelLabel.backgroundColor = UIColor(red:0.55, green:0.00, blue:0.00, alpha:1.0)
        }
        else if (opData.level == "lv3") {
            userLevelLabel.text = "肉務腸"
            userLevelLabel.backgroundColor = UIColor(red:0.47, green:0.87, blue:0.47, alpha:1.0)
        }
        else if (opData.level == "lv4") {
            userLevelLabel.text = "唉屎"
            userLevelLabel.backgroundColor = UIColor(red:0.00, green:1.00, blue:1.00, alpha:1.0)
        }
        
        let avatarURL = URL(string: "https://hkgalden.com" + opData.avatar)
        if (opData.avatar == "") {
            userAvatarImageView.image = UIImage(named: "DefaultAvatar")
        }
        else {
            userAvatarImageView.kf.setImage(with: avatarURL)
        }
        
        replyCountLabel.text = "OP"
        dateLabel.text = opData.date
        quoteButton.tag = 0
        blockButton.tag = 0
        reportButton.tag = 0
        quoteButton.isEnabled = true
        blockButton.isEnabled = true
        reportButton.isEnabled = true
    }
    
    func configureReplyFirstPage(comments: [Replies],indexPath: IndexPath,pageNow: Int) {
        
        userNameLabel.text = comments[indexPath.row - 1].name
        
        if(comments[indexPath.row - 1].gender == "male") {
            userNameLabel.textColor = UIColor(red:0.68, green:0.78, blue:0.81, alpha:1.0)
        }
        else {
            userNameLabel.textColor = UIColor(red:1.00, green:0.41, blue:0.38, alpha:1.0)
        }
        
        if(comments[indexPath.row - 1].level == "lv1") {
            userLevelLabel.text = "普通會然"
            userLevelLabel.backgroundColor = UIColor.darkGray
        }
        else if (comments[indexPath.row - 1].level == "lv2") {
            userLevelLabel.text = "迷の存在"
            userLevelLabel.backgroundColor = UIColor(red:0.55, green:0.00, blue:0.00, alpha:1.0)
        }
        else if (comments[indexPath.row - 1].level == "lv3") {
            userLevelLabel.text = "肉務腸"
            userLevelLabel.backgroundColor = UIColor(red:0.47, green:0.87, blue:0.47, alpha:1.0)
        }
        else if (comments[indexPath.row - 1].level == "lv4") {
            userLevelLabel.text = "唉屎"
            userLevelLabel.backgroundColor = UIColor(red:0.00, green:1.00, blue:1.00, alpha:1.0)
        }
        
        let avatarURL = URL(string: "https://hkgalden.com" + comments[indexPath.row - 1].avatar)
        if (comments[indexPath.row - 1].avatar == "") {
            userAvatarImageView.image = UIImage(named: "DefaultAvatar")
        }
        else {
            userAvatarImageView.kf.setImage(with: avatarURL)
        }
        
        replyCountLabel.text = "#" + String(25 * (pageNow - 1) + indexPath.row)
        dateLabel.text = comments[indexPath.row - 1].date
        quoteButton.tag = indexPath.row
        blockButton.tag = indexPath.row
        reportButton.tag = indexPath.row
        quoteButton.isEnabled = true
        blockButton.isEnabled = true
        reportButton.isEnabled = true
    }
    
    func configureReply(comments: [Replies],indexPath: IndexPath,pageNow: Int) {
        
        userNameLabel.text = comments[indexPath.row].name
        
        if(comments[indexPath.row].gender == "male") {
            userNameLabel.textColor = UIColor(red:0.68, green:0.78, blue:0.81, alpha:1.0)
        }
        else {
            userNameLabel.textColor = UIColor(red:1.00, green:0.41, blue:0.38, alpha:1.0)
        }
        
        if(comments[indexPath.row].level == "lv1") {
            userLevelLabel.text = "普通會然"
            userLevelLabel.backgroundColor = UIColor.darkGray
        }
        else if (comments[indexPath.row].level == "lv2") {
            userLevelLabel.text = "迷の存在"
            userLevelLabel.backgroundColor = UIColor(red:0.55, green:0.00, blue:0.00, alpha:1.0)
        }
        else if (comments[indexPath.row].level == "lv3") {
            userLevelLabel.text = "肉務腸"
            userLevelLabel.backgroundColor = UIColor(red:0.47, green:0.87, blue:0.47, alpha:1.0)
        }
        else if (comments[indexPath.row].level == "lv4") {
            userLevelLabel.text = "唉屎"
            userLevelLabel.backgroundColor = UIColor(red:0.00, green:1.00, blue:1.00, alpha:1.0)
        }
        
        let avatarURL = URL(string: "https://hkgalden.com" + comments[indexPath.row].avatar)
        if (comments[indexPath.row].avatar == "") {
            userAvatarImageView.image = UIImage(named: "DefaultAvatar")
        }
        else {
            userAvatarImageView.kf.setImage(with: avatarURL)
        }
        
        replyCountLabel.text = "#" + String(25 * (pageNow - 1) + indexPath.row + 1)
        dateLabel.text = comments[indexPath.row].date
        quoteButton.tag = indexPath.row
        blockButton.tag = indexPath.row
        reportButton.tag = indexPath.row
        quoteButton.isEnabled = true
        blockButton.isEnabled = true
        reportButton.isEnabled = true
    }
    
    func configureBlocked(indexPath: IndexPath) {
        userAvatarImageView.image = UIImage(named: "block")
        userNameLabel.text = "//XXX//"
        userNameLabel.textColor = .gray
        userLevelLabel.text = "???"
        replyCountLabel.text = ""
        dateLabel.text = ""
        quoteButton.isEnabled = false
        blockButton.isEnabled = false
        reportButton.isEnabled = false
    }
}
