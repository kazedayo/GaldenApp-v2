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
    var uid: String!
    var pageCount = 1
    
    let avatarView = UIImageView()
    let unameLabel = UILabel()
    let ugroupLabel = UILabel()
    let headerView = UIView()
    let tableView = UITableView()
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        navigationItem.title = "起底"
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 0)
        tableView.separatorColor = UIColor(white: 0.10, alpha: 1)
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ThreadListTableViewCell.classForCoder(), forCellReuseIdentifier: "ThreadListTableViewCell")
        view.addSubview(tableView)
        
        if uid == nil {
            uid = sessionUser?.id
        }
        let getUserQuery = GetUserQuery(id: uid)
        NetworkActivityIndicatorManager.networkOperationStarted()
        apollo.fetch(query: getUserQuery) {
            [weak self] result, error in
            NetworkActivityIndicatorManager.networkOperationFinished()
            if error == nil {
                let user = result?.data?.user
                //avatar
                if user?.avatar != nil {
                    self?.avatarView.kf.setImage(with: URL(string: (user?.avatar)!)!)
                } else {
                    self?.avatarView.kf.setImage(with: URL(string: "https://i.imgur.com/2lya6uS.png")!)
                }
                self?.avatarView.clipsToBounds = true
                self?.avatarView.layer.cornerRadius = 25
                
                //user name
                self?.unameLabel.text = user?.nickname
                self?.unameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
                self?.unameLabel.adjustsFontForContentSizeCategory = true
                if user?.gender == UserGender.m {
                    self?.unameLabel.textColor = UIColor(hexRGB: "6495ed")
                } else if user?.gender == UserGender.f {
                    self?.unameLabel.textColor = UIColor(hexRGB: "ff6961")
                }
                
                //user group
                self?.ugroupLabel.text = "郊登仔"
                self?.ugroupLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
                self?.ugroupLabel.adjustsFontForContentSizeCategory = true
                self?.ugroupLabel.textColor = UIColor(hexRGB: "aaaaaa")
                if user?.groups.isEmpty == false {
                   self?.ugroupLabel.text = sessionUser?.groups[0].name
                    if user?.groups[0].id == "DEVELOPER" {
                        self?.ugroupLabel.textColor = UIColor(hexRGB: "9e3e3f")
                    } else if user?.groups[0].id == "ADMIN" {
                        self?.ugroupLabel.textColor = UIColor(hexRGB: "4b6690")
                    }
                }
                self?.getUserThreads(completion: {})
            }
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(refreshControl:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        headerView.addSubview(avatarView)
        headerView.addSubview(unameLabel)
        headerView.addSubview(ugroupLabel)
        headerView.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        headerView.insertSubview(blurView, at: 0)
        
        activityIndicator.snp.makeConstraints {
            (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        blurView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        avatarView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalToSuperview().offset(20)
            make.leading.equalTo(20)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        unameLabel.snp.makeConstraints {
            (make) -> Void in
            make.top.equalToSuperview().offset(20)
            make.leading.equalTo(avatarView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        ugroupLabel.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(unameLabel.snp.bottom).offset(10)
            make.leading.equalTo(avatarView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        tableView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let indexPath = tableView.indexPathForSelectedRow
        if indexPath != nil {
            tableView.deselectRow(at: indexPath!, animated: true)
            tableView.reloadRows(at: [indexPath!], with: .fade)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isToolbarHidden = true
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userThreads.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreadListTableViewCell") as! ThreadListTableViewCell
        let title = self.userThreads[indexPath.row].title
        let count = self.userThreads[indexPath.row].totalReplies
        let dateMap = self.userThreads[indexPath.row].replies.map {$0.date}
        let date = dateMap.last!.toISODate()
        let relativeDate = date?.toRelative(since: DateInRegion(), style: RelativeFormatter.twitterStyle(), locale: Locales.chineseTaiwan)
        cell.backgroundColor = UIColor(white: 0.15, alpha: 1)
        cell.threadTitleLabel.text = title
        cell.threadTitleLabel.textColor = .lightGray
        cell.detailLabel.text = "你的回覆: \(count) // 最後一次回覆: \(relativeDate!)"
        cell.detailLabel.textColor = .darkGray
        let tags = self.userThreads[indexPath.row].tags.map {$0.fragments.tagDetails}
        cell.tagLabel.text = "#\(tags[0].name)"
        cell.tagLabel.textColor = UIColor(hexRGB: tags[0].color)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let contentVC = ContentViewController()
            let selectedThread = self.userThreads[indexPath.row].id
            contentVC.tID = selectedThread
            contentVC.title = self.userThreads[indexPath.row].title
            contentVC.sender = "cell"
            contentVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(contentVC, animated: true)
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
    
    func getUserThreads(completion: @escaping ()->Void) {
        let getUserThreadsQuery = GetUserThreadsQuery(id:uid,page:pageCount)
        if (pageCount==1){
            NetworkActivityIndicatorManager.networkOperationStarted()
        }
        apollo.fetch(query:getUserThreadsQuery,cachePolicy: .fetchIgnoringCacheData) {
            [weak self] result,error in
            if error == nil {
                self?.userThreads.append(contentsOf: (result?.data?.threadsByUser.map {$0.fragments.threadListDetails})!)
                if (self?.pageCount==6){
                    self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                    NetworkActivityIndicatorManager.networkOperationFinished()
                    self?.tableView.isHidden = false
                    completion()
                } else {
                    self?.pageCount+=1
                    print("fetched once")
                    self?.getUserThreads(completion: completion)
                }
                
            }
        }
    }
    
    @objc func refresh(refreshControl: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: 0.3, execute: {
            self.pageCount=1
            self.userThreads.removeAll()
            self.getUserThreads(completion: {
                refreshControl.endRefreshing()
            })
        })
    }
    
}
