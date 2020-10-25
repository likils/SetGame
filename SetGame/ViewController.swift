//
//  ViewController.swift
//  SetGame
//
//  Created by Nik on 19.10.2020.
//  Copyright © 2020 Nik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var mainView: MainStackView = {
        let mainView = MainStackView()
        view.addSubview(mainView)
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        mainView.cards.forEach { $0.addTarget(self, action: #selector(cardTapped), for: .touchUpInside) }
        return mainView
    }()

    private var totalScore = 0 {
        didSet { title = "Score: \(totalScore)" }
    }
    private var selectedCardTags = [Int]()
    private var cardTags = [Int]()
    private var cardPictureByTag = [Int: NSAttributedString]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New Game", style: .plain, target: self, action: #selector(createNewGame))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Get 3 cards", style: .plain, target: self, action: #selector(addThreeCards))
        navigationController?.isToolbarHidden = false
        let cheatButton = UIBarButtonItem(title: "Find 3 cards", style: .done, target: self, action: #selector(cheat))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [spacer, cheatButton, spacer]
        
        createNewGame()
    }
    
    // MARK: - New game init
    @objc func createNewGame() {
        totalScore = 0
        selectedCardTags.removeAll()
        mainView.hideExtraCards()
        navigationItem.rightBarButtonItem?.isEnabled = true
        toolbarItems![1].isEnabled = true
        createCardPictures()
        mainView.cards.forEach { 
            $0.isEnabled = true
            $0.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            if !$0.isHidden { drawNewCard($0) }
        }
    }
    
    private func createCardPictures() {
        cardTags.removeAll(keepingCapacity: true)
        cardPictureByTag.removeAll(keepingCapacity: true)
        let shapes = ["●", "▲", "■", "●\n●", "▲\n▲", "■\n■", "●\n●\n●", "▲\n▲\n▲", "■\n■\n■"]
        let colors = [#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1)]
        var (lenghtIndex, shapeIndex, colorIndex, solidIndex) = (1,1,1,1)
        shapes.forEach { shape in
            if shapeIndex > 3 {shapeIndex = 1; lenghtIndex += 1}
            colors.forEach { color in
                solidIndex = 1
                if colorIndex > 3 {colorIndex = 1}
                
                let stripedAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: color.withAlphaComponent(0.3),
                    .strokeWidth: -0.1]
                cardPictureByTag[Int("\(lenghtIndex)\(shapeIndex)\(colorIndex)\(solidIndex)")!] = NSAttributedString(string: shape, attributes: stripedAttributes)
                solidIndex += 1
                
                let filledAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: color,
                    .strokeWidth: 0.0]
                cardPictureByTag[Int("\(lenghtIndex)\(shapeIndex)\(colorIndex)\(solidIndex)")!] = NSAttributedString(string: shape, attributes: filledAttributes)
                solidIndex += 1
                
                let strokedAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: color,
                    .strokeWidth: 10.0]
                cardPictureByTag[Int("\(lenghtIndex)\(shapeIndex)\(colorIndex)\(solidIndex)")!] = NSAttributedString(string: shape, attributes: strokedAttributes)
                colorIndex += 1
            }
            shapeIndex += 1
        }
        cardPictureByTag.keys.forEach{cardTags.append($0)}
        cardTags.shuffle()
    }
    
    // MARK: - Adding cards
    @objc func addThreeCards() {
        if mainView.hStacks[4].isHidden {
            prepareHiddenStackWithCards(atIndex: 4)
        } else if mainView.hStacks[5].isHidden {
            prepareHiddenStackWithCards(atIndex: 5)
        } else if mainView.hStacks[6].isHidden {
            prepareHiddenStackWithCards(atIndex: 6)
        } else if mainView.hStacks[7].isHidden {
            prepareHiddenStackWithCards(atIndex: 7)
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func prepareHiddenStackWithCards(atIndex index: Int) {
        mainView.hStacks[index].isHidden = false
        mainView.hStacks[index].arrangedSubviews.forEach { view in
            let card = view as! UIButton
            card.isHidden = false
            drawNewCard(card)
        }
    }
    
    // MARK: - Find 3 cards (cheat)
    
    @objc func cheat() {
        drawCardBorderColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
        selectedCardTags.removeAll()
        let activeButtons = mainView.cards.filter{!$0.isHidden}.filter{$0.isEnabled}
        for i1 in (0..<activeButtons.count-2) {
            selectedCardTags.insert(activeButtons[i1].tag, at: 0)
            
            for i2 in (1..<activeButtons.count-1) {
                selectedCardTags.insert(activeButtons[i2].tag, at: 1)
                if selectedCardTags[0] == selectedCardTags[1] { selectedCardTags.remove(at: 1); continue }
                
                for i3 in (2..<activeButtons.count) {
                    selectedCardTags.insert(activeButtons[i3].tag, at: 2)
                    if selectedCardTags[0] == selectedCardTags[2] || selectedCardTags[1] == selectedCardTags[2] { selectedCardTags.remove(at: 2); continue }

                    guard !match() else { 
                        drawCardBorderColor(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0) { [unowned self] in
                            self.drawCardBorderColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                            self.selectedCardTags.removeAll()
                        }
                        return
                    }
                    selectedCardTags.remove(at: 2)
                }
                selectedCardTags.remove(at: 1)
            }
            selectedCardTags.remove(at: 0)
        }
        let controllerTitle: String
        let controllerMessage: String?
        let actionTitle: String
        if !cardTags.isEmpty {
            controllerTitle = "Not found any matches!"
            controllerMessage = "Maybe get 3 extra cards?"
            actionTitle = "Get cards"
        } else {
            controllerTitle = "Game is over! Your score is: \(totalScore)"
            controllerMessage = nil
            actionTitle = "New Game"
            toolbarItems![1].isEnabled = false
        }
        let alertController = UIAlertController(title: controllerTitle, message: controllerMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default) { [unowned self] _ in
            if !self.cardTags.isEmpty {
                self.addThreeCards()
            } else {
                self.createNewGame()
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(action)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Matching cards 
    @objc func cardTapped(_ card: UIButton) {
        switch card.layer.borderColor {
            case #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1).cgColor:
                card.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
                let index = selectedCardTags.firstIndex(of: card.tag)!
                selectedCardTags.remove(at: index)
            default:
                card.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1).cgColor
                selectedCardTags.append(card.tag)
                matchCards()
        }
    }

    private func matchCards() {
        guard selectedCardTags.count == 3 else { return }
        if match() {
            drawCardBorderColor(#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
                self.drawCardBorderColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                self.selectedCardTags.removeSubrange(3...)
                if !self.mainView.hStacks[4].isHidden {
                    self.moveExtraCards()
                } else if !self.cardTags.isEmpty {
                    self.selectedCardTags.forEach {
                        let card = self.view.viewWithTag($0) as! UIButton
                        self.drawNewCard(card)
                    }
                } else {
                    self.selectedCardTags.forEach {
                        let card = self.view.viewWithTag($0) as! UIButton
                        card.backgroundColor = .clear
                        card.setAttributedTitle(NSAttributedString(string: ""), for: .normal)
                        card.isEnabled = false
                        card.layer.borderColor = UIColor.clear.cgColor
                    }
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                }
                self.totalScore += 1
                self.selectedCardTags.removeAll()
            }
        } else {
            drawCardBorderColor(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
                self.drawCardBorderColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                self.selectedCardTags.removeAll()
            }
        }
    }
    
    private func match() -> Bool {
        let picture1 = selectedCardTags[0].digits
        let picture2 = selectedCardTags[1].digits
        let picture3 = selectedCardTags[2].digits
        for i in 0..<picture1.count {
            if !((picture1[i]+picture2[i]+picture3[i])%3==0) {
                return false
            }
        }
        return true
    }
    
    // MARK: - Moving extra cards after matching
    private func moveExtraCards() {
        if !mainView.hStacks[7].isHidden {
            removeCardsFromStackAtIndex(7)
        } else if !mainView.hStacks[6].isHidden {
            removeCardsFromStackAtIndex(6)
        } else if !mainView.hStacks[5].isHidden {
            removeCardsFromStackAtIndex(5)
        } else if !mainView.hStacks[4].isHidden {
            removeCardsFromStackAtIndex(4)
        }
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    private func removeCardsFromStackAtIndex(_ index: Int) {
        let cardTagsInStack = mainView.hStacks[index].arrangedSubviews.compactMap{$0.tag}
        let movedCards = cardTagsInStack.filter{!selectedCardTags.contains($0)}
        let replacedCards = selectedCardTags.filter{!cardTagsInStack.contains($0)}
        (0..<movedCards.count).forEach {
            let movedCard = view.viewWithTag(movedCards[$0]) as! UIButton
            let replacedCard = view.viewWithTag(replacedCards[$0]) as! UIButton
            replacedCard.setAttributedTitle(movedCard.currentAttributedTitle, for: .normal)
            replacedCard.tag = movedCard.tag
        }
        mainView.hStacks[index].isHidden = true
        mainView.hStacks[index].arrangedSubviews.forEach{ $0.isHidden = true }
    }

    // MARK: - Helper methods
    private func drawCardBorderColor(_ color: UIColor) {
        selectedCardTags.forEach {
            guard let button = view.viewWithTag($0) as? UIButton else { return }
            button.layer.borderColor = color.cgColor
        }
    }
    private func drawNewCard(_ card: UIButton) {
        card.tag = cardTags.removeFirst()
        card.setAttributedTitle(cardPictureByTag[card.tag], for: .normal)
        card.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
    }
}

