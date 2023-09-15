//
//  SquiggleShape.swift
//  SetGame
//
//  Created by @likils on 15.09.2023.
//  Copyright © 2023 nkolesnikov@hotmail.com. All rights reserved.
//

import SwiftUI

struct SquiggleShape: Shape {

    func path(in rect: CGRect) -> Path {
        Path { path in

            path.move(to: CGPoint(x: rect.minX, y: rect.maxY*2/3))
            path.addQuadCurve(to: CGPoint(x: rect.maxX*2/5, y: rect.maxY/4), control: CGPoint(x: rect.minX, y: 1-rect.maxY/5))
            path.addQuadCurve(to: CGPoint(x: rect.maxX*8/10, y: rect.maxY/10), control: CGPoint(x: rect.maxX*3/5, y: rect.maxY*3/7))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY/3), control: CGPoint(x: rect.maxX, y: 1-rect.maxY/6))

            path.addQuadCurve(to: CGPoint(x: rect.maxX*3/5, y: rect.maxY*3/4), control: CGPoint(x: rect.maxX, y: rect.maxY*7/6))
            path.addQuadCurve(to: CGPoint(x: rect.maxX*2/10, y: rect.maxY*9/10), control: CGPoint(x: rect.maxX*2/5, y: rect.maxY*4/7))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY*2/3), control: CGPoint(x: rect.minX, y: rect.maxY*7/6))
            path.closeSubpath()
        }
    }
}

struct SquiggleShape_Previews: PreviewProvider {
    static var previews: some View {
        SquiggleShape()
    }
}
