//
//  SymbolView.swift
//  SetGame
//
//  Created by Nik on 29.10.2020.
//  Copyright © 2020 Nik. All rights reserved.
//

import UIKit

final class SymbolView: UIView {
    // MARK: - Cases
    enum Shape: Int, CaseIterable {
        case diamond = 1, squiggle, oval
    }
    enum Color: Int, CaseIterable { 
        case red = 1, green, purple
        var color: UIColor {
            switch self {
                case .red: return .red
                case .green: return .green
                case .purple: return .purple
            }
        }
    }
    enum Shading: Int, CaseIterable {
        case solid = 1, striped, open
    }
    
    // MARK: - Properties
    private var shapeType: Shape
    private var colorType: Color
    private var shadingType: Shading
    
    // MARK: - Drawing
    private func drawDiamond(in rect: CGRect, withPath path: UIBezierPath) {
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.close()
    }
    private func drawOval(in rect: CGRect, withPath path: UIBezierPath) {
        path.move(to: CGPoint(x: rect.maxX/3, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX*2/3, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY), controlPoint: CGPoint(x: rect.maxX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX*2/3, y: rect.maxY), controlPoint: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX/3, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.midY), controlPoint: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX/3, y: rect.minY), controlPoint: CGPoint(x: rect.minX, y: rect.minY))
    }
    private func drawSquiggle(in rect: CGRect, withPath path: UIBezierPath) {
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY*2/3))
        path.addQuadCurve(to: CGPoint(x: rect.maxX*2/5, y: rect.maxY/4), controlPoint: CGPoint(x: rect.minX, y: 1-rect.maxY/5))
        path.addQuadCurve(to: CGPoint(x: rect.maxX*8/10, y: rect.maxY/10), controlPoint: CGPoint(x: rect.maxX*3/5, y: rect.maxY*3/7))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY/3), controlPoint: CGPoint(x: rect.maxX, y: 1-rect.maxY/6))
        
        path.addQuadCurve(to: CGPoint(x: rect.maxX*3/5, y: rect.maxY*3/4), controlPoint: CGPoint(x: rect.maxX, y: rect.maxY*7/6))
        path.addQuadCurve(to: CGPoint(x: rect.maxX*2/10, y: rect.maxY*9/10), controlPoint: CGPoint(x: rect.maxX*2/5, y: rect.maxY*4/7))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY*2/3), controlPoint: CGPoint(x: rect.minX, y: rect.maxY*7/6))
    }
    private func drawStripedShading(in rect: CGRect, withPath path: UIBezierPath) {
        for step in stride(from: 3, to: Int(rect.width), by: 7) {
            path.move(to: CGPoint(x: CGFloat(step), y: rect.minY))
            path.addLine(to: CGPoint(x: CGFloat(step), y: rect.maxY))
        }
        path.addClip()
        path.stroke()
    }
    
    override func draw(_ rect: CGRect) {
        let rect = CGRect(x: 1, y: 1, width: rect.width-2, height: rect.height-2)
        let path = UIBezierPath()
        let color: UIColor
        switch shapeType {
            case .diamond: drawDiamond(in: rect, withPath: path)
            case .squiggle: drawSquiggle(in: rect, withPath: path)
            case .oval: drawOval(in: rect, withPath: path)
        }
        switch colorType {
            case .red: color = colorType.color
            case .green: color = colorType.color
            case .purple: color = colorType.color
        }
        color.setStroke()
        
        switch shadingType {
            case .solid: color.setFill(); path.fill()
            case .striped: drawStripedShading(in: rect, withPath: path) 
            case .open: path.lineWidth = 2; path.stroke()
        }
    }
    
    // MARK: - Initialization
    init(shape: Shape, color: Color, shading: Shading) {
        self.shapeType = shape
        self.colorType = color
        self.shadingType = shading
        super.init(frame: .zero)
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalTo: heightAnchor, multiplier: 2).isActive = true
    }
    
    required convenience init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
