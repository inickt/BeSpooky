//
//  NSObject+Extensions.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/23/22.
//

import Foundation

extension NSObject {
    class func swizzle(original originalSelector: Selector, with newSelector: Selector, forClass: AnyClass) {
        let originalMethod = class_getInstanceMethod(forClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(forClass, newSelector)
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
}
