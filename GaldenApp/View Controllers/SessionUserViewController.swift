//
//  SessionUserViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 11/11/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import UIKit
import SwiftDate

class SessionUserViewController: UserViewController {
    
    var blockedUsers: [GetBlockedUsersQuery.Data.BlockedUser] = []
    let segmentControl = UISegmentedControl.init(items: ["起底","封鎖名單"])
    let refControl = UIRefreshControl()
    lazy var logoutButton = UIBarButtonItem(title: "登出", style: .done, target: self, action: #selector(logoutButtonPressed(_:)))

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.navigationItem.title = "會員資料"
        tabBarController?.navigationItem.leftBarButtonItem = nil
        tabBarController?.navigationItem.rightBarButtonItem = logoutButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableView.register(UserTableViewCell.classForCoder(), forCellReuseIdentifier: "UserTableViewCell")
        
        //refreshcontrol
        refControl.addTarget(self, action: #selector(refresh(refreshControl:)), for: .valueChanged)
        tableView.refreshControl = refControl
        
        segmentControl.tintColor = UIColor(hexRGB: "#45c17c")
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(onChange(_:)), for: .valueChanged)
        headerView.addSubview(segmentControl)
        
        segmentControl.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(ugroupLabel.snp.bottom).offset(20)
            make.centerX.equalTo(headerView)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 140
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if segmentControl.selectedSegmentIndex == 0 {
            count = userThreads.count
        } else if segmentControl.selectedSegmentIndex == 1 {
            count = blockedUsers.count
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellToReturn: UITableViewCell!
        if segmentControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ThreadListTableViewCell") as! ThreadListTableViewCell
            let title = self.userThreads[indexPath.row].title.trimmingCharacters(in: .whitespacesAndNewlines)
            let count = self.userThreads[indexPath.row].totalReplies
            let dateMap = self.userThreads[indexPath.row].replies.map {$0.date}
            let date = dateMap.last!.toISODate()
            let relativeDate = date?.toRelative(since: DateInRegion(), style: RelativeFormatter.twitterStyle(), locale: Locales.chineseTaiwan)
            cell.threadTitleLabel.text = title
            cell.detailLabel.text = "你的回覆: \(count) // 最後一次回覆: \(relativeDate!)"
            let tags = self.userThreads[indexPath.row].tags.map {$0.fragments.tagDetails}
            cell.tagLabel.text = "#\(tags[0].name)"
            cell.tagLabel.textColor = UIColor(hexRGB: tags[0].color)
            cellToReturn = cell
        } else if segmentControl.selectedSegmentIndex == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell") as! UserTableViewCell
            let avatar = self.blockedUsers[indexPath.row].avatar
            let nickname = self.blockedUsers[indexPath.row].nickname
            let gender = self.blockedUsers[indexPath.row].gender
            let groups = self.blockedUsers[indexPath.row].groups
            if avatar != nil {
                cell.avatarView.kf.setImage(with: URL(string: (avatar)!)!)
            } else {
                cell.avatarView.kf.setImage(with: URL(string: "https://i.imgur.com/2lya6uS.png")!)
            }
            cell.unameLabel.text = nickname
            if gender == UserGender.m {
                cell.unameLabel.textColor = UIColor(hexRGB: "22c1fe")
            } else if gender == UserGender.f {
                cell.unameLabel.textColor = UIColor(hexRGB: "ff7aab")
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentControl.selectedSegmentIndex == 0 {
            DispatchQueue.main.async {
                let contentVC = ContentViewController()
                let contentNav = UINavigationController(rootViewController: contentVC)
                let selectedThread = self.userThreads[indexPath.row].id
                contentVC.tID = selectedThread
                contentVC.title = self.userThreads[indexPath.row].title
                contentVC.sender = "cell"
                //contentVC.hidesBottomBarWhenPushed = true
                self.splitViewController?.showDetailViewController(contentNav, sender: self)
            }
        } else if segmentControl.selectedSegmentIndex == 1 {
            let alert = UIAlertController(title: "解除封鎖", message: "你確定要解除封鎖此會員?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "55", style: .destructive, handler: {
                action in
                let unblockUserMutation = UnblockUserMutation(id: self.blockedUsers[indexPath.row].id)
                apollo.perform(mutation: unblockUserMutation) {
                    [weak self] result,error in
                    if result?.data?.unblockUser == true {
                        let success = UIAlertController(title: "成功", message: "你已解除此會員封鎖", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .cancel, handler: {
                            action in
                            self?.getBlockedUsers {
                                success.dismiss(animated: true, completion: nil)
                            }
                        })
                        success.addAction(ok)
                        self?.present(success,animated: true,completion: nil)
                    }
                }
            })
            let no = UIAlertAction(title: "不了", style: .cancel, handler: {
                action in
                tableView.deselectRow(at: indexPath, animated: true)
            })
            alert.addAction(yes)
            alert.addAction(no)
            present(alert,animated: true,completion: nil)
        }
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
        keychain.delete("userKey")
        var controllers = tabBarController?.viewControllers
        let loginViewController = LoginViewController()
        loginViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "user"), tag: 1)
        loginViewController.tabBarItem.imageInsets = UIEdgeInsets.init(top: 6, left: 0, bottom: -6, right: 0)
        controllers![1] = loginViewController
        tabBarController?.setViewControllers(controllers, animated: false)
    }

    private func getBlockedUsers(completion: @escaping ()-> Void) {
        let getBlockedUsersQuery = GetBlockedUsersQuery()
        NetworkActivityIndicatorManager.networkOperationStarted()
        apollo.fetch(query: getBlockedUsersQuery,cachePolicy: .fetchIgnoringCacheData) {
            [weak self] result,error in
            if error == nil {
                self?.blockedUsers = (result?.data?.blockedUsers)!
                sessionUser?.blockedUserIds = (result?.data?.blockedUsers.map {$0.id})!
                //self?.tableView.reloadSections(IndexSet(integer: 0), with: .none)
                self?.tableView.reloadData()
                NetworkActivityIndicatorManager.networkOperationFinished()
                completion()
            }
        }
    }
    
    @objc func onChange(_ sender: UISegmentedControl) {
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
    
    @objc func refresh(refreshControl: UIRefreshControl) {
        if segmentControl.selectedSegmentIndex == 0 {
            pageCount=1
            getUserThreads(completion: {
                refreshControl.endRefreshing()
            })
        } else if segmentControl.selectedSegmentIndex == 1 {
            getBlockedUsers(completion: {
                refreshControl.endRefreshing()
            })
        }
    }
    
}
