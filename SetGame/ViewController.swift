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
    private var cardPictures = [NSAttributedString]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New Game", style: .plain, target: self, action: #selector(createNewGame))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Get 3 cards", style: .plain, target: self, action: #selector(addThreeCards))
        createNewGame()
    }
    
    // MARK: - Game creation
    @objc func createNewGame() {
        totalScore = 0
        selectedCardTags.removeAll()
        mainView.hideExtraCards()
        createCardPictures()
        mainView.cards.forEach { if !$0.isHidden { drawNewCard($0) } }
    }
    
    private func createCardPictures() {
        cardPictures.removeAll(keepingCapacity: true)
        let shapes = ["●", "▲", "■", "●\n●", "▲\n▲", "■\n■", "●\n●\n●", "▲\n▲\n▲", "■\n■\n■"]
        let colors = [#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1)]
        var attributes = [[NSAttributedString.Key: Any]]()
        colors.forEach { color in
            let stripedAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: color.withAlphaComponent(0.3),
                .strokeWidth: -0.1,
                .font: UIFont.systemFont(ofSize: 24)]
            attributes.append(stripedAttributes)
            
            let filledAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: color,
                .strokeWidth: 0.0,
                .font: UIFont.systemFont(ofSize: 24)]
            attributes.append(filledAttributes)
            
            let strokedAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: color,
                .strokeWidth: 10.0,
                .font: UIFont.systemFont(ofSize: 24)]
            attributes.append(strokedAttributes)
        }
        shapes.forEach { shape in
            attributes.forEach { attribute in
                cardPictures.append(NSAttributedString(string: shape, attributes: attribute))
            }
        }
        cardPictures.shuffle()
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
        guard selectedCardTags.count == 3,
            let picture1 = (view.viewWithTag(selectedCardTags[0]) as? UIButton)?.currentAttributedTitle!,
            let picture2 = (view.viewWithTag(selectedCardTags[1]) as? UIButton)?.currentAttributedTitle!,
            let picture3 = (view.viewWithTag(selectedCardTags[2]) as? UIButton)?.currentAttributedTitle!
            else { return }
        // TODO: Transfer matching logic in model
        let itemCount1 = picture1.length == picture2.length
        let itemCount2 = picture1.length == picture3.length
        let itemCount3 = picture2.length == picture3.length
        let itemCountMatching = itemCount1==itemCount2 && itemCount1==itemCount3 && itemCount2==itemCount3
//        print("Button's matching lenght is \(lenghtMatching)")
        
        let shape1 = picture1.string.first! == picture2.string.first!
        let shape2 = picture1.string.first! == picture3.string.first!
        let shape3 = picture2.string.first! == picture3.string.first!
        let shapeMatching = shape1==shape2 && shape1==shape3 && shape2==shape3
//        print("Button's matching shape is \(shapeMatching)")
        
        let color1 = (picture1.attribute(.foregroundColor, at: 0, effectiveRange: nil)! as! UIColor).withAlphaComponent(1) == (picture2.attribute(.foregroundColor, at: 0, effectiveRange: nil)! as! UIColor).withAlphaComponent(1)
        let color2 = (picture1.attribute(.foregroundColor, at: 0, effectiveRange: nil)! as! UIColor).withAlphaComponent(1) == (picture3.attribute(.foregroundColor, at: 0, effectiveRange: nil)! as! UIColor).withAlphaComponent(1)
        let color3 = (picture2.attribute(.foregroundColor, at: 0, effectiveRange: nil)! as! UIColor).withAlphaComponent(1) == (picture3.attribute(.foregroundColor, at: 0, effectiveRange: nil)! as! UIColor).withAlphaComponent(1)
        let colorMatching = color1==color2 && color1==color3 && color2==color3
//        print("Button's matching color is \(colorMatching)")
        
        let solid1 = (picture1.attribute(.strokeWidth, at: 0, effectiveRange: nil)! as! NSNumber) == (picture2.attribute(.strokeWidth, at: 0, effectiveRange: nil)! as! NSNumber)
        let solid2 = (picture1.attribute(.strokeWidth, at: 0, effectiveRange: nil)! as! NSNumber) == (picture3.attribute(.strokeWidth, at: 0, effectiveRange: nil)! as! NSNumber)
        let solid3 = (picture2.attribute(.strokeWidth, at: 0, effectiveRange: nil)! as! NSNumber) == (picture3.attribute(.strokeWidth, at: 0, effectiveRange: nil)! as! NSNumber)
        let solidMatching = solid1==solid2 && solid1==solid3 && solid2==solid3
//        print("Button's matching solid is \(solidMatching)")
        
        // TODO: Animate matching
        if itemCountMatching && shapeMatching && colorMatching && solidMatching {
            drawCardBorderColor(#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
                if !self.mainView.hStacks[4].isHidden {
                    self.moveExtraCards()
                } else if !self.cardPictures.isEmpty {
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
                }
                self.totalScore += 1
                self.selectedCardTags.removeAll()
            }
        } else {
            drawCardBorderColor(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
                self.drawCardBorderColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                self.selectedCardTags.removeAll()
            }
        }
    }
    
    // MARK: - Moving extra cards after matching
    private func moveExtraCards() {
        drawCardBorderColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
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
        let arrayOfCardTags = mainView.hStacks[index].arrangedSubviews.compactMap{ $0.tag }
        let movedCards = arrayOfCardTags.filter{!selectedCardTags.contains($0)}
        let replacedCards = selectedCardTags.filter{!arrayOfCardTags.contains($0)}
        
        if movedCards.count == 1 {
            let movedCard = view.viewWithTag(movedCards.first!) as! UIButton
            let replacedCard = view.viewWithTag(replacedCards.first!) as! UIButton
            replacedCard.setAttributedTitle(movedCard.currentAttributedTitle, for: .normal)
        } else if movedCards.count == 2 {
            let movedCard1 = view.viewWithTag(movedCards.first!) as! UIButton
            let replacedCard1 = view.viewWithTag(replacedCards.first!) as! UIButton
            replacedCard1.setAttributedTitle(movedCard1.currentAttributedTitle, for: .normal)
            let movedCard2 = view.viewWithTag(movedCards[1]) as! UIButton
            let replacedCard2 = view.viewWithTag(replacedCards[1]) as! UIButton
            replacedCard2.setAttributedTitle(movedCard2.currentAttributedTitle, for: .normal)
        }
        mainView.hStacks[index].isHidden = true
    }

    // MARK: - Helper methods
    private func drawCardBorderColor(_ color: UIColor) {
        selectedCardTags.forEach {
            guard let button = view.viewWithTag($0) as? UIButton else { return }
            button.layer.borderColor = color.cgColor
        }
    }
    private func drawNewCard(_ card: UIButton) {
        card.setAttributedTitle(cardPictures.removeFirst(), for: .normal)
        card.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
    }
}

