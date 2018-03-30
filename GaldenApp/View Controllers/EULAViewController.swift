//
//  EULAViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 7/11/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import Hero
import SnapKit

class EULAViewController: UIViewController {

    let eulaLabel = UILabel()
    let eulaContent = UITextView()
    let nextButton = UIButton()
    let eulaContentText = "瞭解及接受條款\n歡迎使用香港膠登 HKGalden 服務。以下是香港膠登 HKGalden 服務條款(下稱「服務條款」)，本站會按照條款，為用戶提供服務。本站可能會隨時修訂條款而無需通知用戶。修訂的服務條款將於公開張貼起即時生效，並取代舊有的條款。當用戶使用特定的香港膠登 HKGalden 服務時，本站與用戶雙方均須遵守為特定服務而公開張貼的指引及規則(會不時重新張貼)。這些指引和規則均構成本服務條款的一部分。用戶有義務了解條款所有內容之外也必須同意本服務才能使用本服務。歡迎使用香港膠登 HKGalden (下稱「本站」)服務。以下是香港膠登 HKGalden 服務條款(下稱「本服務條款」)，本站會按照條款，為用戶提供線上討論區服務(下稱「本服務」)。任何人在本站註冊成為會員後，即表示已閱讀、了解並同意接受本服務條款內的所有內容。本站有權於任何時間修改或變更本服務條款內容，惟在每次修訂後須發帖公告。修訂的服務條款將於公開張貼起即時生效，並即時取代舊有的條款。當用戶使用特定的香港膠登 HKGalden 服務時，本站與用戶雙方均須遵守為特定服務而公開張貼的指引及規則(會不時重新張貼)。這些指引和規則均構成本服務條款的一部分。若任何人不同意本服務條款內的內容，應立即停止使用本站提供的任何服務。\n\n本站與本站管理者\n本站管理團隊(下稱「管理團隊」)由管理員組成，為本站最高管理者，已得授權代表本站，亦有權管理本站會員帳戶資料及網站運作。\n\n本站及本服務名稱\n在管理團隊的管理下，若本站或本服務的名稱有任何變更，本服務條款在另一名稱的網站或服務將保持有效，所有對應於「香港膠登HKGalden」的內容將直接適用於另一名稱的網站或服務，惟管理團隊須立即修訂本服務條款，修正當中有關的名稱。\n\n服務說明\n本站為會員提供線上討論區服務及其他未來可能新增的其他服務。本站服務所涉及的網域名稱、網路位址、功能及會員權利等，均是為本站管理團隊所持有，會員有使用服務期間不得將其出租、外借或轉讓予第三者。本服務是依當時情況及狀態提供，本站有權隨時增加、修改或刪除本服務當中的任何系統或功能，亦有權隨時變更會員在使用服務時享有的權利，而無須另行通知。\n\n廣告\n本服務可能包含廣告，而這些廣告是本站為提供本服務所必須的，任何會員無權選擇不接收。\n\n使用問題免責條款\n本服務可能會出現中斷或故障，可能令會員使用本服務時遭到資料喪失。在任何情況下，對於任何會員在本站遇到的資料喪失問題及其可能衍生到的其他損失，本站均不予負責。\n\n帖文操作授權\n任何帖文內容一經上傳或提供到本站後，管理團隊有權使用、刪除或修改一切內容。\n\n會員帳戶及私隱\n本站重視資料保密原則，承諾不會將會員的註冊與登記資料外泄或提供予第三者。\n\n帳號及密碼的安全\n確保帳號和密碼的安全是會員自身的責任。利用該帳號所進行的一切行為，會員須對此完全負責。若用戶的帳號或密碼遭到未獲授權的使用或其他安全性問題，請立即通知 admins@hkgalden.com 。若未能遵守本項規定所衍生之任何損失或損害，本站將不予負責。\n\n帳戶政策\n除已取得特殊豁免外，任何用戶只可註冊或持有一個帳戶，當中包括已被封鎖的帳戶，並最多只能以一個帳戶使用本服務。本站任何帳戶均不得轉讓、外借或出售，會員亦不得向他人借用帳戶以使用本服務。若有任何用戶以多於一個帳戶使用本服務，本站有權封鎖其所有帳戶，亦有權公開其所有帳戶的會員名稱或會員編號。對於因此與對用戶造成的任何損失或損害，本站一概不負責。\n\n用戶行為\n用戶同意遵守並維護本站的內務方案及機制，包括但不限於版規、公投法和內務長制度。任何違反版規的行為均由會員組成的內務團體負責，但本站管理團隊擁有最終決定權，亦有權凌駕所有內務方案推翻內務團隊一切決定。\n\n用戶留言免責條款\n本服務是以即時上載留言的方式運作，本站對所有留言的真實性、完整性及立場等，均不會負上任何法律責任。會員的一切留言只代表留言者個人意見，並非本網站之立場。\n若用戶在使用本服務時作出任何引致法律問題的行為，本站並不會為此負上任何法律責任，並有權移除任何引致法律問題的貼文或留言。\n\n服務之修改\n本站有權於任何時間對本服務或其任何部分作出暫時或永久修改，亦有權隨時終止提供本服務。不論有否預先通知，本站對於用戶或任何第三人因本服務更變而可能招至的損害或損失均不負責。"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hero.isEnabled = true
        hero.modalAnimationType = .auto
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        
        eulaLabel.text = "香港膠登 HKGalden 使用條款及免責聲明"
        eulaLabel.textColor = .white
        eulaLabel.numberOfLines = 0
        eulaLabel.hero.modifiers = [.position(CGPoint(x:eulaLabel.frame.midX,y:-50))]
        view.addSubview(eulaLabel)
        
        eulaContent.text = eulaContentText
        eulaContent.textColor = .white
        eulaContent.backgroundColor = .clear
        eulaContent.hero.modifiers = [.fade,.scale(0.5)]
        view.addSubview(eulaContent)
        
        nextButton.hero.id = "button"
        nextButton.layer.cornerRadius = 5
        nextButton.backgroundColor = UIColor(rgb: 0x0076ff)
        nextButton.setTitle("繼續", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        view.addSubview(nextButton)
        
        eulaLabel.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(25)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
        }
        eulaContent.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(eulaLabel.snp.bottom).offset(10)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
        }
        
        nextButton.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(eulaContent.snp.bottom).offset(10)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.bottom.equalTo(-10)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func nextButtonPressed() {
        present(FirstLoginViewController(), animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
