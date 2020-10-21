//
//  Card.swift
//  SetGame
//
//  Created by Nik on 20.10.2020.
//  Copyright © 2020 Nik. All rights reserved.
//

import Foundation

struct Card: Hashable { 
    // TODO: Create model
    var content: CardContent
    var isSelected = false
    var isMatched = false
    var identifier: Int
    
    init(id: Int, numberOfShapes: Int, shapeType: String, shading: String, shapeColor: String) {
        identifier = id
        content = CardContent(numberOfShapes: numberOfShapes, shapeType: shapeType, shading: shading, shapeColor: shapeColor)
    }
    
    struct CardContent: Hashable {
        var numberOfShapes: Int
        var shapeType: String
        var shading: String
        var shapeColor: String
    }
    
}
