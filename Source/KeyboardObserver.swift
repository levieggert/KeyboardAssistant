//
//  Created by Levi Eggert.
//  Copyright © 2017 Levi Eggert. All rights reserved.
//

import UIKit

public protocol KeyboardObserverDelegate: class
{
    func keyboardDidChangeState(keyboardObserver: KeyboardObserver, keyboardState: KeyboardObserver.KeyboardState)
    func keyboardDidInvalidateKeyboardHeight(keyboardObserver: KeyboardObserver, keyboardHeight: CGFloat)
}

public class KeyboardObserver: NSObject
{
    public enum KeyboardState { case willShow; case willHide; case didShow; case didHide; }
    
    // MARK: - Properties
    
    public private(set) var keyboardState: KeyboardObserver.KeyboardState = .didHide
    public private(set) var keyboardHeight: CGFloat = 0
    public private(set) var keyboardAnimationDuration: Double = 0
    public private(set) var keyboardIsUp: Bool = false
    public private(set) var isObserving: Bool = false
    
    public weak var delegate: KeyboardObserverDelegate?
    
    public var loggingEnabled: Bool = false
    
    // MARK: - Life Cycle
    
    public override init()
    {
        super.init()
    }
    
    deinit
    {
        
    }
    
    public func start()
    {
        if (!self.isObserving)
        {
            self.isObserving = true
            
            self.addNotification(name: UIResponder.keyboardWillShowNotification)
            self.addNotification(name: UIResponder.keyboardDidShowNotification)
            self.addNotification(name: UIResponder.keyboardWillHideNotification)
            self.addNotification(name: UIResponder.keyboardDidHideNotification)
        }
    }
    
    public func stop()
    {
        if (self.isObserving)
        {
            self.isObserving = false
            
            self.removeNotification(name: UIResponder.keyboardWillShowNotification)
            self.removeNotification(name: UIResponder.keyboardDidShowNotification)
            self.removeNotification(name: UIResponder.keyboardWillHideNotification)
            self.removeNotification(name: UIResponder.keyboardDidHideNotification)
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

// MARK: - NotificationHandler

extension KeyboardObserver: NotificationHandler
{
    @objc func handleNotification(notification: Notification)
    {
        if (notification.name == UIResponder.keyboardWillShowNotification)
        {
            self.log(string:"\nKeyboardObserver: UIKeyboardWillShow()")
            
            if (!self.keyboardIsUp)
            {
                self.keyboardState = .willShow
                
                if let delegate = self.delegate
                {
                    delegate.keyboardDidChangeState(keyboardObserver: self, keyboardState: .willShow)
                }
            }
            
            let lastKeyboardHeight: CGFloat = self.keyboardHeight
            
            self.log(string: "  lastKeyboardHeight: \(lastKeyboardHeight)")
            
            if let keyboardInfo = notification.userInfo
            {
                if let keyboardAnimationDurationNumber = keyboardInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
                {
                    self.keyboardAnimationDuration = keyboardAnimationDurationNumber.doubleValue
                }
                
                if let keyboardFrameValue = keyboardInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue
                {
                    let newKeyboardHeight: CGFloat = keyboardFrameValue.cgRectValue.size.height
                    
                    self.log(string: "  newKeyboardHeight: \(newKeyboardHeight)")
                    
                    if (lastKeyboardHeight != newKeyboardHeight)
                    {
                        self.keyboardHeight = newKeyboardHeight
                        
                        if let delegate = self.delegate
                        {
                            delegate.keyboardDidInvalidateKeyboardHeight(keyboardObserver: self, keyboardHeight: self.keyboardHeight)
                        }
                    }
                }
            }
        }
        else if (notification.name == UIResponder.keyboardDidShowNotification)
        {
            self.log(string:"\nKeyboardObserver: UIKeyboardDidShow()")
            
            self.keyboardIsUp = true
            
            let currentState: KeyboardState = self.keyboardState
            
            self.keyboardState = .didShow
            
            if (currentState == .willShow)
            {
                if let delegate = self.delegate
                {
                    delegate.keyboardDidChangeState(keyboardObserver: self, keyboardState: .didShow)
                }
            }
        }
        else if (notification.name == UIResponder.keyboardWillHideNotification)
        {
            self.log(string:"\nKeyboardObserver: UIKeyboardWillHide()")
            
            self.keyboardIsUp = false
            
            if let delegate = self.delegate
            {
                delegate.keyboardDidChangeState(keyboardObserver: self, keyboardState: .willHide)
            }
        }
        else if (notification.name == UIResponder.keyboardDidHideNotification)
        {
            self.log(string: "\nKeyboardObserver: UIKeyboardDidHide()")
            
            if let delegate = self.delegate
            {
                delegate.keyboardDidChangeState(keyboardObserver: self, keyboardState: .didHide)
            }
        }
    }
}
