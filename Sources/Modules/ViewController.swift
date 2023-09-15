//
//  ViewController.swift
//  SetGame
//
//  Created by @likils on 19.10.2020.
//  Copyright © 2020 nkolesnikov@hotmail.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: View properties
    private lazy var cardSet: CardSet = {
        let cardSet = CardSet()
        cardSet.cardsByTag.values.forEach { view in
            let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(cardTapped))
            pressGesture.minimumPressDuration = 0.01
            view.addGestureRecognizer(pressGesture)
            
            view.frame.origin = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY) // for init animation from center of the screen
        }
        return cardSet
    }()
    
    private var grid = CellsGrid(layout: CellsGrid.Layout.aspectRatio(0.655))
    
    // MARK: Model properties
    private var setGame: SetGame!
    private var cardsOnTable: [Int] {
        setGame.cardsOnTable
    }
    private var selectedCards: [Int] {
        setGame.selectedCards
    }
    private var cardDeckIsEmpty: Bool {
        setGame.cardDeckIsEmpty
    }
    private var totalScore: Int {
        get { setGame.score }
        set {
            setGame.score = newValue
            title = "Score: \(totalScore)"
        }
    }

    // MARK: Controller preparation
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .secondarySystemBackground
        } else {
            view.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New Game", style: .plain, target: self, action: #selector(createNewGame))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Get 3 cards", style: .plain, target: self, action: #selector(addThreeCards))
        
        navigationController?.isToolbarHidden = false
        let cheatButton = UIBarButtonItem(title: "Find 3 cards", style: .done, target: self, action: #selector(cheat))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [spacer, cheatButton, spacer]
        
        UIView.appearance().isExclusiveTouch = true // disable cards multiselecting
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.isUserInteractionEnabled = true
        if let url = SetGame.url, let jsonData = try? Data(contentsOf: url) {
            setGame = SetGame(json: jsonData)
            if cardDeckIsEmpty {
                navigationItem.rightBarButtonItem?.isEnabled = false
                if setGame.findMatches() == nil { createNewGame(); return }
            }
            redrawUI()
            title = "Score: \(totalScore)"
        } else {
            createNewGame()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // redraw cards symbols
        cardSet.cardsByTag.values.forEach { card in
            card.subviews[0].subviews.forEach { $0.setNeedsDisplay() }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if setGame == nil {
            return          // bugfix on Mac with m1 (viewWillTransition() calls before viewDidAppear())
        }
        coordinator.animate(
            alongsideTransition: { _ in
            self.setupGrid()
            self.view.subviews.forEach { self.removeCardConstraints(forCard: $0) }
            self.createCardsConstraints()
            }
        )
    }
    
    // MARK: - Action methods
    @objc func createNewGame() {
        view.isUserInteractionEnabled = true
        toolbarItems?[1].isEnabled = false
        var cards = [Int]()
        cardSet.cardsByTag.keys.forEach { cards.append($0) }
        cardSet.cardsByTag.values.forEach { $0.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor }
        setGame = SetGame(cardDeck: cards.shuffled())
        setGame.createNewGame()
        totalScore = 0
        redrawUI()
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    @objc func addThreeCards() {
        toolbarItems?[1].isEnabled = false
        totalScore -= 1
        putThreeCardsOnTable()
        redrawUI()
    }
    
    @objc func cheat() {
        toolbarItems?[1].isEnabled = false
        view.isUserInteractionEnabled = false
        drawCardBorderColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), forCards: selectedCards)
        setGame.deselectCards()
        if let findedCards = setGame.findMatches() {
            drawCardBorderColor(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), forCards: findedCards)
            findedCards.forEach { tag in
                guard let card = view.viewWithTag(tag) else { return }
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
                                let _ = self.setGame.isCardSelected(withContent: tag)
                                if self.selectedCards.count == 3 {
                                    self.totalScore -= 4
                                    self.matchCards()
                                }
                            }
                        )
                    }
                )
            }
        }
    }
    
    @objc func cardTapped(_ sender: UILongPressGestureRecognizer) {
        guard
            selectedCards.count < 3,
            let card = sender.view
        else {
            return
        }
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
                    switch self.setGame.isCardSelected(withContent: card.tag) {
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
    
    // MARK: - Cards movement
    private func matchCards() {
        guard selectedCards.count == 3 else { return }
        if setGame.cardsMatched(cards: selectedCards) {
            toolbarItems?[1].isEnabled = false
            totalScore += 3
            drawCardBorderColor(#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), forCards: selectedCards)
            setGame.removeMatchedCardsFromTable()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.drawCardBorderColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), forCards: self.selectedCards)
                if self.cardsOnTable.count < 12 { self.putThreeCardsOnTable() }
                self.redrawUI()
                self.setGame.deselectCards()
            }
        } else {
            totalScore -= 1
            drawCardBorderColor(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), forCards: selectedCards)
            selectedCards.forEach { self.view.viewWithTag($0)?.transform = CGAffineTransform(translationX: -3, y: 0) }
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.07, delay: 0, options: [],
                animations: {
                    self.selectedCards.forEach { self.view.viewWithTag($0)?.transform = CGAffineTransform(translationX: 3, y: 0) }
                },
                completion: { _ in
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.07, delay: 0, options: [],
                        animations: {
                            self.selectedCards.forEach { self.view.viewWithTag($0)?.transform = CGAffineTransform(translationX: -3, y: 0) }
                        },
                        completion: { _ in
                            UIViewPropertyAnimator.runningPropertyAnimator(
                                withDuration: 0.07, delay: 0, options: [],
                                animations: {
                                    self.selectedCards.forEach { self.view.viewWithTag($0)?.transform = CGAffineTransform.identity }
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
    
    private func putThreeCardsOnTable() {
        setGame.putThreeCardsOnTable()
        if cardDeckIsEmpty { navigationItem.rightBarButtonItem?.isEnabled = false }
    }
    
    private func checkMatchesOnTable() {
        if cardDeckIsEmpty && setGame.findMatches() == nil {
            gameOver()
        } else if setGame.findMatches() != nil {
            toolbarItems?[1].isEnabled = true
            view.isUserInteractionEnabled = true
        } else {
            putThreeCardsOnTable()
            setGame.shuffleCards()
            redrawUI()
        }
    }
    
    private func gameOver() {
        let alertController = UIAlertController(title: "Game is over!\nYour score is: \(totalScore)", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "New Game", style: .default) { _ in
            self.createNewGame()
        }
        alertController.addAction(action)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
        view.isUserInteractionEnabled = false
        toolbarItems?[1].isEnabled = false
    }

    // MARK: - Redrawings
    private func drawCardBorderColor(_ color: UIColor, forCards cards: [Int]) {
        cards.forEach { view.viewWithTag($0)?.layer.borderColor = color.cgColor }
    }
    
    private func redrawUI() {
        setupGrid()
        
        if selectedCards.count == 3 && view.subviews.count == 12 && !cardDeckIsEmpty {
            let newlyAddedCards = cardsOnTable.filter { view.viewWithTag($0) == nil }
            newlyAddedCards.enumerated().forEach {
                guard let oldCard = view.viewWithTag(selectedCards[$0]), 
                      let newCard = cardSet.cardsByTag[$1]
                else { return }
                
                let oldCardFrame = oldCard.frame
                
                view.bringSubviewToFront(oldCard)
//                newCard.frame.origin = CGPoint(x: oldCardFrame.midX, y: view.bounds.minY - 100)
                newCard.alpha = 0
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.8, delay: 0, options: [],
                    animations: {
                        oldCard.transform = CGAffineTransform.identity.translatedBy(x: -oldCard.frame.origin.x, y: -oldCard.frame.origin.y-210)
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
                            withDuration: 0.6, delay: 0, options: [.transitionFlipFromLeft],
                            animations: {
//                                self.view.layoutIfNeeded()
//                                newCard.subviews[0].subviews.forEach { $0.setNeedsDisplay() }
                                newCard.alpha = 1
                            },
                            completion: {_ in
                                oldCard.transform = CGAffineTransform.identity
                                oldCard.alpha = 1
                                self.removeCardConstraints(forCard: oldCard)
                                self.checkMatchesOnTable()
                            }
                        )
                    }
                )
            }
        } else {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.8, delay: 0, options: [],
                animations: {
                    self.view.subviews.forEach { card in
                        if self.selectedCards.count == 3 && self.selectedCards.contains(card.tag) {
                            self.view.bringSubviewToFront(card)
                            card.transform = CGAffineTransform.identity.translatedBy(x: -card.frame.origin.x, y: -card.frame.origin.y-210)
                            card.alpha = 0.3
                        }
                    }
                },
                completion: {_ in
                    self.view.subviews.forEach { card in
                        card.transform = CGAffineTransform.identity
                        card.alpha = 1
                        self.removeCardConstraints(forCard: card)
                    }
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.8, delay: 0, options: [],
                        animations: {
                            self.createCardsConstraints()
                            self.drawCardBorderColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), forCards: self.selectedCards) // if cards saved pressed
                        },
                        completion: {_ in
                            self.checkMatchesOnTable()
                        }
                    )
                }
            )
        }
    }
    
    // MARK: - Constraints rearrangement
    private func setupGrid() {
        if #available(iOS 11.0, *) {
            grid.frame = view.safeAreaLayoutGuide.layoutFrame
        } else {
            grid.frame = view.bounds
        }
        grid.cellCount = cardsOnTable.count
    }
    
    private func createCardsConstraints() {
        cardsOnTable.enumerated().forEach { (index, tag) in
            guard let card = cardSet.cardsByTag[tag] else { return }
            view.addSubview(card)
            NSLayoutConstraint.activate([
                card.topAnchor.constraint(equalTo: view.topAnchor, constant: grid[index]!.origin.y + 2),
                card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: grid[index]!.origin.x + 2),
                card.widthAnchor.constraint(equalToConstant: grid[index]!.size.width - 4),
                card.heightAnchor.constraint(equalToConstant: grid[index]!.size.height - 4)
            ])
        }
        view.layoutIfNeeded()
    }
    
    private func removeCardConstraints(forCard card: UIView) {
        card.removeFromSuperview()
        card.removeConstraint(card.constraints.last!)
        card.removeConstraint(card.constraints.last!)
    }
}
