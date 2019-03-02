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
        self.stop()
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
            self.addNotification(name: UIResponder.keyboardDidChangeFrameNotification)
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
            self.removeNotification(name: UIResponder.keyboardDidChangeFrameNotification)
        }
    }
    
    private func log(string: String)
    {
        if (self.loggingEnabled)
        {
            print(string)
        }
    }
    
    private func checkForKeyboardHeightChange(notification: Notification)
    {
        if let keyboardInfo = notification.userInfo
        {
            self.log(string: "\nKeyboardObserver: checkForKeyboardHeightChange()")
            
            var beginFrameHeight: CGFloat?
            var endFrameHeight: CGFloat?
            
            if let beginFrame = keyboardInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue
            {
                beginFrameHeight = beginFrame.cgRectValue.size.height
            }
            
            if let endFrame = keyboardInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            {
                endFrameHeight = endFrame.cgRectValue.size.height
            }
            
            self.log(string: "beginFrameHeight: \(beginFrameHeight)")
            self.log(string: "endFrameHeight: \(endFrameHeight)")
            
            var newKeyboardHeight: CGFloat?
            if let endFrameHeight = endFrameHeight
            {
                newKeyboardHeight = endFrameHeight
            }
            else if let beginFrameHeight = beginFrameHeight
            {
                newKeyboardHeight = beginFrameHeight
            }
            
            let lastKeyboardHeight: CGFloat = self.keyboardHeight
            self.log(string: "  lastKeyboardHeight: \(lastKeyboardHeight)")
            
            if let newKeyboardHeight = newKeyboardHeight
            {
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
}

// MARK: - NotificationHandler

extension KeyboardObserver: NotificationHandler
{    
    func handleNotification(notification: Notification)
    {
        if (notification.name == UIResponder.keyboardWillShowNotification)
        {
            self.log(string:"\nKeyboardObserver: UIKeyboardWillShow()")
            
            if let keyboardInfo = notification.userInfo
            {
                if let keyboardAnimationDurationNumber = keyboardInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
                {
                    self.keyboardAnimationDuration = keyboardAnimationDurationNumber.doubleValue
                }
            }
            
            if (!self.keyboardIsUp)
            {
                self.keyboardState = .willShow
                
                self.checkForKeyboardHeightChange(notification: notification)
                
                if let delegate = self.delegate
                {
                    delegate.keyboardDidChangeState(keyboardObserver: self, keyboardState: .willShow)
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
        else if (notification.name == UIResponder.keyboardDidChangeFrameNotification)
        {
            self.log(string:"\nKeyboardObserver: UIKeyboardDidChangeFrame()")
            
            if (self.keyboardIsUp)
            {
                self.checkForKeyboardHeightChange(notification: notification)
            }
        }
    }
}
