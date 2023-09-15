//
//  SetGame.swift
//  SetGame
//
//  Created by likils on 20.10.2020.
//  Copyright © 2020 likils. All rights reserved.
//

import Foundation

struct SetGame: Codable {
    private struct Card: Equatable, Codable {
        var content: Int
        var onTable = false
        var isSelected = false
        var isMatched = false
    }
    
    private var cardDeck = [Card]()
    var score = 0
    
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
        saveGame()
    }
    
    mutating func shuffleCards() {
        cardDeck.shuffle()
        saveGame()
    }
    
    mutating func putThreeCardsOnTable() {
        guard !cardDeckIsEmpty else { return }
        for _ in 0..<3 {
            if let card = cardDeck.filter({ !$0.onTable && !$0.isMatched }).first,
               let index = cardDeck.firstIndex(of: card) {
                cardDeck[index].onTable = true
               }
        }
        saveGame()
    }
    
    mutating func isCardSelected(withContent content: Int) -> Bool {
        if let card = cardDeck.filter({ $0.content == content }).first,
           let index = cardDeck.firstIndex(of: card) {
            cardDeck[index].isSelected = !cardDeck[index].isSelected
            saveGame()
            return cardDeck[index].isSelected
        } else {
            return false
        }
    }
    
    mutating func deselectCards() {
        selectedCards.forEach { let _ = isCardSelected(withContent: $0) }
    }
    
    mutating func removeMatchedCardsFromTable() {
        selectedCards.forEach { content in
            if let card = cardDeck.filter({ $0.content == content }).first,
               let index = cardDeck.firstIndex(of: card) {
                cardDeck[index].isMatched = true
                cardDeck[index].onTable = false
            }
        }
        saveGame()
    }

    // MARK: - Matches
    func findMatches() -> [Int]? {
        guard cardsOnTable.count > 2 else { return nil }
        for i1 in (0..<cardsOnTable.count-2) {
            for i2 in (i1+1..<cardsOnTable.count-1) {
                for i3 in (i2+1..<cardsOnTable.count) {
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
    
    // MARK: - Initialization
    init(cardDeck content: [Int]) {
        content.forEach{ cardDeck.append(Card(content: $0)) }
    }
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(SetGame.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    // MARK: - Saving
    static var url: URL? {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("SetGame.json")
        } catch {
            print("Couldn't create URL \(error.localizedDescription)")
            return nil
        }
    }
    
    private var json: Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            print("Could not encode: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func saveGame() {
        if let json = json, let url = SetGame.url {
            do {
                try json.write(to: url)
            } catch {
                print("Couldn't save: \(error.localizedDescription)")
            }
        }
    }
}
