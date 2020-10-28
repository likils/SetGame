//
//  SetGame.swift
//  SetGame
//
//  Created by Nik on 20.10.2020.
//  Copyright © 2020 Nik. All rights reserved.
//

import Foundation

struct SetGame {
    private struct Card: Equatable {
        var content: Int
        var onTable = false
        var isSelected = false
        var isMatched = false
    }
    
    // MARK: - Properties
    private var cardDeck = [Card]()
    
    var cardDeckIsEmpty: Bool {
        cardDeck.filter{!$0.onTable && !$0.isMatched}.isEmpty
    }
    var selectedCards: [Int] {
        cardDeck.filter{$0.isSelected}.map{$0.content}
    }
    
    // MARK: - Cards movement
    mutating func putCardOnTable() -> Int {
        let card = cardDeck.filter{!$0.onTable && !$0.isMatched}.first!
        let index = cardDeck.firstIndex(of: card)!
        cardDeck[index].onTable = true
        return card.content
    }
    mutating func selectCard(withContent content: Int) -> Bool {
        let card = cardDeck.filter{ $0.content == content }.first!
        let index = cardDeck.firstIndex(of: card)!
        cardDeck[index].isSelected = !cardDeck[index].isSelected
        return cardDeck[index].isSelected
    }
    mutating func deselectCards() {
        let cards = selectedCards
        cards.forEach{let _ = selectCard(withContent: $0)}
    }
    mutating func removeCardsFromTable() {
        let cards = selectedCards
        cards.forEach { tag in
            let card = cardDeck.filter{ $0.content == tag }.first!
            let index = cardDeck.firstIndex(of: card)!
            cardDeck[index].isMatched = true
            cardDeck[index].onTable = false
        }
    }

    // MARK: - Matches
    func findMatches() -> [Int]? {
        let cardsOnTable = cardDeck.filter{$0.onTable}.map{$0.content}
        var selectedCards = [Int]()
        for i1 in (0..<cardsOnTable.count-2) {
            selectedCards.insert(cardsOnTable[i1], at: 0)
            
            for i2 in (1..<cardsOnTable.count-1) {
                selectedCards.insert(cardsOnTable[i2], at: 1)
                if selectedCards[0] == selectedCards[1] { selectedCards.remove(at: 1); continue }
                
                for i3 in (2..<cardsOnTable.count) {
                    selectedCards.insert(cardsOnTable[i3], at: 2)
                    if selectedCards[0] == selectedCards[2] || selectedCards[1] == selectedCards[2] { selectedCards.remove(at: 2); continue }
                    if cardsMatched(cards: selectedCards) {
                        return selectedCards
                    }
                    selectedCards.remove(at: 2)
                }
                selectedCards.remove(at: 1)
            }
            selectedCards.remove(at: 0)
        }
        return nil
    }
    
    func cardsMatched(cards tags: [Int]) -> Bool {
        let card1 = tags[0].digits
        let card2 = tags[1].digits
        let card3 = tags[2].digits
        for i in 0..<card1.count {
            if !((card1[i]+card2[i]+card3[i])%3==0) {
                return false
            }
        }
        return true
    }
    
    // MARK: - Init
    init(cardDeck content: [Int]) {
        content.forEach{ cardDeck.append(Card(content: $0)) }
    }
}
