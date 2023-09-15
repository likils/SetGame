//
//  CardView.swift
//  SetGame
//
//  Created by @likils on 15.09.2023.
//  Copyright © 2023 nkolesnikov@hotmail.com. All rights reserved.
//

import SwiftUI

struct CardView: View {

// MARK: - Construction

    init(
        id: Int,
        color: ColorType,
        shading: ShadingType,
        shape: ShapeType
    ) {
        self.id = id
        self.color = color.value
        self.shading = shading
        self.shape = shape.value
    }

// MARK: - Properties

    let id: Int

    private let color: Color
    private let shading: ShadingType
    private let shape: AnyShape

// MARK: - Views

    var body: some View {
        preparedShape
            .padding(8)
            .overlay {
                RoundedRectangle(cornerRadius: Const.cornerRadius)
                    .stroke(.gray, lineWidth: Const.lineWidth)
            }
    }

    @ViewBuilder
    private var preparedShape: some View {
        switch shading {

            case .open:
                shape.stroke(color, lineWidth: Const.lineWidth)

            case .solid:
                shape.fill(color)

            case .striped:
                shape.strip(color, lineWidth: Const.lineWidth)
        }
    }

// MARK: - Inner Types

    private enum Const {
        static let cornerRadius: CGFloat = 16.0
        static let lineWidth: CGFloat = 3.0
    }
}

struct Card_Previews: PreviewProvider {
    static var previews: some View {
        CardView(
            id: 0,
            color: .red,
            shading: .striped,
            shape: .squiggle
        )
        .padding(10)
    }
}
