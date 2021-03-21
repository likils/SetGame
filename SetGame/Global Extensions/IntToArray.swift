//
//  IntToArray.swift
//  SetGame
//
//  Created by likils on 25.10.2020.
//  Copyright © 2020 likils. All rights reserved.
//

import Foundation

extension Int {
    var digits: [Int] {
        String(self).compactMap { Int(String($0)) }
    }
}
