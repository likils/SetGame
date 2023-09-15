//
//  DiamondShape.swift
//  SetGame
//
//  Created by @likils on 15.09.2023.
//  Copyright © 2023 nkolesnikov@hotmail.com. All rights reserved.
//

import SwiftUI

struct DiamondShape: Shape {

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

struct DiamondShape_Previews: PreviewProvider {
    static var previews: some View {
        DiamondShape()
    }
}
