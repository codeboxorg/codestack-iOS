//
//  EditorButtonGenerator.swift
//  CommonUIDemo
//
//  Created by hwan on 3/28/25.
//  Copyright © 2025 com.hwan. All rights reserved.
//

import UIKit

enum EditorButtonGenerator {
    indirect enum ButtonType {
        case moveLeft([Command])
        case moveRight([Command])
        case done(Command)
        case tap(Command)
        case symbol(Command)
        case deleteLine(Command)
        case details
    }
    
    static func layoutConfig(button: UIButton, size: CGFloat = 28) {
        button.tintColor = .whiteGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: size).isActive = true
        button.heightAnchor.constraint(equalToConstant: size).isActive = true
    }
    
    static func symbolAlertColorAction(button: UIButton) {
        let selectedColor = UIColor.whiteGray.withAlphaComponent(0.3)
        if button.backgroundColor == .clear || button.backgroundColor == nil {
            button.backgroundColor = selectedColor
        } else {
            button.backgroundColor = .clear
        }
        button.layer.cornerRadius = 6
    }
    
    static func generate(type: ButtonType) -> UIButton {
        let button = UIButton(type: .system)
        
        let action = UIAction { _ in
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.prepare()
            generator.impactOccurred()
        }
        
        button.addAction(action, for: .touchUpInside)
        
        switch type {
        case .symbol(let command):
            let symbolAlertButton = button
            symbolAlertButton.setTitle("S", for: .normal)
            symbolAlertButton.addAction(command.asAction(), for: command.controlType)
            let colorAction = UIAction { [weak symbolAlertButton] _ in
                guard let button = symbolAlertButton else { return }
                symbolAlertColorAction(button: button)
            }
            
            symbolAlertButton.addAction(colorAction, for: .touchUpInside)
            
            layoutConfig(button: symbolAlertButton, size: 30)
            return symbolAlertButton
            
        case .moveLeft(let commands):
            let moveLeftButton = button
            moveLeftButton.setImage(UIImage(systemName: "arrowshape.backward"), for: .normal)
            layoutConfig(button: moveLeftButton, size: 30)
            
            for command in commands {
                moveLeftButton.addAction(command.asAction(), for: command.controlType)
            }
            
            return moveLeftButton
            
        case .moveRight(let commands):
            let moveRightButton = button
            moveRightButton.setImage(UIImage(systemName: "arrowshape.right"), for: .normal)
            layoutConfig(button: moveRightButton, size: 30)
            
            for command in commands {
                moveRightButton.addAction(command.asAction(), for: command.controlType)
            }
            
            return moveRightButton
            
        case .done(let command):
            let doneButton = button
            doneButton.setImage(UIImage(systemName: "keyboard.chevron.compact.down"), for: .normal)
            layoutConfig(button: doneButton)
            doneButton.addAction(command.asAction(), for: .touchUpInside)
            return doneButton
            
        case .tap(let command):
            let tapButton = button
            tapButton.setImage(UIImage(systemName: "arrow.right.to.line"), for: .normal)
            layoutConfig(button: tapButton)
            tapButton.addAction(command.asAction(), for: .touchUpInside)
            return tapButton
            
        case .deleteLine(let command):
            let deleteLine = button
            deleteLine.setImage(UIImage(systemName: "trash"), for: .normal)
            layoutConfig(button: deleteLine)
            deleteLine.addAction(command.asAction(), for: .touchUpInside)
            return deleteLine
            
        case .details:
            return UIButton(type: .system)
        }
    }
    
}
