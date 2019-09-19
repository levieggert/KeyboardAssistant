//
//  Created by Levi Eggert.
//  Copyright © 2017 Levi Eggert. All rights reserved.
//

import UIKit

public protocol KeyboardObserverDelegate: class {
    func keyboardDidChangeState(keyboardObserver: KeyboardObserver, keyboardState: KeyboardObserver.KeyboardState)
    func keyboardDidInvalidateKeyboardHeight(keyboardObserver: KeyboardObserver, keyboardHeight: CGFloat)
}

public class KeyboardObserver: NSObject {
    
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
    
    public override init() {
        super.init()
    }
    
    deinit {
        stop()
    }
    
    public func start() {
        if !isObserving {
            isObserving = true
            
            addNotification(name: UIResponder.keyboardWillShowNotification)
            addNotification(name: UIResponder.keyboardDidShowNotification)
            addNotification(name: UIResponder.keyboardWillHideNotification)
            addNotification(name: UIResponder.keyboardDidHideNotification)
            addNotification(name: UIResponder.keyboardDidChangeFrameNotification)
        }
    }
    
    public func stop() {
        if isObserving {
            isObserving = false
            
            removeNotification(name: UIResponder.keyboardWillShowNotification)
            removeNotification(name: UIResponder.keyboardDidShowNotification)
            removeNotification(name: UIResponder.keyboardWillHideNotification)
            removeNotification(name: UIResponder.keyboardDidHideNotification)
            removeNotification(name: UIResponder.keyboardDidChangeFrameNotification)
        }
    }
    
    private func log(string: String) {
        if loggingEnabled
        {
            print(string)
        }
    }
    
    private func checkForKeyboardHeightChange(notification: Notification) {
        if let keyboardInfo = notification.userInfo {
            log(string: "\nKeyboardObserver: checkForKeyboardHeightChange()")
            
            var beginFrameHeight: CGFloat?
            var endFrameHeight: CGFloat?
            
            if let beginFrame = keyboardInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue {
                beginFrameHeight = beginFrame.cgRectValue.size.height
            }
            
            if let endFrame = keyboardInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                endFrameHeight = endFrame.cgRectValue.size.height
            }
            
            log(string: "beginFrameHeight: \(String(describing: beginFrameHeight))")
            log(string: "endFrameHeight: \(String(describing: endFrameHeight))")
            
            var newKeyboardHeight: CGFloat?
            if let endFrameHeight = endFrameHeight {
                newKeyboardHeight = endFrameHeight
            }
            else if let beginFrameHeight = beginFrameHeight {
                newKeyboardHeight = beginFrameHeight
            }
            
            let lastKeyboardHeight: CGFloat = keyboardHeight
            log(string: "  lastKeyboardHeight: \(lastKeyboardHeight)")
            
            if let newKeyboardHeight = newKeyboardHeight {
                log(string: "  newKeyboardHeight: \(newKeyboardHeight)")
                
                if (lastKeyboardHeight != newKeyboardHeight) {
                    keyboardHeight = newKeyboardHeight
                    delegate?.keyboardDidInvalidateKeyboardHeight(keyboardObserver: self, keyboardHeight: keyboardHeight)
                }
            }
        }
    }
}

// MARK: - NotificationHandler

extension KeyboardObserver: NotificationHandler {
    func handleNotification(notification: Notification) {
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            log(string:"\nKeyboardObserver: UIKeyboardWillShow()")
            
            if let keyboardInfo = notification.userInfo {
                if let keyboardAnimationDurationNumber = keyboardInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
                    keyboardAnimationDuration = keyboardAnimationDurationNumber.doubleValue
                }
            }
            
            if !keyboardIsUp {
                keyboardState = .willShow
                
                checkForKeyboardHeightChange(notification: notification)
                
                delegate?.keyboardDidChangeState(keyboardObserver: self, keyboardState: .willShow)
            }
        }
        else if notification.name == UIResponder.keyboardDidShowNotification {
            
            log(string:"\nKeyboardObserver: UIKeyboardDidShow()")
            
            keyboardIsUp = true
            
            let currentState: KeyboardState = keyboardState
            
            keyboardState = .didShow
            
            if currentState == .willShow {
                delegate?.keyboardDidChangeState(keyboardObserver: self, keyboardState: .didShow)
            }
        }
        else if notification.name == UIResponder.keyboardWillHideNotification {
            
            log(string:"\nKeyboardObserver: UIKeyboardWillHide()")
            
            keyboardIsUp = false
            
            delegate?.keyboardDidChangeState(keyboardObserver: self, keyboardState: .willHide)
        }
        else if notification.name == UIResponder.keyboardDidHideNotification {
            
            log(string: "\nKeyboardObserver: UIKeyboardDidHide()")
            
            delegate?.keyboardDidChangeState(keyboardObserver: self, keyboardState: .didHide)
        }
        else if notification.name == UIResponder.keyboardDidChangeFrameNotification {
            
            log(string:"\nKeyboardObserver: UIKeyboardDidChangeFrame()")
            
            if keyboardIsUp {
                checkForKeyboardHeightChange(notification: notification)
            }
        }
    }
}
