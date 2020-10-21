//
//  ViewController.swift
//  SetGame
//
//  Created by Nik on 19.10.2020.
//  Copyright © 2020 Nik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var totalScore = 0 {
        didSet { title = "Score: \(totalScore)" }
    }

    private var state = [NSAttributedString]()

    private var selectedCards = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Get 3 cards", style: .plain, target: self, action: #selector(addThreeCards))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New Game", style: .plain, target: self, action: #selector(createNewGame))
        title = "Score: \(totalScore)"
        loadViewElements()
    }
    
    // MARK: - Actions
    @objc func buttonTapped(_ sender: UIButton) {
        switch sender.layer.borderColor {
            case #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1).cgColor:
                sender.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
                let index = selectedCards.firstIndex(of: sender.tag)!
                selectedCards.remove(at: index)
            default:
                if selectedCards.count == 3 {
                    drawCardBorderColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                    selectedCards.removeAll()
                }
                sender.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1).cgColor
                selectedCards.append(sender.tag)
                matchCards()
        }
    }
    
    @objc func addThreeCards() {
        guard vStack.arrangedSubviews.count < 8 else { return }
        vStack.addArrangedSubview(setupHStack())
    }
    
    @objc func createNewGame() {
        // TODO: Create new game
    }
    
    //MARK: - Helper Methods
    func createState() {
        let shapes = ["●", "▲", "■", "●\n●", "▲\n▲", "■\n■", "●\n●\n●", "▲\n▲\n▲", "■\n■\n■"]
        let colors = [#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1)]
        var attributes = [[NSAttributedString.Key: Any]]()
        colors.forEach { color in
            let stripedAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: color.withAlphaComponent(0.3),
                .strokeWidth: -0.1,
                .font: UIFont.systemFont(ofSize: 25)]
            attributes.append(stripedAttributes)
            
            let filletAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: color,
                .strokeWidth: 0.0,
                .font: UIFont.systemFont(ofSize: 25)]
            attributes.append(filletAttributes)
            
            let attributesWithStroke: [NSAttributedString.Key: Any] = [
                .foregroundColor: color,
                .strokeWidth: 10.0,
                .font: UIFont.systemFont(ofSize: 25)]
            attributes.append(attributesWithStroke)
        }
        shapes.forEach { shape in
            attributes.forEach { attribute in
                state.append(NSAttributedString(string: shape, attributes: attribute))
            }
        }
        state.shuffle()
        print(state.count)
    }
    
    func drawCardBorderColor(_ color: UIColor) {
        selectedCards.forEach {
            guard let button = view.viewWithTag($0) as? UIButton else { return }
            button.layer.borderColor = color.cgColor
        }
    }
    
    func matchCards() {
        guard selectedCards.count == 3,
            let button1 = view.viewWithTag(selectedCards[0]) as? UIButton,
            let button2 = view.viewWithTag(selectedCards[1]) as? UIButton,
            let button3 = view.viewWithTag(selectedCards[2]) as? UIButton
            else { return } 
        
        // TODO: Transfer matching logic in model
        let lenght1 = button1.currentAttributedTitle!.length==button2.currentAttributedTitle!.length
        let lenght2 = button1.currentAttributedTitle!.length==button3.currentAttributedTitle!.length
        let lenght3 = button2.currentAttributedTitle!.length==button3.currentAttributedTitle!.length
        let lenghtMatching = lenght1==lenght2 && lenght1==lenght3 && lenght2==lenght3
        print("Button's matching lenght is \(lenghtMatching)")
        
        let shape1 = button1.currentAttributedTitle!.string.first!==button2.currentAttributedTitle!.string.first!
        let shape2 = button1.currentAttributedTitle!.string.first!==button3.currentAttributedTitle!.string.first!
        let shape3 = button2.currentAttributedTitle!.string.first!==button3.currentAttributedTitle!.string.first!
        let shapeMatching = shape1==shape2 && shape1==shape3 && shape2==shape3
        print("Button's matching shape is \(shapeMatching)")
        
        let color1 = button1.titleLabel!.textColor!.withAlphaComponent(1)==button2.titleLabel!.textColor!.withAlphaComponent(1)
        let color2 = button1.titleLabel!.textColor!.withAlphaComponent(1)==button3.titleLabel!.textColor!.withAlphaComponent(1)
        let color3 = button2.titleLabel!.textColor!.withAlphaComponent(1)==button3.titleLabel!.textColor!.withAlphaComponent(1)
        let colorMatching = color1==color2 && color1==color3 && color2==color3
        print("Button's matching color is \(colorMatching)")
        
        let solid1 = (button1.currentAttributedTitle!.attribute(.strokeWidth, at: 0, effectiveRange: nil)! as! NSNumber) == (button2.currentAttributedTitle!.attribute(.strokeWidth, at: 0, effectiveRange: nil)! as! NSNumber)
        let solid2 = (button1.currentAttributedTitle!.attribute(.strokeWidth, at: 0, effectiveRange: nil)! as! NSNumber) == (button3.currentAttributedTitle!.attribute(.strokeWidth, at: 0, effectiveRange: nil)! as! NSNumber)
        let solid3 = (button2.currentAttributedTitle!.attribute(.strokeWidth, at: 0, effectiveRange: nil)! as! NSNumber) == (button3.currentAttributedTitle!.attribute(.strokeWidth, at: 0, effectiveRange: nil)! as! NSNumber)
        let solidMatching = solid1==solid2 && solid1==solid3 && solid2==solid3
        print("Button's matching solid is \(solidMatching)\n")
        
        // TODO: Animate matching
        if lenghtMatching && shapeMatching && colorMatching && solidMatching {
            drawCardBorderColor(#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1))
            if !state.isEmpty {
                selectedCards.forEach {
                    let button = view.viewWithTag($0) as! UIButton
                    button.setAttributedTitle(state.removeFirst(), for: .normal)
                    button.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
                }
            } else {
                selectedCards.forEach {
                    let button = view.viewWithTag($0) as! UIButton
                    button.backgroundColor = .clear
                    button.setAttributedTitle(NSAttributedString(string: ""), for: .normal)
                    button.isEnabled = false
                    button.layer.borderColor = UIColor.clear.cgColor
                }
            }
            selectedCards.removeAll()
            totalScore += 1
        } else {
            drawCardBorderColor(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1))
        }
    }
    
    // MARK: - View Preparation
    // TODO: Create independent view with elements below
    private var buttonTag = 100
    
    private lazy var vStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    func loadViewElements() {
        createState()
        for _ in 0..<4 {
            vStack.addArrangedSubview(setupHStack())
        }
        view.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            vStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            vStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            vStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)])
    }
    
    func setupHStack() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        for _ in 0..<3 {
            let button = setupButton(withTag: buttonTag)
            buttonTag += 1
            stackView.addArrangedSubview(button)
        }
        return stackView
    }
    
    func setupButton(withTag tag: Int) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = tag
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        button.setAttributedTitle(state.removeFirst(), for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9461697033, green: 1, blue: 0.9377601226, alpha: 1)
        button.layer.borderWidth = 3.0
        button.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        button.layer.cornerRadius = 15.0
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }
}

