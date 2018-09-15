//
//  ThreadListViewController.swift
//  
//
//  Created by Kin Wa Lam on 7/10/2017.
//

import UIKit
import PKHUD
import GoogleMobileAds
import QuartzCore
import SideMenu
import RealmSwift
import SwiftEntryKit
import SwiftDate

class ThreadListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,GADBannerViewDelegate,UIPopoverPresentationControllerDelegate {
    
    //MARK: Properties
    var threads: [ThreadListDetails] = []
    var channelNow: String = "bw"
    var tagsId: [String] = []
    var pageNow: Int = 1
    var pageCount: Double?
    var selectedThread: Int?
    var selectedPage: Int?
    var selectedThreadTitle: String!
    
    let realm = try! Realm()
    let tableView = UITableView()
    let adBannerView = GADBannerView()
    let sideMenuVC = SideMenuViewController()
    //lazy var longPress = UILongPressGestureRecognizer(target: self, action: #selector(jumpToPage(_:)))
    lazy var sideMenuButton = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(channelButtonPressed(sender:)))
    //lazy var newThread = UIBarButtonItem(image: UIImage(named: "compose"), style: .plain, target: self, action: #selector(newThreadButtonPressed))
    
    var reloadButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: sideMenuVC)
        sideMenuVC.mainVC = self
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view, forMenu: .left)
        SideMenuManager.default.menuPushStyle = .subMenu
        SideMenuManager.default.menuWidth = 150
        SideMenuManager.default.menuFadeStatusBar = false
        
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .automatic
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = true
        }
        tableView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0)
        tableView.separatorColor = UIColor(white: 0.10, alpha: 1)
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(ThreadListTableViewCell.classForCoder(), forCellReuseIdentifier: "ThreadListTableViewCell")
        tableView.register(BlockedTableViewCell.classForCoder(), forCellReuseIdentifier: "BlockedTableViewCell")
        //tableView.addGestureRecognizer(longPress)
        view.addSubview(tableView)
        
        adBannerView.adUnitID = "ca-app-pub-6919429787140423/1613095078"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        view.addSubview(adBannerView)
        
        tableView.snp.makeConstraints {
            (make) -> Void in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        adBannerView.snp.makeConstraints {
            (make) -> Void in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.snp.bottomMargin)
            } else {
                make.bottom.equalTo(view.snp.bottom)
            }
            make.height.equalTo(50)
        }
        
        navigationItem.leftBarButtonItem = sideMenuButton
        //navigationItem.rightBarButtonItem = newThread
        navigationItem.title = "吹水臺"
        
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(white: 0.13, alpha: 1)
        refreshControl.addTarget(self, action: #selector(refresh(refreshControl: )), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
            tableView.addSubview(refreshControl)
        }
        
        reloadButton.center = self.view.center
        reloadButton.setTitle("重新載入", for: .normal)
        reloadButton.isHidden = true
        reloadButton.addTarget(self, action: #selector(reloadButtonPressed(_:)), for: .touchUpInside)
        
        updateSequence(append: false, completion: {})
    }
    
    @objc func refresh(refreshControl: UIRefreshControl) {
        pageNow = 1
        DispatchQueue.main.asyncAfter(deadline: 0.3, execute: {
            self.updateSequence(append: false, completion: {
                refreshControl.endRefreshing()
            })
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isToolbarHidden = true
        if (keychain.getBool("noAd") == true) {
            adBannerView.removeFromSuperview()
            view.layoutSubviews()
        } else {
            adBannerView.load(GADRequest())
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let indexPath = tableView.indexPathForSelectedRow
        if indexPath != nil {
            tableView.deselectRow(at: indexPath!, animated: true)
            tableView.reloadRows(at: [indexPath!], with: .fade)
        }
        if #available(iOS 11.0, *) {
            self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: adBannerView.frame.height, right: 0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: adBannerView.frame.height, right: 0)
        } else {
            self.tableView.contentInset = UIEdgeInsets.init(top: (navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height, left: 0, bottom: (navigationController?.toolbar.frame.height)! + adBannerView.frame.height, right: 0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsets.init(top: (navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height, left: 0, bottom: (navigationController?.toolbar.frame.height)! + adBannerView.frame.height, right: 0)
        }
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        //print("Banner loaded successfully")
        // Reposition the banner ad to create a slide down effect
        let translateTransform = CGAffineTransform(translationX: 0, y: bannerView.bounds.size.height)
        bannerView.transform = translateTransform
        
        UIView.animate(withDuration: 0.5) {
            bannerView.transform = CGAffineTransform.identity
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        //print("Fail to receive ads")
        print(error)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return threads.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let title = self.threads[indexPath.row].title
        let nickName = self.threads[indexPath.row].replies.map {$0.authorNickname}
        let count = self.threads[indexPath.row].totalReplies
        let dateMap = self.threads[indexPath.row].replies.map {$0.date}
        let date = dateMap.last!.toISODate()
        let relativeDate = date?.toRelative(since: DateInRegion(), style: RelativeFormatter.twitterStyle(), locale: Locales.chineseTraditional)
        let readThreads = realm.object(ofType: History.self, forPrimaryKey: self.threads[indexPath.row].id)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreadListTableViewCell") as! ThreadListTableViewCell
        if (readThreads != nil) {
            let newReplyCount = count-readThreads!.replyCount
            if (newReplyCount > 0) {
                let newReply = UILabel()
                newReply.clipsToBounds = true
                newReply.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
                newReply.layer.cornerRadius = 5
                newReply.textColor = .white
                newReply.font = UIFont.systemFont(ofSize: 10)
                newReply.backgroundColor = .red
                newReply.textAlignment = .center
                newReply.text = String(count-readThreads!.replyCount)
                cell.accessoryView = newReply
            } else {
                cell.accessoryView = UIView()
            }
            //cell.accessoryView = UIImageView(image: UIImage(named: "read"))
        } else {
            cell.accessoryView = UIView()
        }
        cell.backgroundColor = UIColor(white: 0.15, alpha: 1)
        cell.threadTitleLabel.text = title
        cell.threadTitleLabel.textColor = .lightGray
        cell.detailLabel.text = "\(nickName[0]) // 回覆: \(count) // 最後回覆: \(relativeDate!)"
        cell.detailLabel.textColor = .darkGray
        let tags = self.threads[indexPath.row].tags.map {$0.fragments.tagDetails}
        cell.tagLabel.text = "#\(tags[0].name)"
        cell.tagLabel.textColor = UIColor(hexRGB: tags[0].color)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let contentVC = ContentViewController()
            let selectedThread = self.threads[indexPath.row].id
            contentVC.tID = selectedThread
            contentVC.title = self.threads[indexPath.row].title
            contentVC.sender = "cell"
            contentVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(contentVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (threads.count - indexPath.row) == 1 {
            self.pageNow += 1
            DispatchQueue.main.async {
                self.updateSequence(append: true, completion: {})
            }
        }
    }
    
    /*@objc func jumpToPage(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                self.selectedThread = threads[indexPath.row].id
                self.selectedThreadTitle = threads[indexPath.row].title
                self.pageCount = ceil((Double(threads[indexPath.row].totalReplies))/50)
                let pageVC = PageSelectViewController()
                pageVC.pageCount = self.pageCount!
                pageVC.titleText = self.selectedThreadTitle
                pageVC.mainVC = self
                SwiftEntryKit.display(entry: pageVC, using: EntryAttributes.shared.centerEntryZoom())
            }
        }
    }*/
    
    @objc func channelButtonPressed(sender: UIBarButtonItem) {
        sideMenuVC.mainVC = self
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    /*@objc func newThreadButtonPressed() {
        let composeVC = ComposeViewController()
        let composeNavVC = UINavigationController(rootViewController: composeVC)
        composeVC.channel = channelNow
        composeVC.composeType = .newThread
        composeVC.threadVC = self
        //SwiftEntryKit.display(entry: composeVC, using: EntryAttributes.shared.centerEntry())
        present(composeNavVC, animated: true, completion: nil)
    }*/
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "pageSelect":
            
        default:
            break
        }
    }*/
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    //Delegates
    func unwindToThreadList(channel: ChannelDetails,tags: [TagDetails]) {
        self.channelNow = channel.id
        self.pageNow = 1
        self.tagsId = tags.compactMap {$0.id}
        self.navigationItem.title = channel.name
        self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        self.updateSequence(append: false, completion: {})
    }
    
    func unwindToThreadListAfterNewPost() {
        self.updateSequence(append: false, completion: {})
    }
    
    func unwindAfterPageSelect(pageSelected: Int) {
        self.selectedPage = pageSelected
        DispatchQueue.main.async {
            let contentVC = ContentViewController()
            //contentVC.threadIdReceived = self.selectedThread
            contentVC.title = self.selectedThreadTitle
            contentVC.pageNow = self.selectedPage!
            self.navigationController?.pushViewController(contentVC, animated: true)
        }
    }
    
    @objc func reloadButtonPressed(_ sender: UIButton) {
        self.updateSequence(append: false, completion: {})
    }
    
    private func updateSequence(append: Bool, completion: @escaping ()->Void) {
        let getThreadsQuery = GetThreadsQuery(id: tagsId, page: pageNow)
        apollo.fetch(query: getThreadsQuery,cachePolicy: .fetchIgnoringCacheData) {
            [weak self] result, error in
            if (error == nil) {
                if append == true {
                    guard let threads = result?.data?.threads else { return }
                    self?.threads.append(contentsOf: threads.map {$0.fragments.threadListDetails})
                } else {
                    guard let threads = result?.data?.threads else { return }
                    self?.threads = threads.map {$0.fragments.threadListDetails}
                }
                self?.tableView.reloadData()
                self?.reloadButton.isHidden = true
                self?.tableView.isHidden = false
            } else {
                self?.reloadButton.isHidden = false
            }
        }
        completion()
    }
}
