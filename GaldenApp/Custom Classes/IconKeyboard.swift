//
//  IconKeyboard.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 10/11/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit

protocol IconKeyboardDelegate: class {
    func keyWasTapped(character: String)
}

class IconKeyboard: UIView {
    weak var delegate: IconKeyboardDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    
    func initializeSubviews() {
        let xibFileName = "IconKeyboard" // xib extention not included
        let view = Bundle.main.loadNibNamed(xibFileName, owner: self, options: nil)![0] as! UIView
        self.addSubview(view)
        view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 265)
    }
    
    @IBAction func keyTapped(sender: UIButton) {
        switch sender.tag {
        case 0:
            self.delegate?.keyWasTapped(character: "[369] ")
        case 1:
            self.delegate?.keyWasTapped(character: "#adore# ")
        case 2:
            self.delegate?.keyWasTapped(character: "#yup# ")
        case 3:
            self.delegate?.keyWasTapped(character: "O:-) ")
        case 4:
            self.delegate?.keyWasTapped(character: ":-[ ")
        case 5:
            self.delegate?.keyWasTapped(character: "#ass# ")
        case 6:
            self.delegate?.keyWasTapped(character: "[banghead] ")
        case 7:
            self.delegate?.keyWasTapped(character: ":D ")
        case 8:
            self.delegate?.keyWasTapped(character: "[bomb] ")
        case 9:
            self.delegate?.keyWasTapped(character: "[bouncer] ")
        case 10:
            self.delegate?.keyWasTapped(character: "[bouncy] ")
        case 11:
            self.delegate?.keyWasTapped(character: "#bye# ")
        case 12:
            self.delegate?.keyWasTapped(character: "[censored] ")
        case 13:
            self.delegate?.keyWasTapped(character: "#cn# ")
        case 14:
            self.delegate?.keyWasTapped(character: ":o) ")
        case 15:
            self.delegate?.keyWasTapped(character: ":~( ")
        case 16:
            self.delegate?.keyWasTapped(character: "xx( ")
        case 17:
            self.delegate?.keyWasTapped(character: ":-] ")
        case 18:
            self.delegate?.keyWasTapped(character: "#ng# ")
        case 19:
            self.delegate?.keyWasTapped(character: "#fire# ")
        case 20:
            self.delegate?.keyWasTapped(character: "[flowerface] ")
        case 21:
            self.delegate?.keyWasTapped(character: ":-( ")
        case 22:
            self.delegate?.keyWasTapped(character: "fuck ")
        case 23:
            self.delegate?.keyWasTapped(character: "@_@ ")
        case 24:
            self.delegate?.keyWasTapped(character: "#good# ")
        case 25:
            self.delegate?.keyWasTapped(character: "#hehe# ")
        case 26:
            self.delegate?.keyWasTapped(character: "#hoho# ")
        case 27:
            self.delegate?.keyWasTapped(character: "#kill# ")
        case 28:
            self.delegate?.keyWasTapped(character: "#kill2# ")
        case 29:
            self.delegate?.keyWasTapped(character: "^3^ ")
        case 30:
            self.delegate?.keyWasTapped(character: "#love# ")
        case 31:
            self.delegate?.keyWasTapped(character: "#no# ")
        case 32:
            self.delegate?.keyWasTapped(character: "[offtopic] ")
        case 33:
            self.delegate?.keyWasTapped(character: ":O ")
        case 34:
            self.delegate?.keyWasTapped(character: "[photo] ")
        case 35:
            self.delegate?.keyWasTapped(character: "[shocking] ")
        case 36:
            self.delegate?.keyWasTapped(character: "[slick] ")
        case 37:
            self.delegate?.keyWasTapped(character: ":) ")
        case 38:
            self.delegate?.keyWasTapped(character: "[sosad] ")
        case 39:
            self.delegate?.keyWasTapped(character: "#oh# ")
        case 40:
            self.delegate?.keyWasTapped(character: ":P ")
        case 41:
            self.delegate?.keyWasTapped(character: ";-) ")
        case 42:
            self.delegate?.keyWasTapped(character: "?_? ")
        case 43:
            self.delegate?.keyWasTapped(character: "??? ")
        case 44:
            self.delegate?.keyWasTapped(character: "[yipes] ")
        case 45:
            self.delegate?.keyWasTapped(character: "Z_Z ")
        case 46:
            self.delegate?.keyWasTapped(character: "#lol# ")
        default:
            return
        }
    }
}
