//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

public protocol KeyboardAssistantDelegate: class {
    func keyboardAssistantManuallyReposition(keyboardAssistant: KeyboardAssistant, toInputItem: UIView, keyboardHeight: CGFloat)
}

public class KeyboardAssistant: NSObject {
    
    public enum AssistantType {
        case autoScrollView
        case manualWithBottomConstraint
        case manual
        
        public static var allTypes: [KeyboardAssistant.AssistantType] {
            return [.autoScrollView, .manualWithBottomConstraint, .manual]
        }
    }
    
    public enum PositionConstraint {
        case viewTopToTopOfScreen
        case viewBottomToTopOfKeyboard
        
        public static var all: [PositionConstraint] {
            return [.viewTopToTopOfScreen, .viewBottomToTopOfKeyboard]
        }
    }
    
    // MARK: - Properties
    
    public private(set) var observer: KeyboardObserver!
    public private(set) var navigator: InputNavigator!
    public private(set) var type: KeyboardAssistant.AssistantType = .autoScrollView
    public private(set) var positionConstraint: KeyboardAssistant.PositionConstraint = .viewTopToTopOfScreen
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
        
        super.init()
        
        observer = KeyboardObserver()
        navigator = inputNavigator
        
        observer.delegate = self
        navigator.delegate = self
    }
    
    static public func createAutoScrollView(inputNavigator: InputNavigator, positionScrollView: UIScrollView, positionConstraint: KeyboardAssistant.PositionConstraint, positionOffset: CGFloat, bottomConstraint: NSLayoutConstraint, bottomConstraintLayoutView: UIView) -> KeyboardAssistant {
        
        let assistant = KeyboardAssistant(inputNavigator: inputNavigator)
        
        assistant.scrollView = positionScrollView
        assistant.positionConstraint = positionConstraint
        assistant.positionOffset = positionOffset
        assistant.bottomConstraint = bottomConstraint
        assistant.bottomConstraintLayoutView = bottomConstraintLayoutView
        assistant.type = .autoScrollView
        
        return assistant
    }
    
    static public func createManual(inputNavigator: InputNavigator, delegate: KeyboardAssistantDelegate, bottomConstraint: NSLayoutConstraint, bottomConstraintLayoutView: UIView) -> KeyboardAssistant {
        
        let assistant = KeyboardAssistant(inputNavigator: inputNavigator)
        
        assistant.bottomConstraint = bottomConstraint
        assistant.bottomConstraintLayoutView = bottomConstraintLayoutView
        assistant.type = .manualWithBottomConstraint
        assistant.delegate = delegate
        
        return assistant
    }
    
    static public func createManual(inputNavigator: InputNavigator, delegate: KeyboardAssistantDelegate) -> KeyboardAssistant {
        
        let assistant = KeyboardAssistant(inputNavigator: inputNavigator)
        
        assistant.type = .manual
        assistant.delegate = delegate
        
        return assistant
    }
    
    deinit {
        stop()
    }
    
    public func closeKeyboard() {
        navigator.focusedItem = nil
    }
    
    public func setBottomConstraintToKeyboard(keyboardHeight: CGFloat, animated: Bool) {
        
        if let bottomConstraint = bottomConstraint, let bottomConstraintLayoutView = bottomConstraintLayoutView {
            
            // TODO: Sometimes height will not have to be inverted by -1.  Depends on how constraints are set.
            // If the scrollview bottom is attached to safe area bottom then it needs to be inverted by -1.  Otherwise no inversion.
            // Is there a way to check for this?
            
            if invertBottomConstraintConstant {
                bottomConstraint.constant = keyboardHeight * -1
            }
            else {
                bottomConstraint.constant = keyboardHeight
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
        navigator.addNotifications()
        observer.start()
    }
    
    public func stop() {
        navigator.focusedItem = nil
        observer.stop()
        navigator.removeNotifications()
    }
    
    private func reposition(toInputItem: UIView) {
        switch type {
        case .autoScrollView:
            if let scrollView = scrollView {
                reposition(scrollView: scrollView, toInputItem: toInputItem, constraint: positionConstraint, offset: positionOffset)
            }
        case .manualWithBottomConstraint:
            delegate?.keyboardAssistantManuallyReposition(keyboardAssistant: self, toInputItem: toInputItem, keyboardHeight: observer.keyboardHeight)
            
        case .manual:
            delegate?.keyboardAssistantManuallyReposition(keyboardAssistant: self, toInputItem: toInputItem, keyboardHeight: observer.keyboardHeight)
        }
    }
    
    public func reposition(scrollView: UIScrollView, toInputItem: UIView, constraint: PositionConstraint, offset: CGFloat) {
        if observer.keyboardIsUp {
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
                if (scrollView.contentSize.height - scrollOffset) < scrollView.frame.size.height {
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
}

// MARK: - KeyboardObserverDelegate

extension KeyboardAssistant: KeyboardObserverDelegate {
    
    public func keyboardDidChangeState(keyboardObserver: KeyboardObserver, keyboardState: KeyboardObserver.KeyboardState) {
        
        log(string: "\nKeyboardAssistant: keyboard state changed: \(keyboardState)")
        
        switch (keyboardState) {
        
        case .willShow:
            setBottomConstraintToKeyboard(keyboardHeight: keyboardObserver.keyboardHeight, animated: false)
            
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
    
    public func keyboardDidInvalidateKeyboardHeight(keyboardObserver: KeyboardObserver, keyboardHeight: CGFloat) {
        
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
