//
//  MainStackView.swift
//  SetGame
//
//  Created by Nik on 22.10.2020.
//  Copyright © 2020 Nik. All rights reserved.
//

import UIKit

class MainStackView: UIStackView {
    
    private var cardTag = 100
    private var hStackTag = 10
    
    private(set) var cards = [UIButton]()
    private(set) var hStacks = [UIStackView]()
    
    // MARK: - Create UI
    private var card: UIButton {
        let card = UIButton()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.tag = cardTag
        cardTag += 1
        card.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        card.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        card.layer.borderWidth = 3.0
        card.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        card.layer.cornerRadius = 15.0
        return card
    }
    
    private var hStack: UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.tag = hStackTag
        hStackTag += 1
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }

    private func createAllCards() {
        for index in 0..<8 {
            for _ in 0..<3 {
                cards.append(card)
            }
            let hStack = self.hStack
            hStack.addArrangedSubview(cards[index*3])
            hStack.addArrangedSubview(cards[index*3+1])
            hStack.addArrangedSubview(cards[index*3+2])
            hStacks.append(hStack)
        }
        hStacks.forEach(addArrangedSubview(_:))
    }
    
    func hideExtraCards() {
        hStacks[4].arrangedSubviews.forEach{ $0.isHidden = true }
        hStacks[5].arrangedSubviews.forEach{ $0.isHidden = true }
        hStacks[6].arrangedSubviews.forEach{ $0.isHidden = true }
        hStacks[7].arrangedSubviews.forEach{ $0.isHidden = true }
        hStacks[4].isHidden = true
        hStacks[5].isHidden = true
        hStacks[6].isHidden = true
        hStacks[7].isHidden = true
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        createAllCards()
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        alignment = .fill
        distribution = .fillEqually
        spacing = 8
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}