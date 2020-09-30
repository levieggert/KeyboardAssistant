//
//  Created by Levi Eggert.
//  Copyright © 2017 Levi Eggert. All rights reserved.
//

import UIKit

public class KeyboardNotificationObserver: NSObject, KeyboardObserverType {
    
    public let keyboardStateDidChangeSignal: SignalValue<KeyboardStateChange> = SignalValue()
    public let keyboardHeightDidChangeSignal: SignalValue<Double> = SignalValue()
    
    public private(set) var keyboardState: KeyboardState = .didHide
    public private(set) var keyboardHeight: Double = 0
    public private(set) var keyboardAnimationDuration: Double = 0
    public private(set) var keyboardIsUp: Bool = false
    public private(set) var isObservingKeyboardChanges: Bool = false
    public private(set) var loggingEnabled: Bool = false
        
    public required init(loggingEnabled: Bool) {
        
        self.loggingEnabled = loggingEnabled
        
        super.init()
    }
    
    deinit {
        stopObservingKeyboardChanges()
    }
    
    public func startObservingKeyboardChanges() {
        
        guard !isObservingKeyboardChanges else {
            return
        }
        
        isObservingKeyboardChanges = true
        
        addNotification(name: UIResponder.keyboardWillShowNotification)
        addNotification(name: UIResponder.keyboardDidShowNotification)
        addNotification(name: UIResponder.keyboardWillHideNotification)
        addNotification(name: UIResponder.keyboardDidHideNotification)
        addNotification(name: UIResponder.keyboardDidChangeFrameNotification)
    }
    
    public func stopObservingKeyboardChanges() {
        
        guard isObservingKeyboardChanges else {
            return
        }
        
        isObservingKeyboardChanges = false
        
        removeNotification(name: UIResponder.keyboardWillShowNotification)
        removeNotification(name: UIResponder.keyboardDidShowNotification)
        removeNotification(name: UIResponder.keyboardWillHideNotification)
        removeNotification(name: UIResponder.keyboardDidHideNotification)
        removeNotification(name: UIResponder.keyboardDidChangeFrameNotification)
    }
    
    private func log(string: String) {
        
        if loggingEnabled {
            print(string)
        }
    }
    
    private func getKeyboardHeightFromKeyboardNotification(notification: Notification) -> Double? {
        
        guard let keyboardInfo = notification.userInfo else {
            return nil
        }
        
        var beginFrameHeight: Double?
        var endFrameHeight: Double?
        
        if let beginFrame = keyboardInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue {
            beginFrameHeight = Double(beginFrame.cgRectValue.size.height)
        }
        
        if let endFrame = keyboardInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            endFrameHeight = Double(endFrame.cgRectValue.size.height)
        }
        
        log(string: "beginFrameHeight: \(String(describing: beginFrameHeight))")
        log(string: "endFrameHeight: \(String(describing: endFrameHeight))")
        
        let keyboardHeight: Double? = endFrameHeight ?? beginFrameHeight
        
        return keyboardHeight
    }
    
    private func updateKeyboardHeightIfNeededFromKeyboardNotification(notification: Notification, sendNotificationIfKeyboardHeightChanged: Bool) {
        
        log(string: "\nKeyboardNotificationObserver: checkForKeyboardHeightChange()")
        
        guard let newKeyboardHeight = getKeyboardHeightFromKeyboardNotification(notification: notification) else {
            return
        }
        
        let lastKeyboardHeight: Double = keyboardHeight
        
        log(string: "  lastKeyboardHeight: \(lastKeyboardHeight)")
        log(string: "  newKeyboardHeight: \(newKeyboardHeight)")
        
        if lastKeyboardHeight != newKeyboardHeight {
            
            keyboardHeight = newKeyboardHeight
            
            if sendNotificationIfKeyboardHeightChanged {
                keyboardHeightDidChangeSignal.accept(value: keyboardHeight)
            }
        }
    }
}

// MARK: - NotificationHandler

extension KeyboardNotificationObserver: NotificationHandler {
    func handleNotification(notification: Notification) {
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            log(string:"\nKeyboardNotificationObserver: UIKeyboardWillShow()")
            
            if let keyboardInfo = notification.userInfo {
                if let keyboardAnimationDurationNumber = keyboardInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
                    keyboardAnimationDuration = keyboardAnimationDurationNumber.doubleValue
                }
            }
            
            if !keyboardIsUp {
                
                keyboardState = .willShow
                
                let newKeyboardHeight: Double = getKeyboardHeightFromKeyboardNotification(notification: notification) ?? keyboardHeight
                
                updateKeyboardHeightIfNeededFromKeyboardNotification(
                    notification: notification,
                    sendNotificationIfKeyboardHeightChanged: true
                )
                
                keyboardStateDidChangeSignal.accept(value: KeyboardStateChange(keyboardState: .willShow, keyboardHeight: newKeyboardHeight))
            }
        }
        else if notification.name == UIResponder.keyboardDidShowNotification {
            
            log(string:"\nKeyboardNotificationObserver: UIKeyboardDidShow()")
            
            keyboardIsUp = true
            
            let currentState: KeyboardState = keyboardState
            
            keyboardState = .didShow
                        
            if currentState == .willShow {
                keyboardStateDidChangeSignal.accept(value: KeyboardStateChange(keyboardState: .didShow, keyboardHeight: keyboardHeight))
            }
        }
        else if notification.name == UIResponder.keyboardWillHideNotification {
            
            log(string:"\nKeyboardNotificationObserver: UIKeyboardWillHide()")
            
            keyboardIsUp = false
            
            keyboardState = .willHide
            
            keyboardStateDidChangeSignal.accept(value: KeyboardStateChange(keyboardState: .willHide, keyboardHeight: keyboardHeight))
        }
        else if notification.name == UIResponder.keyboardDidHideNotification {
            
            log(string: "\nKeyboardNotificationObserver: UIKeyboardDidHide()")
            
            keyboardState = .didHide
            
            keyboardStateDidChangeSignal.accept(value: KeyboardStateChange(keyboardState: .didHide, keyboardHeight: keyboardHeight))
        }
        else if notification.name == UIResponder.keyboardDidChangeFrameNotification {
            
            log(string:"\nKeyboardNotificationObserver: UIKeyboardDidChangeFrame()")
            
            if keyboardIsUp {
                updateKeyboardHeightIfNeededFromKeyboardNotification(
                    notification: notification,
                    sendNotificationIfKeyboardHeightChanged: true
                )
            }
        }
    }
}
