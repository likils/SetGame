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
    
    private var cardDeck = [Card]()
    
    // MARK: - Cards position
    var cardsOnTable: [Int] {
        cardDeck.filter{$0.onTable}.map{$0.content}
    }
    var selectedCards: [Int] {
        cardDeck.filter{$0.isSelected}.map{$0.content}
    }
    var cardDeckIsEmpty: Bool {
        cardDeck.filter{!$0.onTable && !$0.isMatched}.isEmpty
    }
    
    // MARK: - Cards movement
    mutating func createNewGame() {
        for index in 0..<12 { cardDeck[index].onTable = true }
    }
    
    mutating func shuffleCards() {
        cardDeck.shuffle()
    }
    
    mutating func putThreeCardsOnTable() {
        guard !cardDeckIsEmpty else { return }
        for _ in 0..<3 {
            let card = cardDeck.filter{!$0.onTable && !$0.isMatched}.first!
            let index = cardDeck.firstIndex(of: card)!
            cardDeck[index].onTable = true
        }
    }
    
    mutating func cardIsSelected(withContent content: Int) -> Bool {
        let card = cardDeck.filter{ $0.content == content }.first!
        let index = cardDeck.firstIndex(of: card)!
        cardDeck[index].isSelected = !cardDeck[index].isSelected
        return cardDeck[index].isSelected
    }
    
    mutating func deselectCards() {
        selectedCards.forEach { let _ = cardIsSelected(withContent: $0) }
    }
    
    mutating func removeMatchedCardsFromTable() {
        selectedCards.forEach { content in
            let card = cardDeck.filter{ $0.content == content }.first!
            let index = cardDeck.firstIndex(of: card)!
            cardDeck[index].isMatched = true
            cardDeck[index].onTable = false
        }
    }

    // MARK: - Matches
    func findMatches() -> [Int]? {
        guard cardsOnTable.count > 2 else { return nil }
        for i1 in (0..<cardsOnTable.count-2) {
            for i2 in (1..<cardsOnTable.count-1) {
                if cardsOnTable[i1] == cardsOnTable[i2] { continue }
                
                for i3 in (2..<cardsOnTable.count) {
                    if cardsOnTable[i1] == cardsOnTable[i3] || cardsOnTable[i2] == cardsOnTable[i3] { continue }
                    
                    let findedCards = [cardsOnTable[i1], cardsOnTable[i2], cardsOnTable[i3]]
                    if cardsMatched(cards: findedCards) {
                        return findedCards
                    }
                }
            }
        }
        return nil
    }
    
    func cardsMatched(cards tags: [Int]) -> Bool {
        let card1 = tags[0].digits
        let card2 = tags[1].digits
        let card3 = tags[2].digits
        for i in 0..<card1.count {
            if (card1[i] + card2[i] + card3[i]) % 3 != 0 {
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
