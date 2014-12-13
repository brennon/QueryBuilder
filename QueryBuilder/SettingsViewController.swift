//
//  SettingsViewController.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 12/4/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

//extension UIView {
//    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
//        return UINib(
//            nibName: nibNamed,
//            bundle: bundle
//            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
//    }
//}

class SettingsViewController: UIViewController {
    
}

class SettingsViewPopoverController: UIPopoverController {
    override init() {
        
        let settingsViewController = SettingsViewController(nibName: "SettingsView", bundle: NSBundle.mainBundle())
        
        super.init(contentViewController: settingsViewController)
    }
}
