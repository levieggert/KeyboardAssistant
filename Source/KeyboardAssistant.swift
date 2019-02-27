//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

public protocol KeyboardAssistantDelegate: class
{
    func keyboardAssistantManuallyReposition(keyboardAssistant: KeyboardAssistant, view: UIView, keyboardHeight: CGFloat)
}

public class KeyboardAssistant: NSObject
{
    public enum AssistantType { case auto; case manual; }
    public enum RepositionConstraint { case viewTopToTopOfScreen; case viewBottomToTopOfKeyboard; }
    
    // MARK: - Properties
    
    private var resetBottomConstraintConstant: CGFloat = 0
    
    private weak var bottomConstraint: NSLayoutConstraint?
    private weak var bottomConstraintLayoutView: UIView?
        
    public private(set) var observer: KeyboardObserver!
    public private(set) var navigator: InputNavigator!
    public private(set) var type: KeyboardAssistant.AssistantType = .auto
    public private(set) var repositionConstraint: KeyboardAssistant.RepositionConstraint = .viewTopToTopOfScreen
    public private(set) var repositionOffset: CGFloat = 20
    
    public private(set) weak var scrollView: UIScrollView?
    
    public var animationDuration: TimeInterval = 0.3
    
    private weak var delegate: KeyboardAssistantDelegate?
    
    private init(allowToSetInputDelegates: Bool)
    {
        super.init()
        
        self.observer = KeyboardObserver()
        self.navigator = InputNavigator(allowToSetInputDelegates: allowToSetInputDelegates)
        
        self.observer.delegate = self
        self.navigator.delegate = self
        
        // TODO: Is there a way to see if the bottom constraint of the scrollview is attached to the safe area for inverting bottomConstraint.constant when pushing up with keyboard?
    }
    
    static func createAutoKeyboardAssistant(allowToSetInputDelegates: Bool, inputItems: [UIView], positionScrollView: UIScrollView, positionConstraint: KeyboardAssistant.RepositionConstraint, positionOffset: CGFloat, bottomConstraint: NSLayoutConstraint, bottomConstraintLayoutView: UIView) -> KeyboardAssistant
    {
        let assistant: KeyboardAssistant = KeyboardAssistant(allowToSetInputDelegates: allowToSetInputDelegates)
        
        assistant.navigator.addInputItems(inputItems: inputItems)
        assistant.scrollView = positionScrollView
        assistant.repositionConstraint = positionConstraint
        assistant.repositionOffset = positionOffset
        assistant.bottomConstraint = bottomConstraint
        assistant.bottomConstraintLayoutView = bottomConstraintLayoutView
        assistant.type = .auto
        
        return assistant
    }
    
    static func createManualKeyboardAssistant(allowToSetInputDelegates: Bool, inputItems: [UIView], bottomConstraint: NSLayoutConstraint, bottomConstraintLayoutView: UIView, delegate: KeyboardAssistantDelegate) -> KeyboardAssistant
    {
        let assistant: KeyboardAssistant = KeyboardAssistant(allowToSetInputDelegates: allowToSetInputDelegates)
        
        assistant.navigator.addInputItems(inputItems: inputItems)
        assistant.bottomConstraint = bottomConstraint
        assistant.bottomConstraintLayoutView = bottomConstraintLayoutView
        assistant.type = .manual
        
        return assistant
    }
    
    deinit
    {
        
    }
    
    private func reposition()
    {
        switch (self.type)
        {
        case .auto:
            if let scrollView = self.scrollView, let view = self.navigator.focusedItem
            {
                self.reposition(scrollView: scrollView, toView: view, constraint: self.repositionConstraint, offset: self.repositionOffset)
            }
            
        case .manual:
            if let delegate = self.delegate, let view = self.navigator.focusedItem
            {
                delegate.keyboardAssistantManuallyReposition(keyboardAssistant: self, view: view, keyboardHeight: self.observer.keyboardHeight)
            }
        }
    }
    
    public func reposition(scrollView: UIScrollView, toView: UIView, constraint: RepositionConstraint, offset: CGFloat)
    {
        if (self.observer.keyboardIsUp)
        {
            var offsetValue: CGFloat?
            
            switch (constraint)
            {
            case .viewTopToTopOfScreen:
                // TODO: Need to account for nested views.  Above won't work for nested views.
                offsetValue = toView.frame.origin.y - offset
                
            case .viewBottomToTopOfKeyboard:
                // TODO: Need to account for nested views.  Above won't work for nested views.
                offsetValue = (toView.frame.origin.y - scrollView.frame.size.height) + toView.frame.size.height + offset
            }
            
            print("\nKeyboardAssistant: reposition()")
            print("  constraint: \(constraint)")
            print("  offset: \(offset)")
            print("  offsetValue: \(String(describing: offsetValue))")
            
            if var offsetValue = offsetValue
            {
                // dont allow to scroll passed bottom of scroll view.
                if ((scrollView.contentSize.height - offsetValue) < scrollView.frame.size.height)
                {
                    let bottomOfScrollViewOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
                    offsetValue = bottomOfScrollViewOffset
                }
                
                if (offsetValue < 0)
                {
                    offsetValue = 0
                }
                
                let contentOffset: CGPoint = CGPoint(x: 0, y: offsetValue)
                
                UIView.animate(withDuration: self.animationDuration, delay: 0, options: .curveEaseOut, animations: {
                    
                    scrollView.setContentOffset(contentOffset, animated: false)
                    
                }, completion: { (finished: Bool) in
                    
                    if (finished)
                    {
                        
                    }
                })
            }
        }
    }
}

// MARK: - KeyboardObserverDelegate

extension KeyboardAssistant: KeyboardObserverDelegate
{
    public func keyboardDidChangeState(keyboardObserver: KeyboardObserver, keyboardState: KeyboardObserver.KeyboardState)
    {
        print("\nKeyboardAssistant: keyboard state changed: \(keyboardState)")
        
        switch (keyboardState)
        {
        case .willShow:
            break
            
        case .didShow:
            
            if let bottomConstraint = self.bottomConstraint, let bottomConstraintLayoutView = self.bottomConstraintLayoutView
            {
                // TODO: Sometimes height will not have to be inverted by -1.  Depends on how constraints are set.
                // If the scrollview bottom is attached to safe area bottom then it needs to be inverted by -1.  Otherwise no inversion.
                bottomConstraint.constant = keyboardObserver.keyboardHeight * -1
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    bottomConstraintLayoutView.layoutIfNeeded()
                }, completion: { (finished: Bool) in
                    
                    if (finished)
                    {

                    }
                })
            }
            
            self.reposition()
            
        case .willHide:
            break
            
        case .didHide:
            break
        }
    }
    
    public func keyboardDidInvalidateKeyboardHeight(keyboardObserver: KeyboardObserver, keyboardHeight: CGFloat)
    {
        print("\nKeyboardAssistant: keyboard height changed: \(keyboardHeight)")
    }
}

// MARK: - InputNavigatorDelegate

extension KeyboardAssistant: InputNavigatorDelegate
{
    public func inputNavigatorFocusChanged(inputNavigator: InputNavigator, inputItem: UIView?)
    {
        //print("\nKeyboardAssistant: input focus changed")
        self.reposition()
    }
}
