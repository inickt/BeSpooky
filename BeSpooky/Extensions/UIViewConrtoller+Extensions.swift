//
//  UIViewConrtoller+Extensions.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/22/22.
//

import UIKit

extension UIViewController {
    @objc var swizzle_prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    class func swizzleHomeIndicatorProperty() {
        self.swizzle(
            original: #selector(getter: UIViewController.prefersHomeIndicatorAutoHidden),
            with: #selector(getter: UIViewController.swizzle_prefersHomeIndicatorAutoHidden),
            forClass: UIViewController.self
        )
    }
}
