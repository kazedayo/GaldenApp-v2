//
//  ThreadListViewController.swift
//  
//
//  Created by Kin Wa Lam on 7/10/2017.
//

import UIKit
import KeychainSwift
import SideMenu
import PKHUD
import GoogleMobileAds
import GradientLoadingBar
import CRRefresh

class ThreadListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,GADBannerViewDelegate {
    
    //MARK: Properties
    var threads = [ThreadList]()
    var channelNow: String?
    var pageNow: String?
    var pageCount: Double?
    var selectedThread: String!
    var blockedUsers = [String]()
    var selectedPage: Int?
    var selectedThreadTitle: String!
    var adTest = false
    var navigationLoadingBar: BottomGradientLoadingBar?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adBannerView: GADBannerView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        addPullToRefresh()
        adBannerView.adUnitID = "ca-app-pub-6919429787140423/1613095078"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        if (adTest == false) {
            heightConstraint.constant = 0
            adBannerView.layoutIfNeeded()
        } else {
            adBannerView.load(GADRequest())
        }
        
        if let navigationBar = navigationController?.navigationBar {
            navigationLoadingBar = BottomGradientLoadingBar(onView: navigationBar)
        }
        navigationLoadingBar?.show()
        
        let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! UISideMenuNavigationController
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        let menuRightNavigationController = storyboard!.instantiateViewController(withIdentifier: "RightMenuNavigationController") as! UISideMenuNavigationController
        SideMenuManager.default.menuRightNavigationController = menuRightNavigationController
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        channelNow = "bw"
        pageNow = "1"
        self.navigationItem.title = HKGaldenAPI.shared.channelNameFunc(ch: channelNow!)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = HKGaldenAPI.shared.channelColorFunc(ch: self.channelNow!).as1ptImage()
        HKGaldenAPI.shared.fetchThreadList(currentChannel: channelNow!, pageNumber: pageNow!, completion: {
            [weak self] threads,blocked,error in
            if (error == nil) {
                self?.threads = threads!
                self?.blockedUsers = blocked!
                self?.tableView.reloadData()
                self?.navigationLoadingBar?.hide()
            } else {
                self?.navigationLoadingBar?.hide()
                HUD.flash(.error)
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.shadowImage = HKGaldenAPI.shared.channelColorFunc(ch: self.channelNow!).as1ptImage()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreadListTableViewCell", for: indexPath) as! ThreadListTableViewCell
        
        // Configure the cell...
        let queue = SerialOperationQueue()
        queue.cancelAllOperations()
        let operation = BlockOperation()
        operation.addExecutionBlock {
            [weak operation] in
            let title = self.threads[indexPath.row].title
            var uname = self.threads[indexPath.row].userName
            let count = self.threads[indexPath.row].count
            let rate = self.threads[indexPath.row].rate
            uname = uname.replacingOccurrences(of: "\n", with: "")
            DispatchQueue.main.async {
                if let operation = operation, operation.isCancelled { return }
                if (self.blockedUsers.contains(self.threads[indexPath.row].userID)) {
                    cell.threadTitleLabel.text = "[已封鎖]"
                    cell.threadTitleLabel.textColor = .darkGray
                    cell.detailLabel.text = "//unknown identity//"
                } else {
                    cell.threadTitleLabel.text = title
                    cell.threadTitleLabel.textColor = .lightGray
                    cell.detailLabel.text = "\(uname) 回覆: \(count) 評分: \(rate)"
                }
            }
        }
        queue.addOperation(operation)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (blockedUsers.contains(threads[indexPath.row].userID)) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title:"喂喂喂",message:"扑咗就唔好心郁郁",preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:"好囉",style:.cancel,handler:nil))
                self.present(alert,animated: true,completion: nil)
            }
        } else {
            let cell = tableView.cellForRow(at: indexPath)
            self.performSegue(withIdentifier: "GoToPost", sender: cell)
        }
    }
    
    @IBAction func jumpToPage(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
                
            let touchPoint = sender.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                self.selectedThread = threads[indexPath.row].id
                self.selectedThreadTitle = threads[indexPath.row].title
                self.pageCount = ceil(Double(threads[indexPath.row].count)!/25)
                self.performSegue(withIdentifier: "pageSelect", sender: sender)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "GoToPost":
            guard let contentViewController = segue.destination as? ContentViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            if (sender is ThreadListTableViewCell) {
                let selectedThreadCell = sender as? ThreadListTableViewCell
                let indexPath = tableView.indexPath(for: selectedThreadCell!)
                let selectedThread = threads[(indexPath?.row)!].id
                contentViewController.threadIdReceived = selectedThread
                contentViewController.title = threads[(indexPath?.row)!].title
                contentViewController.sender = "cell"
                contentViewController.navigationLoadingBar = self.navigationLoadingBar
            }
            else {
                contentViewController.threadIdReceived = selectedThread
                contentViewController.title = selectedThreadTitle
                contentViewController.pageNow = self.selectedPage!
                contentViewController.navigationLoadingBar = self.navigationLoadingBar
            }
        case "StartNewPost":
            let destination = segue.destination as! ComposeViewController
            destination.channel = channelNow!
            destination.type = "newThread"
        case "pageSelect":
            let destination = segue.destination as! PageSelectViewController
            destination.type = "threadList"
            destination.pageCount = self.pageCount!
            destination.titleText = self.selectedThreadTitle
        default:
            break
        }
    }
    
    //Unwind Segue
    @IBAction func unwindToThreadList(segue: UIStoryboardSegue) {
        let channelSelectViewController = segue.source as! ChannelSelectViewController
        self.channelNow = channelSelectViewController.channelSelected
        self.pageNow = "1"
        self.navigationItem.title = HKGaldenAPI.shared.channelNameFunc(ch: channelNow!)
        self.navigationController?.navigationBar.shadowImage = HKGaldenAPI.shared.channelColorFunc(ch: self.channelNow!).as1ptImage()
        self.navigationLoadingBar?.show()
        HKGaldenAPI.shared.fetchThreadList(currentChannel: channelNow!, pageNumber: pageNow!, completion: {
            [weak self] threads,blocked,error in
            if (error == nil) {
                self?.threads = threads!
                self?.blockedUsers = blocked!
                self?.tableView.reloadData()
                self?.navigationLoadingBar?.hide()
                self?.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
            } else {
                self?.navigationLoadingBar?.hide()
                HUD.flash(.error)
            }
        })
    }
    
    @IBAction func unwindToThreadListAfterNewPost(segue: UIStoryboardSegue) {
        HUD.flash(.success)
        self.navigationLoadingBar?.show()
        HKGaldenAPI.shared.fetchThreadList(currentChannel: channelNow!, pageNumber: pageNow!, completion: {
            [weak self] threads,blocked,error in
            if (error == nil) {
                self?.threads = threads!
                self?.blockedUsers = blocked!
                self?.tableView.reloadData()
                self?.navigationLoadingBar?.hide()
            } else {
                self?.navigationLoadingBar?.hide()
                HUD.flash(.error)
            }
        })
    }
    
    @IBAction func unwindAfterPageSelect(segue: UIStoryboardSegue) {
        let source = segue.source as! PageSelectViewController
        self.selectedPage = source.pageSelected
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "GoToPost", sender: self)
        }
    }
    
    func addPullToRefresh() {
        tableView.cr.addHeadRefresh(animator: FastAnimator.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50), color: .darkGray, arrowColor: .lightGray, lineWidth: 1)) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.pageNow = "1"
            HKGaldenAPI.shared.fetchThreadList(currentChannel: (self?.channelNow)!, pageNumber: (self?.pageNow)!, completion: {
                [weak self] threads,blocked,error in
                if (error == nil) {
                    self?.threads = threads!
                    self?.blockedUsers = blocked!
                    self?.tableView.reloadData()
                    self?.tableView.cr.endHeaderRefresh()
                } else {
                    self?.navigationLoadingBar?.hide()
                    HUD.flash(.error)
                    self?.tableView.cr.endHeaderRefresh()
                }
            })
        }
        
        tableView.cr.addFootRefresh(animator: FastAnimator.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50), color: .darkGray, arrowColor: .lightGray, lineWidth: 1)) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.pageNow = String(Int((self?.pageNow!)!)! + 1)
            HKGaldenAPI.shared.fetchThreadList(currentChannel: (self?.channelNow)!, pageNumber: (self?.pageNow)!, completion: {
                [weak self] threads,blocked,error in
                if (error == nil) {
                    self?.threads.append(contentsOf: threads!)
                    self?.blockedUsers = blocked!
                    self?.tableView.reloadData()
                    self?.tableView.cr.endLoadingMore()
                } else {
                    self?.navigationLoadingBar?.hide()
                    HUD.flash(.error)
                    self?.tableView.cr.endLoadingMore()
                }
            })
        }
    }
}
