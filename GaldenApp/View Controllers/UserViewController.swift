//
//  UserViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 24/7/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftDate

class UserViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var userThreads: [ThreadListDetails] = []
    var blockedUsers: [GetBlockedUsersQuery.Data.BlockedUser] = []
    
    let avatarView = UIImageView()
    let unameLabel = UILabel()
    let ugroupLabel = UILabel()
    let tableView = UITableView()
    let segmentControl = UISegmentedControl.init(items: ["起底","封鎖名單"])
    lazy var logoutButton = UIBarButtonItem(title: "登出", style: .done, target: self, action: #selector(logoutButtonPressed(_:)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        self.title = "會員資料"
        navigationItem.rightBarButtonItem = logoutButton
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0)
        tableView.separatorColor = UIColor(white: 0.10, alpha: 1)
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(ThreadListTableViewCell.classForCoder(), forCellReuseIdentifier: "ThreadListTableViewCell")
        tableView.register(UserTableViewCell.classForCoder(), forCellReuseIdentifier: "UserTableViewCell")
        view.addSubview(tableView)
        
        segmentControl.tintColor = UIColor(hexRGB: "#568064")
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(onChange(_:)), for: .valueChanged)
        view.addSubview(segmentControl)
        
        //avatar
        if sessionUser?.avatar != nil {
            avatarView.kf.setImage(with: URL(string: (sessionUser?.avatar)!)!)
        } else {
            avatarView.kf.setImage(with: URL(string: "https://i.imgur.com/mrD0tRG.png")!)
        }
        
        //user name
        unameLabel.text = sessionUser?.nickname
        if sessionUser?.gender == UserGender.m {
            unameLabel.textColor = UIColor(hexRGB: "6495ed")
        } else if sessionUser?.gender == UserGender.f {
            unameLabel.textColor = UIColor(hexRGB: "ff6961")
        }
        
        //user group
        ugroupLabel.text = "郊登仔"
        ugroupLabel.textColor = UIColor(hexRGB: "aaaaaa")
        if sessionUser?.groups.isEmpty == false {
            ugroupLabel.text = sessionUser?.groups[0].name
            if sessionUser?.groups[0].id == "DEVELOPER" {
                ugroupLabel.textColor = UIColor(hexRGB: "9e3e3f")
            } else if sessionUser?.groups[0].id == "ADMIN" {
                ugroupLabel.textColor = UIColor(hexRGB: "4b6690")
            }
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(white: 0.13, alpha: 1)
        refreshControl.addTarget(self, action: #selector(refresh(refreshControl:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
            tableView.addSubview(refreshControl)
        }
        
        getUserThreads(completion: {})
        
        view.addSubview(avatarView)
        view.addSubview(unameLabel)
        view.addSubview(ugroupLabel)
        
        avatarView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(view.snp.topMargin).offset(20)
            make.leading.equalTo(20)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        unameLabel.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(view.snp.topMargin).offset(20)
            make.leading.equalTo(avatarView.snp.trailing).offset(10)
        }
        
        ugroupLabel.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(unameLabel.snp.bottom).offset(10)
            make.leading.equalTo(avatarView.snp.trailing).offset(10)
        }
        
        segmentControl.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(ugroupLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(segmentControl.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.bottomMargin)
        }
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if segmentControl.selectedSegmentIndex == 0 {
            count = userThreads.count
        } else if segmentControl.selectedSegmentIndex == 1 {
            count = blockedUsers.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellToReturn: UITableViewCell!
        if segmentControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ThreadListTableViewCell") as! ThreadListTableViewCell
            let title = self.userThreads[indexPath.row].title
            let nickName = self.userThreads[indexPath.row].replies.map {$0.authorNickname}
            let count = self.userThreads[indexPath.row].totalReplies
            let dateMap = self.userThreads[indexPath.row].replies.map {$0.date}
            let date = dateMap.last!.toISODate()
            let relativeDate = date?.toRelative(since: DateInRegion(), style: RelativeFormatter.twitterStyle(), locale: Locales.chineseTraditional)
            cell.backgroundColor = UIColor(white: 0.15, alpha: 1)
            cell.threadTitleLabel.text = title
            cell.threadTitleLabel.textColor = .lightGray
            cell.detailLabel.text = "\(nickName[0]) // 回覆: \(count) // 最後回覆: \(relativeDate!)"
            cell.detailLabel.textColor = .darkGray
            let tags = self.userThreads[indexPath.row].tags.map {$0.fragments.tagDetails}
            cell.tagLabel.text = "#\(tags[0].name)"
            cell.tagLabel.textColor = UIColor(hexRGB: tags[0].color)
            cellToReturn = cell
        } else if segmentControl.selectedSegmentIndex == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell") as! UserTableViewCell
            cell.backgroundColor = UIColor(white: 0.15, alpha: 1)
            let avatar = self.blockedUsers[indexPath.row].avatar
            let nickname = self.blockedUsers[indexPath.row].nickname
            let gender = self.blockedUsers[indexPath.row].gender
            let groups = self.blockedUsers[indexPath.row].groups
            if avatar != nil {
                cell.avatarView.kf.setImage(with: URL(string: (avatar)!)!)
            } else {
                cell.avatarView.kf.setImage(with: URL(string: "https://i.imgur.com/mrD0tRG.png")!)
            }
            cell.unameLabel.text = nickname
            if gender == UserGender.m {
                cell.unameLabel.textColor = UIColor(hexRGB: "6495ed")
            } else if gender == UserGender.f {
                cell.unameLabel.textColor = UIColor(hexRGB: "ff6961")
            }
            if groups.isEmpty == false {
                cell.ugroupLabel.text = groups[0].name
                if groups[0].id == "DEVELOPER" {
                    cell.ugroupLabel.textColor = UIColor(hexRGB: "9e3e3f")
                } else if groups[0].id == "ADMIN" {
                    cell.ugroupLabel.textColor = UIColor(hexRGB: "4b6690")
                }
            }
            cellToReturn = cell
        }
        return cellToReturn
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func logoutButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
    private func getUserThreads(completion: @escaping ()->Void) {
        let getUserThreadsQuery = GetUserThreadsQuery(id:sessionUser!.id,page:1)
        NetworkActivityIndicatorManager.networkOperationStarted()
        apollo.fetch(query:getUserThreadsQuery,cachePolicy: .fetchIgnoringCacheData) {
            [weak self] result,error in
            if error == nil {
                self?.userThreads = (result?.data?.threadsByUser.map {$0.fragments.threadListDetails})!
                self?.tableView.reloadData()
                NetworkActivityIndicatorManager.networkOperationFinished()
                completion()
            }
        }
    }
    
    private func getBlockedUsers(completion: @escaping ()-> Void) {
        let getBlockedUsersQuery = GetBlockedUsersQuery()
        NetworkActivityIndicatorManager.networkOperationStarted()
        apollo.fetch(query: getBlockedUsersQuery,cachePolicy: .fetchIgnoringCacheData) {
            [weak self] result,error in
            if error == nil {
                self?.blockedUsers = (result?.data?.blockedUsers)!
                self?.tableView.reloadData()
                NetworkActivityIndicatorManager.networkOperationFinished()
                completion()
            }
        }
    }
    
    @objc func refresh(refreshControl: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: 0.3, execute: {
            if self.segmentControl.selectedSegmentIndex == 0 {
                self.getUserThreads(completion: {
                    refreshControl.endRefreshing()
                })
            } else if self.segmentControl.selectedSegmentIndex == 1 {
                self.getBlockedUsers(completion: {
                    refreshControl.endRefreshing()
                })
            }
        })
    }
    
    @objc func onChange(_ sender: UISegmentedControl) {
        tableView.isHidden = true
        if segmentControl.selectedSegmentIndex == 0 {
            getUserThreads(completion: {
                self.tableView.isHidden = false
            })
        } else if segmentControl.selectedSegmentIndex == 1 {
            getBlockedUsers(completion: {
                self.tableView.isHidden = false
            })
        }
    }
    
}
