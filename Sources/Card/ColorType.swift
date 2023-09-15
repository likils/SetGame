//
//  ColorType.swift
//  SetGame
//
//  Created by @likils on 15.09.2023.
//  Copyright © 2023 nkolesnikov@hotmail.com. All rights reserved.
//

import SwiftUI

enum ColorType: Int, CaseIterable {
    case green
    case purple
    case red

    var value: Color {
        switch self {
            case .green:
                return .green
            case .purple:
                return .purple
            case .red:
                return .red
        }
    }
}
