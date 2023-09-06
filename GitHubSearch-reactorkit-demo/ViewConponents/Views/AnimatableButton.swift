//
//  AnimatableButton.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import UIKit

class AnimatableButton: UIButton {
    
    enum FeedbackImpact {
        case style(UIImpactFeedbackGenerator.FeedbackStyle)
        case none
    }
    
    enum TouchBgColor {
        case color(UIColor)
        case none
    }
    
    var feedbackImpact: FeedbackImpact = .none
    var beginBgColor: TouchBgColor = .none
    var endBgColor: TouchBgColor = .none
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        switch beginBgColor {
        case .color(let color):
            self.backgroundColor = color
        case .none: break }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        switch feedbackImpact {
        case .style(let feedBackStyle):
            let generator = UIImpactFeedbackGenerator(style: feedBackStyle)
            generator.impactOccurred()
        case .none: break }
        
        switch endBgColor {
        case .color(let color):
            self.backgroundColor = color
        case .none: break }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        switch endBgColor {
        case .color(let color):
            self.backgroundColor = color
        case .none: break }
    }
    
}

