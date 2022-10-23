//
//  UIApplication+Extensions.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/23/22.
//

import UIKit

private let statusBarHiddenKey = "statusBarHidden"

extension UIApplication {
    /// `isStatusBarHidden` is deprecated and `.statusBar(hidden: true)` has problems on iOS 14
    var isStatusBarHiddenHack: Bool {
        get {
            UIApplication.shared.value(forKey: statusBarHiddenKey) as! Bool
        }
        set {
            UIApplication.shared.setValue(newValue, forKey: statusBarHiddenKey)
        }
    }
}
