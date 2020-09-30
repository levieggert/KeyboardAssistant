//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

public protocol KeyboardAssistantDelegate: class {
    func keyboardAssistantManuallyReposition(keyboardAssistant: KeyboardAssistant, toInputItem: UIView, keyboardHeight: Double)
}

public class KeyboardAssistant: NSObject {
     
    private var observersAdded: Bool = false
    
    public let keyboardObserver: KeyboardNotificationObserver
    
    public private(set) var navigator: InputNavigator!
    public private(set) var repositionType: KeyboardAssistantRepositionType = .autoScrollView
    public private(set) var positionConstraint: KeyboardAssistantPositionConstraint = .viewTopToTopOfScreen
    public private(set) var positionOffset: CGFloat = 20
    public private(set) var resetBottomConstraintConstant: CGFloat = 0
    
    public private(set) weak var scrollView: UIScrollView?
    public private(set) weak var bottomConstraint: NSLayoutConstraint?
    public private(set) weak var bottomConstraintLayoutView: UIView?
    
    public var invertBottomConstraintConstant: Bool = true
    public var animationDuration: TimeInterval = 0.3
    public var loggingEnabled: Bool = false
    
    private weak var delegate: KeyboardAssistantDelegate?
    
    private init(inputNavigator: InputNavigator) {
        
        keyboardObserver = KeyboardNotificationObserver(loggingEnabled: true)
        
        super.init()
                
        navigator = inputNavigator
        
        navigator.delegate = self
    }
    
    deinit {
        stop()
    }
    
    static public func createAutoScrollView(inputNavigator: InputNavigator, positionScrollView: UIScrollView, positionConstraint: KeyboardAssistantPositionConstraint, positionOffset: CGFloat, bottomConstraint: NSLayoutConstraint, bottomConstraintLayoutView: UIView) -> KeyboardAssistant {
        
        let assistant = KeyboardAssistant(inputNavigator: inputNavigator)
        
        assistant.scrollView = positionScrollView
        assistant.positionConstraint = positionConstraint
        assistant.positionOffset = positionOffset
        assistant.bottomConstraint = bottomConstraint
        assistant.bottomConstraintLayoutView = bottomConstraintLayoutView
        assistant.repositionType = .autoScrollView
        
        return assistant
    }
    
    static public func createManual(inputNavigator: InputNavigator, delegate: KeyboardAssistantDelegate, bottomConstraint: NSLayoutConstraint, bottomConstraintLayoutView: UIView) -> KeyboardAssistant {
        
        let assistant = KeyboardAssistant(inputNavigator: inputNavigator)
        
        assistant.bottomConstraint = bottomConstraint
        assistant.bottomConstraintLayoutView = bottomConstraintLayoutView
        assistant.repositionType = .manualWithBottomConstraint
        assistant.delegate = delegate
        
        return assistant
    }
    
    static public func createManual(inputNavigator: InputNavigator, delegate: KeyboardAssistantDelegate) -> KeyboardAssistant {
        
        let assistant = KeyboardAssistant(inputNavigator: inputNavigator)
        
        assistant.repositionType = .manual
        assistant.delegate = delegate
        
        return assistant
    }
    
    public func closeKeyboard() {
        navigator.focusedItem = nil
    }
    
    public func setBottomConstraintToKeyboard(keyboardHeight: Double, animated: Bool) {
        
        if let bottomConstraint = bottomConstraint, let bottomConstraintLayoutView = bottomConstraintLayoutView {
            
            // TODO: Sometimes height will not have to be inverted by -1.  Depends on how constraints are set.
            // If the scrollview bottom is attached to safe area bottom then it needs to be inverted by -1.  Otherwise no inversion.
            // Is there a way to check for this?
            
            if invertBottomConstraintConstant {
                bottomConstraint.constant = CGFloat(keyboardHeight * -1)
            }
            else {
                bottomConstraint.constant = CGFloat(keyboardHeight)
            }
            
            if animated {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    bottomConstraintLayoutView.layoutIfNeeded()
                }, completion: nil)
            }
            else {
                bottomConstraintLayoutView.layoutIfNeeded()
            }
        }
    }
    
    public func resetBottomConstraint(toConstant: CGFloat, animated: Bool) {
        if let bottomConstraint = bottomConstraint, let bottomConstraintLayoutView = bottomConstraintLayoutView {
            bottomConstraint.constant = toConstant
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                bottomConstraintLayoutView.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    public func start() {
        addObservers()
        navigator.addNotifications()
        keyboardObserver.startObservingKeyboardChanges()
    }
    
    public func stop() {
        removeObservers()
        navigator.focusedItem = nil
        keyboardObserver.stopObservingKeyboardChanges()
        navigator.removeNotifications()
    }
    
    private func reposition(toInputItem: UIView) {
        
        switch repositionType {
        case .autoScrollView:
            if let scrollView = scrollView {
                reposition(scrollView: scrollView, toInputItem: toInputItem, constraint: positionConstraint, offset: positionOffset)
            }
        case .manualWithBottomConstraint:
            delegate?.keyboardAssistantManuallyReposition(keyboardAssistant: self, toInputItem: toInputItem, keyboardHeight: keyboardObserver.keyboardHeight)
            
        case .manual:
            delegate?.keyboardAssistantManuallyReposition(keyboardAssistant: self, toInputItem: toInputItem, keyboardHeight: keyboardObserver.keyboardHeight)
        }
    }
    
    public func reposition(scrollView: UIScrollView, toInputItem: UIView, constraint: KeyboardAssistantPositionConstraint, offset: CGFloat) {
        if keyboardObserver.keyboardIsUp {
            var scrollOffset: CGFloat?

            //first - get position of toInputItem relative to scrollview
            var position: CGPoint = toInputItem.convert(toInputItem.frame.origin, to: scrollView)
            position.y = position.y - toInputItem.frame.origin.y // Here we subtract because when converting to scrollview coordinate space toInputItem.origin.y is added to conversion
            
            switch constraint {
            case .viewTopToTopOfScreen:
                scrollOffset = position.y - offset // Account for offset
                
            case .viewBottomToTopOfKeyboard:
                position.y = position.y - scrollView.frame.size.height // This conversion is as if we were placing position.y at the top of the keyboard, align toInputItem top with keyboard top.
                scrollOffset = position.y + toInputItem.frame.size.height + offset // Account for toInputItem.height and offset
            }
            
            log(string: "\nKeyboardAssistant: reposition(scrollView)")
            log(string:"  constraint: \(constraint)")
            log(string:"  offset: \(offset)")
            log(string:"  toInputItem.origin.y: \(toInputItem.frame.origin.y)")
            log(string:"  position.y: \(position.y)")
            log(string:"  scrollOffset: \(String(describing: scrollOffset))")
            
            if var scrollOffset = scrollOffset {
                // dont allow to scroll passed bottom of scroll view.
                if scrollView.contentSize.height - scrollOffset < scrollView.frame.size.height {
                    let bottomOfScrollViewOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
                    scrollOffset = bottomOfScrollViewOffset
                }
                
                if scrollOffset < 0 {
                    scrollOffset = 0
                }
                
                let contentOffset: CGPoint = CGPoint(x: 0, y: scrollOffset)
                
                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
                    scrollView.setContentOffset(contentOffset, animated: false)
                }, completion: nil)
            }
        }
    }
    
    private func log(string: String) {
        if loggingEnabled {
            print(string)
        }
    }
    
    // MARK: - Observers
    
    private func addObservers() {
        
        guard !observersAdded else {
            return
        }
        
        observersAdded = true
        
        keyboardObserver.keyboardStateDidChangeSignal.addObserver(self) { [weak self] (keyboardStateChange: KeyboardStateChange) in
            self?.handleKeyboardStateChange(keyboardStateChange: keyboardStateChange)
        }
        
        keyboardObserver.keyboardHeightDidChangeSignal.addObserver(self) { [weak self] (keyboardHeight: Double) in
            self?.handleKeyboardHeightChange(keyboardHeight: keyboardHeight)
        }
    }
    
    private func removeObservers() {
        
        guard observersAdded else {
            return
        }
        
        observersAdded = false
        
        keyboardObserver.keyboardStateDidChangeSignal.removeObserver(self)
        keyboardObserver.keyboardHeightDidChangeSignal.removeObserver(self)
    }
    
    private func handleKeyboardStateChange(keyboardStateChange: KeyboardStateChange) {
        
        log(string: "\nKeyboardAssistant: keyboard state changed: \(keyboardStateChange.keyboardState)")
        
        switch keyboardStateChange.keyboardState {
        
        case .willShow:
            setBottomConstraintToKeyboard(keyboardHeight: keyboardStateChange.keyboardHeight, animated: false)
            
        case .didShow:
            if let toInputItem = navigator.focusedItem {
                reposition(toInputItem: toInputItem)
            }
            
        case .willHide:
            resetBottomConstraint(toConstant: resetBottomConstraintConstant,animated: true)
        case .didHide:
            break
        }
    }
    
    private func handleKeyboardHeightChange(keyboardHeight: Double) {
        
        log(string: "\nKeyboardAssistant: keyboard height changed: \(keyboardHeight)")
        log(string: "  keyboardHeight: \(keyboardHeight)")
        
        setBottomConstraintToKeyboard(keyboardHeight: keyboardHeight, animated: false)
        
        if let toInputItem = navigator.focusedItem {
            reposition(toInputItem: toInputItem)
        }
    }
}

// MARK: - InputNavigatorDelegate

extension KeyboardAssistant: InputNavigatorDelegate {
    public func inputNavigatorFocusChanged(inputNavigator: InputNavigator, inputItem: UIView?) {
        
        log(string: "\nKeyboardAssistant: input focus changed")
        
        if let toInputItem = inputItem {
            reposition(toInputItem: toInputItem)
        }
    }
}
