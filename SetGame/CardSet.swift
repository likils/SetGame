//
//  CardSet.swift
//  SetGame
//
//  Created by Nik on 22.10.2020.
//  Copyright © 2020 Nik. All rights reserved.
//

import UIKit

struct CardSet {
    
    private(set) var cardsByTag = [Int: UIView]()
    
    //MARK: - Create Cards
    private var card: UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        card.layer.borderWidth = 3.0
        card.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        card.layer.cornerRadius = 15.0
        return card
    }
    
    private var symbolStack: UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 4
        return stackView
    }
    
    mutating private func addViewIntoCard(symbolShape: SymbolView.Shape, symbolColor: SymbolView.Color, symbolShading: SymbolView.Shading, symbolQuantity: Int) {
        let symbolStack = self.symbolStack
        for _ in 0..<symbolQuantity {
            let symbol = SymbolView(shape: symbolShape, color: symbolColor, shading: symbolShading)
            symbolStack.addArrangedSubview(symbol)
        }
        let cardTag = Int("\(symbolShape.rawValue)\(symbolColor.rawValue)\(symbolShading.rawValue)\(symbolQuantity)")!
        let card = self.card
        card.tag = cardTag
        card.addSubview(symbolStack)
        NSLayoutConstraint.activate([
            symbolStack.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            symbolStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            symbolStack.widthAnchor.constraint(equalTo: card.widthAnchor, multiplier: 0.7)
        ])
        cardsByTag[cardTag] = card
    }
    
    mutating private func createAllCards() {
        SymbolView.Shape.allCases.forEach { shape in
            SymbolView.Color.allCases.forEach { color in
                SymbolView.Shading.allCases.forEach { shading in
                    (1...3).forEach { number in
                        addViewIntoCard(symbolShape: shape, symbolColor: color, symbolShading: shading, symbolQuantity: number)
                    }
                }
            }
        }
    }
    
    // MARK: - Initialization
    init() {
        createAllCards()
    }
}
