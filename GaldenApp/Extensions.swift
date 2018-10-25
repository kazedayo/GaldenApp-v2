//
//  Extensions.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 30/10/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import SwiftEntryKit
import Hero
import Apollo

extension String {
    func nsRange(from range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}

extension UIColor {
    
    /// Converts this `UIColor` instance to a 1x1 `UIImage` instance and returns it.
    ///
    /// - Returns: `self` as a 1x1 `UIImage`.
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}

extension DispatchTime: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = DispatchTime.now() + .seconds(value)
    }
}
extension DispatchTime: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = DispatchTime.now() + .milliseconds(Int(value * 1000))
    }
}

class SerialOperationQueue: OperationQueue {
    override init() {
        super.init()
        maxConcurrentOperationCount = 1
    }
}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension UIColor {
    convenience init?(hexRGBA: String?) {
        guard let rgba = hexRGBA, let val = Int(rgba.replacingOccurrences(of: "#", with: ""), radix: 16) else {
            return nil
        }
        self.init(red: CGFloat((val >> 24) & 0xff) / 255.0, green: CGFloat((val >> 16) & 0xff) / 255.0, blue: CGFloat((val >> 8) & 0xff) / 255.0, alpha: CGFloat(val & 0xff) / 255.0)
    }
    convenience init?(hexRGB: String?) {
        guard let rgb = hexRGB else {
            return nil
        }
        self.init(hexRGBA: rgb + "ff") // Add alpha = 1.0
    }
}

enum NavigationType {
    case normal
    case refresh
    case reply
}

class EntryAttributes {
    static let shared = EntryAttributes()
    
    public func iconEntry() -> EKAttributes {
        var attributes = EKAttributes()
        attributes.position = .top
        attributes.displayPriority = .normal
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.9)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.4)
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.displayDuration = .infinity
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .forward
        attributes.entryBackground = .color(color: UIColor(hexRGB: "#262626")!)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 10, offset: .zero))
        attributes.roundCorners = .all(radius: 10)
        attributes.entranceAnimation = .init(translate: EKAttributes.Animation.Translate.init(duration: 0.25, anchorPosition: .top, delay: 0, spring: EKAttributes.Animation.Spring.init(damping: 1, initialVelocity: 0)), scale: nil, fade: nil)
        attributes.exitAnimation = .init(translate: EKAttributes.Animation.Translate.init(duration: 0.25, anchorPosition: .top, delay: 0, spring: EKAttributes.Animation.Spring.init(damping: 1, initialVelocity: 0)), scale: nil, fade: nil)
        return attributes
    }
    
    public func centerEntry() -> EKAttributes {
        var attributes = EKAttributes()
        attributes.position = .center
        attributes.displayPriority = .normal
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.85)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.constant(value: 500)
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.displayDuration = .infinity
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .forward
        attributes.screenBackground = .visualEffect(style: .dark)
        attributes.entryBackground = .color(color: UIColor(hexRGB: "#262626")!)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 10, offset: .zero))
        attributes.roundCorners = .all(radius: 10)
        attributes.entranceAnimation = .init(translate: EKAttributes.Animation.Translate.init(duration: 0.5, anchorPosition: .bottom, delay: 0, spring: EKAttributes.Animation.Spring.init(damping: 1, initialVelocity: 0)), scale: nil, fade: nil)
        return attributes
    }
    
    public func centerEntryZoom() -> EKAttributes {
        var attributes = EKAttributes()
        attributes.position = .center
        attributes.displayPriority = .normal
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.75)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.constant(value: 300)
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        attributes.displayDuration = .infinity
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .forward
        attributes.screenBackground = .visualEffect(style: .dark)
        attributes.entryBackground = .color(color: UIColor(hexRGB: "#262626")!)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 10, offset: .zero))
        attributes.roundCorners = .all(radius: 10)
        attributes.entranceAnimation = .init(translate: nil, scale: EKAttributes.Animation.RangeAnimation.init(from: 0.5, to: 1, duration: 0.25), fade: EKAttributes.Animation.RangeAnimation.init(from: 0.5, to: 1, duration: 0.25))
        attributes.exitAnimation = .init(translate: nil, scale: EKAttributes.Animation.RangeAnimation.init(from: 1, to: 0.25, duration: 0.25), fade: EKAttributes.Animation.RangeAnimation.init(from: 1, to: 0.25, duration: 0.25))
        return attributes
    }
    
    public func bottomEntry() -> EKAttributes {
        var attributes = EKAttributes()
        attributes.position = .bottom
        attributes.displayPriority = .normal
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.9)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.constant(value: 200)
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        attributes.positionConstraints.verticalOffset = 20
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.displayDuration = .infinity
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .forward
        attributes.screenBackground = .visualEffect(style: .dark)
        attributes.entryBackground = .color(color: UIColor(hexRGB: "#262626")!)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 10, offset: .zero))
        attributes.roundCorners = .all(radius: 10)
        attributes.entranceAnimation = .init(translate: EKAttributes.Animation.Translate.init(duration: 0.5, anchorPosition: .bottom, delay: 0, spring: EKAttributes.Animation.Spring.init(damping: 1, initialVelocity: 0)), scale: nil, fade: nil)
        return attributes
    }
    
    public func loginEntry() -> EKAttributes {
        var attributes = EKAttributes()
        attributes.position = .center
        attributes.displayPriority = .normal
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.8)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.8)
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.displayDuration = .infinity
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .forward
        attributes.screenBackground = .visualEffect(style: .dark)
        attributes.entryBackground = .color(color: UIColor(hexRGB: "#262626")!)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 10, offset: .zero))
        attributes.roundCorners = .all(radius: 10)
        attributes.entranceAnimation = .init(translate: nil, scale: EKAttributes.Animation.RangeAnimation.init(from: 0.5, to: 1, duration: 0.25), fade: EKAttributes.Animation.RangeAnimation.init(from: 0.5, to: 1, duration: 0.25))
        attributes.exitAnimation = .init(translate: nil, scale: EKAttributes.Animation.RangeAnimation.init(from: 1, to: 0.5, duration: 0.25), fade: EKAttributes.Animation.RangeAnimation.init(from: 1, to: 0.5, duration: 0.25))
        return attributes
    }
    
}

class Configurations {
    static let shared = Configurations()
    
    func configureUI() -> UITabBarController {
        let tabBarController = UITabBarController()
        let threadListViewController = ThreadListViewController()
        let settingsTableViewController = SettingsTableViewController.init(style: .grouped)
        let userViewController = UserViewController()
        let loginViewController = LoginViewController()
        threadListViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "posts"), tag: 0)
        userViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "user"), tag: 1)
        settingsTableViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "settings"), tag: 2)
        loginViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "user"), tag: 1)
        if keychain.get("userKey") != nil {
            let controllers = [threadListViewController,userViewController,settingsTableViewController]
            tabBarController.viewControllers = controllers.map { UINavigationController(rootViewController: $0)}
        } else {
            let controllers = [threadListViewController,loginViewController,settingsTableViewController]
            tabBarController.viewControllers = controllers.map { UINavigationController(rootViewController: $0)}
        }
        if UIDevice.current.userInterfaceIdiom == .phone {
            let tabbaritems = tabBarController.tabBar.items!
            for item in tabbaritems {
                item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
            }
        }
        tabBarController.hero.isEnabled = true
        tabBarController.hero.modalAnimationType = .zoom
        return tabBarController
    }
    
    func configureApollo() -> ApolloClient {
        let configuration = URLSessionConfiguration.default
        // Add additional headers as needed
        configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(keychain.get("userKey") ?? "")"] // Replace `<token>`
        
        let url = URL(string: "https://hkgalden.org/_")!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }
}
