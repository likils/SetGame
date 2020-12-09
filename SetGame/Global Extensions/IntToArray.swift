//
//  IntToArray.swift
//  SetGame
//
//  Created by Nik on 25.10.2020.
//  Copyright © 2020 Nik. All rights reserved.
//

import Foundation

extension Int {
    var digits: [Int] {
        String(self).compactMap { Int(String($0)) }
    }
}
