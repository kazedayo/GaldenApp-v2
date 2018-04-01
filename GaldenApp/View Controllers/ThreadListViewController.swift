//
//  ThreadListViewController.swift
//  
//
//  Created by Kin Wa Lam on 7/10/2017.
//

import UIKit
import KeychainSwift
import PKHUD
import GoogleMobileAds
import QuartzCore

class ThreadListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,GADBannerViewDelegate,UIPopoverPresentationControllerDelegate {
    
    //MARK: Properties
    var threads = [ThreadList]()
    var channelNow: Int = 0
    var pageNow: Int = 1
    var pageCount: Double?
    var selectedThread: String!
    var blockedUsers = [String]()
    var selectedPage: Int?
    var selectedThreadTitle: String!
    
    let tableView = UITableView()
    let adBannerView = GADBannerView()
    lazy var longPress = UILongPressGestureRecognizer(target: self, action: #selector(jumpToPage(_:)))
    lazy var flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    lazy var channelSwitch = UIBarButtonItem(image: UIImage(named: "channel"), style: .plain, target: self, action: #selector(channelButtonPressed(sender:)))
    lazy var newThread = UIBarButtonItem(image: UIImage(named: "Add"), style: .plain, target: self, action: #selector(newThreadButtonPressed))
    lazy var userDetail = UIBarButtonItem(image: UIImage(named: "user"), style: .plain, target: self, action: #selector(userDetailPressed))
    
    var reloadButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        tableView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.separatorColor = UIColor(white: 0.2, alpha: 1)
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(ThreadListTableViewCell.classForCoder(), forCellReuseIdentifier: "ThreadListTableViewCell")
        tableView.addGestureRecognizer(longPress)
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
            make.bottom.equalTo(view.snp.bottom).offset(-44)
            make.height.equalTo(50)
        }
        
        navigationController?.isToolbarHidden = false
        navigationController?.navigationBar.barStyle = .black
        navigationController?.toolbar.barStyle = .black
        navigationController?.toolbar.tintColor = .white
        navigationController?.navigationBar.tintColor = .white
        toolbarItems = [flexibleSpace,channelSwitch,flexibleSpace,newThread,flexibleSpace,userDetail,flexibleSpace]
        navigationItem.title = HKGaldenAPI.shared.chList![channelNow]["name"].stringValue
        navigationController?.navigationBar.barTintColor = UIColor(hexRGB: HKGaldenAPI.shared.chList![channelNow]["color"].stringValue)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: .bottom)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(refreshControl: )), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
            tableView.addSubview(refreshControl)
        }
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        spinner.startAnimating()
        spinner.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 44)
        tableView.tableFooterView = spinner;
        
        reloadButton.center = self.view.center
        reloadButton.setTitle("重新載入", for: .normal)
        reloadButton.isHidden = true
        reloadButton.addTarget(self, action: #selector(reloadButtonPressed(_:)), for: .touchUpInside)
        
        updateSequence(append: false, completion: {})
    }
    
    @objc func refresh(refreshControl: UIRefreshControl) {
        pageNow = 1
        DispatchQueue.main.asyncAfter(deadline: 1, execute: {
            self.updateSequence(append: false, completion: {
                refreshControl.endRefreshing()
            })
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (adOption.adEnabled == false) {
            adBannerView.removeFromSuperview()
            view.layoutSubviews()
        } else {
            adBannerView.load(GADRequest())
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexRGB: HKGaldenAPI.shared.chList![channelNow]["color"].stringValue)
        let indexPath = tableView.indexPathForSelectedRow
        if indexPath != nil {
            tableView.deselectRow(at: indexPath!, animated: true)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreadListTableViewCell") as! ThreadListTableViewCell
        
        // Configure the cell...
        cell.backgroundColor = UIColor(white: 0.15, alpha: 1)
            let title = self.threads[indexPath.row].title
            var uname = self.threads[indexPath.row].userName
            let count = self.threads[indexPath.row].count
            let rate = self.threads[indexPath.row].rate
            uname = uname.replacingOccurrences(of: "\n", with: "")
        if (self.blockedUsers.contains(self.threads[indexPath.row].userID)) {
            cell.threadTitleLabel.text = "[已封鎖]"
            cell.threadTitleLabel.textColor = .darkGray
            cell.detailLabel.isHidden = true
        } else {
            cell.threadTitleLabel.text = title
            cell.threadTitleLabel.textColor = .lightGray
            cell.detailLabel.isHidden = false
            cell.detailLabel.text = "\(uname) // 回覆: \(count) // 評分: \(rate)"
            cell.detailLabel.textColor = .darkGray
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (blockedUsers.contains(threads[indexPath.row].userID)) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title:"喂喂喂",message:"扑咗就唔好心郁郁",preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:"好囉",style:.cancel,handler:nil))
                self.present(alert,animated: true,completion: nil)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            let contentVC = ContentViewController()
            let selectedThread = threads[indexPath.row].id
            contentVC.threadIdReceived = selectedThread
            contentVC.title = threads[indexPath.row].title
            contentVC.sender = "cell"
            navigationController?.pushViewController(contentVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (threads.count - indexPath.row) == 1 {
            self.pageNow += 1
            DispatchQueue.main.asyncAfter(deadline: 1, execute: {
                self.updateSequence(append: true, completion: {})
            })
        }
    }
    
    @objc func jumpToPage(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
                
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                self.selectedThread = threads[indexPath.row].id
                self.selectedThreadTitle = threads[indexPath.row].title
                self.pageCount = ceil((Double(threads[indexPath.row].count)! + 1)/25)
                let destination = PageSelectViewController()
                destination.pageCount = self.pageCount!
                destination.titleText = self.selectedThreadTitle
                destination.hero.isEnabled = true
                destination.hero.modalAnimationType = .fade
                destination.modalPresentationStyle = .overFullScreen
                destination.mainVC = self
                present(destination, animated: true, completion: nil)
            }
        }
    }
    
    @objc func channelButtonPressed(sender: UIBarButtonItem) {
        let popoverViewController = ChannelSelectViewController()
        popoverViewController.threadListViewController = self
        popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverViewController.popoverPresentationController?.delegate = self
        popoverViewController.popoverPresentationController?.barButtonItem = sender
        present(popoverViewController, animated: true, completion: nil)
    }
    
    @objc func newThreadButtonPressed() {
        let destination = ComposeViewController()
        destination.channel = channelNow
        destination.type = "newThread"
        destination.modalPresentationStyle = .overFullScreen
        destination.hero.isEnabled = true
        destination.hero.modalAnimationType = .fade
        destination.threadVC = self
        present(destination, animated: true, completion: nil)
    }
    
    @objc func userDetailPressed() {
        let destination = UserDetailViewController()
        destination.modalPresentationStyle = .overFullScreen
        destination.hero.isEnabled = true
        destination.hero.modalAnimationType = .fade
        present(destination, animated: true, completion: nil)
    }
    
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
    
    //Unwind Segue
    func unwindToThreadList(channelSelected: Int) {
        self.channelNow = channelSelected
        self.pageNow = 1
        self.navigationItem.title = HKGaldenAPI.shared.chList![channelNow]["name"].stringValue
        self.navigationController?.navigationBar.barTintColor = UIColor(hexRGB: HKGaldenAPI.shared.chList![channelNow]["color"].stringValue)
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
            contentVC.threadIdReceived = self.selectedThread
            contentVC.title = self.selectedThreadTitle
            contentVC.pageNow = self.selectedPage!
            self.navigationController?.pushViewController(contentVC, animated: true)
        }
    }
    
    @objc func reloadButtonPressed(_ sender: UIButton) {
        self.updateSequence(append: false, completion: {})
    }
    
    private func updateSequence(append: Bool, completion: @escaping ()->Void) {
        HKGaldenAPI.shared.fetchThreadList(currentChannel: HKGaldenAPI.shared.chList![channelNow]["ident"].stringValue, pageNumber: String(pageNow), completion: {
            [weak self] threads,blocked,error in
            if (error == nil) {
                if append == true {
                    self?.threads.append(contentsOf: threads)
                } else {
                    self?.threads = threads
                }
                self?.blockedUsers = blocked
                self?.tableView.reloadData()
                self?.reloadButton.isHidden = true
                self?.tableView.isHidden = false
            } else {
                self?.reloadButton.isHidden = false
            }
            completion()
        })
    }
}
