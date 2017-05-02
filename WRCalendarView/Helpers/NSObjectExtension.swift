//
//  NSObjectExtenstion.swift
//  Pods
//
//  Created by wayfinder on 2017. 4. 19..
//
//

import Foundation

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
