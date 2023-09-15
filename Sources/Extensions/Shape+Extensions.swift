//
//  Strip+Shape.swift
//  SetGame
//
//  Created by @likils on 15.09.2023.
//  Copyright © 2023 nkolesnikov@hotmail.com. All rights reserved.
//

import SwiftUI

extension Shape {

    func strip<S>(_ content: S, lineWidth: CGFloat = 1) -> some View where S : ShapeStyle {
        StripShape()
            .stroke(content, lineWidth: lineWidth)
            .clipShape(self)
            .overlay {
                stroke(content, lineWidth: lineWidth)
            }
    }
}

private struct StripShape: Shape {

    func path(in rect: CGRect) -> Path {
        Path { path in
            for step in stride(from: 3, to: Int(rect.width), by: 7) {
                path.move(to: CGPoint(x: CGFloat(step), y: rect.minY))
                path.addLine(to: CGPoint(x: CGFloat(step), y: rect.maxY))
            }
        }
    }
}

struct StripShape_Previews: PreviewProvider {
    static var previews: some View {
        StripShape()
            .stroke(.gray, lineWidth: 3)
    }
}
