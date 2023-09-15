//
//  ShapeType.swift
//  SetGame
//
//  Created by @likils on 15.09.2023.
//  Copyright © 2023 nkolesnikov@hotmail.com. All rights reserved.
//

import SwiftUI

enum ShapeType: Int, CaseIterable {
    case diamond = 1
    case oval
    case squiggle

    var value: AnyShape {
        switch self {
            case .diamond:
                return AnyShape(DiamondShape())
            case .oval:
                return AnyShape(OvalShape())
            case .squiggle:
                return AnyShape(SquiggleShape())
        }
    }
}
