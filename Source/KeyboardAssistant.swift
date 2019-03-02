//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

public protocol KeyboardAssistantDelegate: class
{
    func keyboardAssistantManuallyReposition(keyboardAssistant: KeyboardAssistant, toInputItem: UIView, keyboardHeight: CGFloat)
}

public class KeyboardAssistant: NSObject
{
    public enum AssistantType { case autoScrollView; case manual; }
    public enum RepositionConstraint { case viewTopToTopOfScreen; case viewBottomToTopOfKeyboard; }
    
    // MARK: - Properties
    
    private weak var bottomConstraint: NSLayoutConstraint?
    private weak var bottomConstraintLayoutView: UIView?
        
    public private(set) var observer: KeyboardObserver!
    public private(set) var navigator: InputNavigator!
    public private(set) var type: KeyboardAssistant.AssistantType = .autoScrollView
    public private(set) var repositionConstraint: KeyboardAssistant.RepositionConstraint = .viewTopToTopOfScreen
    public private(set) var repositionOffset: CGFloat = 20
    public private(set) var resetBottomConstraintConstant: CGFloat = 0
    
    public private(set) weak var scrollView: UIScrollView?
    
    public var animationDuration: TimeInterval = 0.3
    public var loggingEnabled: Bool = false
    
    private weak var delegate: KeyboardAssistantDelegate?
    
    private init(inputNavigator: InputNavigator)
    {
        super.init()
        
        self.observer = KeyboardObserver()
        self.navigator = inputNavigator
        
        self.observer.delegate = self
        self.navigator.delegate = self
        
        // TODO: Is there a way to see if the bottom constraint of the scrollview is attached to the safe area for inverting bottomConstraint.constant when pushing up with keyboard?
    }
    
    static public func createAutoScrollViewKeyboardAssistant(inputNavigator: InputNavigator, positionScrollView: UIScrollView, positionConstraint: KeyboardAssistant.RepositionConstraint, positionOffset: CGFloat, bottomConstraint: NSLayoutConstraint, bottomConstraintLayoutView: UIView) -> KeyboardAssistant
    {
        let assistant: KeyboardAssistant = KeyboardAssistant(inputNavigator: inputNavigator)
        
        assistant.scrollView = positionScrollView
        assistant.repositionConstraint = positionConstraint
        assistant.repositionOffset = positionOffset
        assistant.bottomConstraint = bottomConstraint
        assistant.bottomConstraintLayoutView = bottomConstraintLayoutView
        assistant.type = .autoScrollView
        
        return assistant
    }
    
    static public func createManualKeyboardAssistant(inputNavigator: InputNavigator, delegate: KeyboardAssistantDelegate, bottomConstraint: NSLayoutConstraint, bottomConstraintLayoutView: UIView) -> KeyboardAssistant
    {
        let assistant: KeyboardAssistant = KeyboardAssistant(inputNavigator: inputNavigator)
        
        assistant.bottomConstraint = bottomConstraint
        assistant.bottomConstraintLayoutView = bottomConstraintLayoutView
        assistant.type = .manual
        assistant.delegate = delegate
        
        return assistant
    }
    
    deinit
    {
        self.stop()
    }
    
    public func closeKeyboard()
    {
        self.navigator.focusedItem = nil
    }
    
    public func setBottomConstraintToKeyboard(keyboardHeight: CGFloat, animated: Bool)
    {
        if let bottomConstraint = self.bottomConstraint, let bottomConstraintLayoutView = self.bottomConstraintLayoutView
        {
            // TODO: Sometimes height will not have to be inverted by -1.  Depends on how constraints are set.
            // If the scrollview bottom is attached to safe area bottom then it needs to be inverted by -1.  Otherwise no inversion.
            bottomConstraint.constant = keyboardHeight * -1
            
            if (animated)
            {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    bottomConstraintLayoutView.layoutIfNeeded()
                }, completion: { (finished: Bool) in
                    
                    if (finished)
                    {
                        
                    }
                })
            }
            else
            {
                bottomConstraintLayoutView.layoutIfNeeded()
            }
        }
    }
    
    public func resetBottomConstraint(toConstant: CGFloat, animated: Bool)
    {
        if let bottomConstraint = self.bottomConstraint, let bottomConstraintLayoutView = self.bottomConstraintLayoutView
        {
            bottomConstraint.constant = toConstant
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                bottomConstraintLayoutView.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                
                if (finished)
                {
                    
                }
            })
        }
    }
    
    public func start()
    {
        self.navigator.addNotifications()
        self.observer.start()
    }
    
    public func stop()
    {
        self.navigator.focusedItem = nil
        self.observer.stop()
        self.navigator.removeNotifications()
    }
    
    private func reposition(toInputItem: UIView)
    {
        switch (self.type)
        {
        case .autoScrollView:
            if let scrollView = self.scrollView
            {
                self.reposition(scrollView: scrollView, toInputItem: toInputItem, constraint: self.repositionConstraint, offset: self.repositionOffset)
            }
            
        case .manual:
            if let delegate = self.delegate
            {
                delegate.keyboardAssistantManuallyReposition(keyboardAssistant: self, toInputItem: toInputItem, keyboardHeight: self.observer.keyboardHeight)
            }
        }
    }
    
    public func reposition(scrollView: UIScrollView, toInputItem: UIView, constraint: RepositionConstraint, offset: CGFloat)
    {
        if (self.observer.keyboardIsUp)
        {
            var scrollOffset: CGFloat?

            //first - get position of toInputItem relative to scrollview
            var position: CGPoint = toInputItem.convert(toInputItem.frame.origin, to: scrollView)
            position.y = position.y - toInputItem.frame.origin.y // Here we subtract because when converting to scrollview coordinate space toInputItem.origin.y is added to conversion
            
            switch (constraint)
            {
            case .viewTopToTopOfScreen:
                scrollOffset = position.y - offset // Account for offset
                
            case .viewBottomToTopOfKeyboard:
                position.y = position.y - scrollView.frame.size.height // This conversion is as if we were placing position.y at the top of the keyboard, align toInputItem top with keyboard top.
                scrollOffset = position.y + toInputItem.frame.size.height + offset // Account for toInputItem.height and offset
            }
            
            /*
            self.log(string: "\nKeyboardAssistant: reposition(scrollView)")
            self.log(string:"  constraint: \(constraint)")
            self.log(string:"  offset: \(offset)")
            self.log(string:"  toInputItem.origin.y: \(toInputItem.frame.origin.y)")
            self.log(string:"  position.y: \(position.y)")
            self.log(string:"  scrollOffset: \(String(describing: scrollOffset))")
            */
            
            if var scrollOffset = scrollOffset
            {
                // dont allow to scroll passed bottom of scroll view.
                if ((scrollView.contentSize.height - scrollOffset) < scrollView.frame.size.height)
                {
                    let bottomOfScrollViewOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
                    scrollOffset = bottomOfScrollViewOffset
                }
                
                if (scrollOffset < 0)
                {
                    scrollOffset = 0
                }
                
                let contentOffset: CGPoint = CGPoint(x: 0, y: scrollOffset)
                
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
    
    private func log(string: String)
    {
        if (self.loggingEnabled)
        {
            print(string)
        }
    }
}

// MARK: - KeyboardObserverDelegate

extension KeyboardAssistant: KeyboardObserverDelegate
{
    public func keyboardDidChangeState(keyboardObserver: KeyboardObserver, keyboardState: KeyboardObserver.KeyboardState)
    {
        self.log(string: "\nKeyboardAssistant: keyboard state changed: \(keyboardState)")
        
        switch (keyboardState)
        {
        case .willShow:
            self.setBottomConstraintToKeyboard(keyboardHeight: keyboardObserver.keyboardHeight, animated: false)
            
        case .didShow:
            if let toInputItem = self.navigator.focusedItem
            {
                self.reposition(toInputItem: toInputItem)
            }
            
        case .willHide:
            self.resetBottomConstraint(toConstant: self.resetBottomConstraintConstant,animated: true)
            
        case .didHide:
            break
        }
    }
    
    public func keyboardDidInvalidateKeyboardHeight(keyboardObserver: KeyboardObserver, keyboardHeight: CGFloat)
    {
        self.log(string: "\nKeyboardAssistant: keyboard height changed: \(keyboardHeight)")
        self.log(string: "  keyboardHeight: \(keyboardHeight)")
        
        self.setBottomConstraintToKeyboard(keyboardHeight: keyboardHeight, animated: false)
        
        if let toInputItem = self.navigator.focusedItem
        {
            self.reposition(toInputItem: toInputItem)
        }
    }
}

// MARK: - InputNavigatorDelegate

extension KeyboardAssistant: InputNavigatorDelegate
{
    public func inputNavigatorFocusChanged(inputNavigator: InputNavigator, inputItem: UIView?)
    {
        self.log(string: "\nKeyboardAssistant: input focus changed")
        if let toInputItem = inputItem
        {
            self.reposition(toInputItem: toInputItem)
        }
    }
}
