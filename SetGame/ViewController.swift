//
//  ViewController.swift
//  SetGame
//
//  Created by Nik on 19.10.2020.
//  Copyright © 2020 Nik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var cardSet: CardSet = {
        let cardSet = CardSet()
        cardSet.cardsByTag.values.forEach { view in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            view.addGestureRecognizer(tapGesture)
        }
        return cardSet
    }()
    
    private var grid: Grid!
    
    private var setGame: SetGame!
    private var cardsOnTable: [Int] {
        setGame.cardsOnTable
    }
    private var cardDeckIsEmpty: Bool {
        setGame.cardDeckIsEmpty
    }
    private var selectedCards: [Int] {
        setGame.selectedCards
    }

    private var totalScore = 0 {
        didSet { title = "Score: \(totalScore)" }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New Game", style: .plain, target: self, action: #selector(createNewGame))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Get 3 cards", style: .plain, target: self, action: #selector(addThreeCards))
        navigationController?.isToolbarHidden = false
        let cheatButton = UIBarButtonItem(title: "Find 3 cards", style: .done, target: self, action: #selector(cheat))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [spacer, cheatButton, spacer]
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(addThreeCards))
        swipeGesture.direction = .up
        view.addGestureRecognizer(swipeGesture)
        let shuffleGesture = UIRotationGestureRecognizer(target: self, action: #selector(shuffleCardsByGesture))
        view.addGestureRecognizer(shuffleGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createNewGame()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        redrawUI()
    }
    
    // MARK: - Action methods
    @objc func createNewGame() {
        totalScore = 0
        var cards = [Int]()
        cardSet.cardsByTag.keys.forEach{ cards.append($0) }
        setGame = SetGame(cardDeck: cards.shuffled())
        setGame.createNewGame()
        redrawUI()
        navigationItem.rightBarButtonItem?.isEnabled = true
        toolbarItems![1].isEnabled = true
    }
    
    @objc func addThreeCards() {
        setGame.putThreeCardsOnTable()
        redrawUI()
        if cardDeckIsEmpty {navigationItem.rightBarButtonItem?.isEnabled = false}
    }
    
    @objc func shuffleCardsByGesture(_ sender: UIRotationGestureRecognizer) {
        switch sender.state {
            case .ended:
                setGame.shuffleCards()
                redrawUI()
            default: return
        }
    }
    
    @objc func cheat() {
        drawCardBorderColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), forCards: selectedCards)
        setGame.deselectCards()
        if let findedCards = setGame.findMatches() {
            drawCardBorderColor(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), forCards: findedCards)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [unowned self] in
                self.drawCardBorderColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), forCards: findedCards)
            }
            return
        }
        let controllerTitle: String
        let controllerMessage: String?
        let actionTitle: String
        if !cardDeckIsEmpty {
            controllerTitle = "Not found any matches!"
            controllerMessage = "Maybe get 3 extra cards?"
            actionTitle = "Get cards"
        } else {
            controllerTitle = "Game is over!\nYour score is: \(totalScore)"
            controllerMessage = nil
            actionTitle = "New Game"
            toolbarItems![1].isEnabled = false
        }
        let alertController = UIAlertController(title: controllerTitle, message: controllerMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default) { [unowned self] _ in
            self.cardDeckIsEmpty ? self.createNewGame() : self.addThreeCards()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(action)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func cardTapped(_ sender: UITapGestureRecognizer) {
        let card = sender.view!
        switch setGame.cardIsSelected(withContent: card.tag) {
            case false:
                card.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
            case true:
                card.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1).cgColor
                matchCards()
        }
    }
    
    // MARK: - Helper methods
    private func matchCards() {
        guard selectedCards.count == 3 else { return }
        if setGame.cardsMatched(cards: selectedCards) {
            drawCardBorderColor(#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), forCards: selectedCards)
            setGame.removeMatchedCardsFromTable()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
                self.drawCardBorderColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), forCards: self.selectedCards)
                if self.cardDeckIsEmpty {
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    if self.setGame.findMatches() == nil { self.cheat() }
                } else if self.cardsOnTable.count < 12 {
                    self.setGame.putThreeCardsOnTable()
                }
                self.redrawUI()
                self.totalScore += 1
                self.setGame.deselectCards()
            }
        } else {
            drawCardBorderColor(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), forCards: selectedCards)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
                self.drawCardBorderColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), forCards: self.selectedCards)
                self.setGame.deselectCards()
            }
        }
    }

    private func drawCardBorderColor(_ color: UIColor, forCards cards: [Int]) {
        cards.forEach {
            view.viewWithTag($0)!.layer.borderColor = color.cgColor
        }
    }
    
    private func redrawUI() {
        view.subviews.forEach {
            $0.removeFromSuperview()
            $0.removeConstraint($0.constraints.last!)
            $0.removeConstraint($0.constraints.last!)
        }
        grid = Grid(layout: Grid.Layout.aspectRatio(0.655), frame: view.safeAreaLayoutGuide.layoutFrame)
        grid.cellCount = cardsOnTable.count
        
        cardsOnTable.enumerated().forEach {
            let card = cardSet.cardsByTag[$1]!
            view.addSubview(card)
            NSLayoutConstraint.activate([
                card.topAnchor.constraint(equalTo: view.topAnchor, constant: grid[$0]!.origin.y + 2),
                card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: grid[$0]!.origin.x + 2),
                card.widthAnchor.constraint(equalToConstant: grid[$0]!.size.width - 4),
                card.heightAnchor.constraint(equalToConstant: grid[$0]!.size.height - 4)
            ])
        }
    }
}

