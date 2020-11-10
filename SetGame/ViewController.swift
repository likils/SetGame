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
            let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            pressGesture.minimumPressDuration = 0.01
            view.addGestureRecognizer(pressGesture)
            view.frame.origin = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        }
        return cardSet
    }()
    
    private var grid = Grid(layout: Grid.Layout.aspectRatio(0.655))
    
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
        grid.frame = view.safeAreaLayoutGuide.layoutFrame
        view.subviews.forEach { card in
            card.removeFromSuperview()
            card.removeConstraint(card.constraints.last!)
            card.removeConstraint(card.constraints.last!)
        }
        cardsOnTable.enumerated().forEach { (index, tag) in
            let card = cardSet.cardsByTag[tag]!
            view.addSubview(card)
            NSLayoutConstraint.activate([
                card.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.grid[index]!.origin.y + 2),
                card.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.grid[index]!.origin.x + 2),
                card.widthAnchor.constraint(equalToConstant: self.grid[index]!.size.width - 4),
                card.heightAnchor.constraint(equalToConstant: self.grid[index]!.size.height - 4)
            ])
        }
    }
    
    // MARK: - Action methods
    @objc func createNewGame() {
        totalScore = 0
        var cards = [Int]()
        cardSet.cardsByTag.keys.forEach { cards.append($0) }
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
            findedCards.forEach {
                let card = view.viewWithTag($0)!
                card.transform = CGAffineTransform.identity.scaledBy(x: 0.98, y: 0.98)
                UIView.transition(
                    with: card, duration: 0.4, options: [],
                    animations: { 
                        card.transform = CGAffineTransform.identity.scaledBy(x: 1.04, y: 1.04)
                    },
                    completion: { _ in
                        UIView.transition(
                            with: card, duration: 0.4, options: [],
                            animations: { 
                                card.transform = CGAffineTransform.identity
                            },
                            completion: { _ in
                                self.drawCardBorderColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), forCards: findedCards)
                            }   
                        )
                    }
                )
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
    
    @objc func cardTapped(_ sender: UILongPressGestureRecognizer) {
        guard selectedCards.count < 3 else { return }
        let card = sender.view!
        if sender.state == .began {
            UIView.transition(
                with: card, duration: 0.1, options: [],
                animations: { 
                    card.transform = CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95)
                }
            )
        }
        if sender.state == .ended {
            UIView.transition(
                with: card, duration: 0.1, options: [],
                animations: {
                    switch self.setGame.cardIsSelected(withContent: card.tag) {
                        case false:
                            card.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
                        case true:
                            card.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1).cgColor
                    }
                    card.transform = CGAffineTransform.identity
                }
            )
        }
        matchCards()
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
            selectedCards.forEach { self.view.viewWithTag($0)!.transform = CGAffineTransform(translationX: -3, y: 0) }
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.07, delay: 0, options: [],
                animations: {
                    self.selectedCards.forEach { self.view.viewWithTag($0)!.transform = CGAffineTransform(translationX: 3, y: 0) }
                },
                completion: { _ in
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.07, delay: 0, options: [],
                        animations: {
                            self.selectedCards.forEach { self.view.viewWithTag($0)!.transform = CGAffineTransform(translationX: -3, y: 0) }
                        },
                        completion: { _ in
                            UIViewPropertyAnimator.runningPropertyAnimator(
                                withDuration: 0.07, delay: 0, options: [],
                                animations: {
                                    self.selectedCards.forEach { self.view.viewWithTag($0)!.transform = CGAffineTransform.identity }
                                },
                                completion: { _ in 
                                    self.drawCardBorderColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), forCards: self.selectedCards)
                                    self.setGame.deselectCards()
                                }
                            )
                        }
                    )
                }
            )
        }
    }

    private func drawCardBorderColor(_ color: UIColor, forCards cards: [Int]) {
        cards.forEach {
            view.viewWithTag($0)!.layer.borderColor = color.cgColor
        }
    }
    
    private func redrawUI() {
        grid.frame = view.safeAreaLayoutGuide.layoutFrame
        grid.cellCount = cardsOnTable.count
        
        if selectedCards.count == 3 && view.subviews.count == 12 && !cardDeckIsEmpty {
            let newlyAddedCards = cardsOnTable.filter { view.viewWithTag($0) == nil }
            newlyAddedCards.enumerated().forEach {
                let oldCard = view.viewWithTag(selectedCards[$0])!
                let newCard = cardSet.cardsByTag[$1]!
                let oldCardFrame = oldCard.frame
                
                view.bringSubviewToFront(oldCard)
//                newCard.frame.origin = CGPoint(x: oldCardFrame.midX, y: view.bounds.minY - 100)
                newCard.alpha = 0
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 1.0, delay: 0, options: [],
                    animations: {
                        oldCard.transform = CGAffineTransform.identity.translatedBy(x: -oldCard.frame.origin.x, y: -oldCard.frame.origin.y-100)
                        oldCard.alpha = 0.3
                        
                        self.view.addSubview(newCard)
                        NSLayoutConstraint.activate([
                            newCard.topAnchor.constraint(equalTo: self.view.topAnchor, constant: oldCardFrame.origin.y),
                            newCard.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: oldCardFrame.origin.x),
                            newCard.widthAnchor.constraint(equalToConstant: oldCardFrame.size.width),
                            newCard.heightAnchor.constraint(equalToConstant: oldCardFrame.size.height)
                        ])
                    },
                    completion: {_ in
                        UIViewPropertyAnimator.runningPropertyAnimator(
                            withDuration: 1.0, delay: 0, options: [.transitionFlipFromLeft],
                            animations: {
//                                self.view.layoutIfNeeded()
//                                newCard.subviews[0].subviews.forEach { $0.setNeedsDisplay() }
                                newCard.alpha = 1
                            },
                            completion: {_ in
                                oldCard.transform = CGAffineTransform.identity
                                oldCard.alpha = 1
                                oldCard.removeFromSuperview()
                                oldCard.removeConstraint(oldCard.constraints.last!)
                                oldCard.removeConstraint(oldCard.constraints.last!)
                            }
                        )
                    }
                )
            }
        } else {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 1.0, delay: 0, options: [],
                animations: {
                    self.view.subviews.forEach { card in
                        if self.selectedCards.count == 3 && self.selectedCards.contains(card.tag) {
                            card.transform = CGAffineTransform.identity.translatedBy(x: -card.frame.origin.x, y: -card.frame.origin.y-100)
                            card.alpha = 0.3
                        }
                    }
                },
                completion: {_ in
                    self.view.subviews.forEach { card in
                        card.transform = CGAffineTransform.identity
                        card.alpha = 1
                        card.removeFromSuperview()
                        card.removeConstraint(card.constraints.last!)
                        card.removeConstraint(card.constraints.last!)
                    }
                    
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 1.0, delay: 0, options: [],
                        animations: {
                            self.cardsOnTable.enumerated().forEach { (index, tag) in
                                let card = self.cardSet.cardsByTag[tag]!
                                self.view.addSubview(card)
                                self.view.layoutIfNeeded()
                                NSLayoutConstraint.activate([
                                    card.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.grid[index]!.origin.y + 2),
                                    card.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.grid[index]!.origin.x + 2),
                                    card.widthAnchor.constraint(equalToConstant: self.grid[index]!.size.width - 4),
                                    card.heightAnchor.constraint(equalToConstant: self.grid[index]!.size.height - 4)
                                ])
                            }
                            self.view.layoutIfNeeded()
                        },
                        completion: nil
                    )
                }
            )
        }
    }
}


