//
//  StringExtension.swift
//  Pods
//
//  Created by wayfinder on 2017. 4. 18..
//
//

import Foundation

extension String {
    var hex: Int? {
        return Int(self, radix: 16)
    }
}
