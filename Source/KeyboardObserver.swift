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
    
    public private(set) var keyboardOrientation: UIDeviceOrientation = .portrait
    public private(set) var keyboardHeight: CGFloat = 0
    public private(set) var keyboardAnimationDuration: Double = 0
    public private(set) var keyboardIsUp: Bool = false
    public private(set) var isObserving: Bool = false
    
    public weak var delegate: KeyboardObserverDelegate?
    
    public var loggingEnabled: Bool = false
    
    // MARK: - Life Cycle
    
    override init()
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
    
    public var isPortrait: Bool {
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        return (orientation == .portrait || orientation == .portraitUpsideDown) || (orientation  != .landscapeLeft && orientation != .landscapeRight)
    }
    
    public var isLandscape: Bool {
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        return orientation  == .landscapeLeft || orientation == .landscapeRight
    }
    
    private func log(string: String)
    {
        if (self.loggingEnabled)
        {
            print(string)
        }
    }
    
    private var keyMaxKeyboardHeightInPortrait: String {
        return "KeyboardObserver.maxKeyboardHeightInPortrait"
    }
    
    public var maxKeyboardHeightInPortrait: CGFloat {
        var height: CGFloat = 0
        if let maxHeight = UserDefaults.getData(key: self.keyMaxKeyboardHeightInPortrait) as? NSNumber {
            height = CGFloat(maxHeight.floatValue)
        }
        self.log(string: "  fetching max keyboard height in portrait: \(height)")
        return height
    }
    
    private var keyMaxKeyboardHeightInLandscape: String {
        return "KeyboardObserver.maxKeyboardHeightInLandscape"
    }
    
    public var maxKeyboardHeightInLandscape: CGFloat {
        var height: CGFloat = 0
        if let maxHeight = UserDefaults.getData(key: self.keyMaxKeyboardHeightInLandscape) as? NSNumber {
            height = CGFloat(maxHeight.floatValue)
        }
        self.log(string: "  fetching max keyboard height in landscape: \(height)")
        return height
    }
}

// MARK: - NotificationHandler

extension KeyboardObserver: NotificationHandler
{
    @objc func handleNotification(notification: Notification)
    {
        if (notification.name == UIResponder.keyboardWillShowNotification)
        {
            self.keyboardIsUp = true
            
            self.log(string:"\nKeyboardObserver: UIKeyboardWillShow()")
            
            if let delegate = self.delegate
            {
                delegate.keyboardDidChangeState(keyboardObserver: self, keyboardState: .willShow)
            }
            
            var invalidateKeyboardHeight: Bool = false
            let lastKeyboardHeight: CGFloat = self.keyboardHeight
            
            if let keyboardInfo = notification.userInfo
            {
                if let keyboardAnimationDurationNumber = keyboardInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
                {
                    self.keyboardAnimationDuration = keyboardAnimationDurationNumber.doubleValue
                }
                
                if let keyboardFrameValue = keyboardInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue
                {
                    let newKeyboardOrientation: UIDeviceOrientation = UIDevice.current.orientation
                    let newKeyboardHeight: CGFloat = keyboardFrameValue.cgRectValue.size.height
                    
                    self.log(string: "  isPortrait: \(self.isPortrait)")
                    self.log(string: "  isLandscape: \(self.isLandscape)")
                    self.log(string: "  keyboardHeight: \(newKeyboardHeight)")
                    
                    //update max keyboard height for portrait and landscape
                    if (self.isPortrait && newKeyboardHeight > self.maxKeyboardHeightInPortrait)
                    {
                        self.log(string: "  saving new max keyboard height in portrait: \(newKeyboardHeight)")
                        UserDefaults.saveData(data: NSNumber(value: Float(newKeyboardHeight)), key: self.keyMaxKeyboardHeightInPortrait)
                    }
                    else if (self.isLandscape && newKeyboardHeight > self.maxKeyboardHeightInLandscape)
                    {
                        self.log(string: "  saving new max keyboard height in landscape: \(newKeyboardHeight)")
                        UserDefaults.saveData(data: NSNumber(value: Float(newKeyboardHeight)), key: self.keyMaxKeyboardHeightInLandscape)
                    }
                    
                    //check for keyboard invalidation
                    if (newKeyboardOrientation != self.keyboardOrientation)
                    {
                        invalidateKeyboardHeight = true
                        self.keyboardHeight = newKeyboardHeight
                    }
                    else if (newKeyboardOrientation == self.keyboardOrientation && newKeyboardHeight > self.keyboardHeight)
                    {
                        invalidateKeyboardHeight = true
                        self.keyboardHeight = newKeyboardHeight
                    }
                    
                    //clamp keyboard height to max keyboard height based on orientation
                    if (self.isPortrait && self.keyboardHeight < self.maxKeyboardHeightInPortrait)
                    {
                        invalidateKeyboardHeight = true
                        self.keyboardHeight = self.maxKeyboardHeightInPortrait
                    }
                    else if (self.isLandscape && self.keyboardHeight < self.maxKeyboardHeightInLandscape)
                    {
                        invalidateKeyboardHeight = true
                        self.keyboardHeight = self.maxKeyboardHeightInLandscape
                    }
                    
                    self.log(string:"  newKeyboardOrientation: \(newKeyboardOrientation.rawValue)")
                    self.log(string:"  newKeyboardHeight: \(newKeyboardHeight)")
                    self.log(string:"  maxKeyboardHeightInPortrait: \(self.maxKeyboardHeightInPortrait)")
                    self.log(string:"  maxKeyboardHeightInLandscape: \(self.maxKeyboardHeightInLandscape)")
                    self.log(string:"  invalidateKeyboardHeight: \(invalidateKeyboardHeight)")
                    self.log(string:"  self.keyboardOrientation: \(self.keyboardOrientation.rawValue)")
                    self.log(string:"  self.keyboardHeight: \(self.keyboardHeight)")
                    self.log(string:"  lastKeyboardHeight: \(lastKeyboardHeight)")
                    
                    self.keyboardOrientation = newKeyboardOrientation
                }
            }
            
            if (invalidateKeyboardHeight)
            {
                if let delegate = self.delegate
                {
                    delegate.keyboardDidInvalidateKeyboardHeight(keyboardObserver: self, keyboardHeight: self.keyboardHeight)
                }
            }
        }
        else if (notification.name == UIResponder.keyboardDidShowNotification)
        {
            self.log(string:"\nKeyboardObserver: UIKeyboardDidShow()")
            
            if let delegate = self.delegate
            {
                delegate.keyboardDidChangeState(keyboardObserver: self, keyboardState: .didShow)
            }
        }
        else if (notification.name == UIResponder.keyboardWillHideNotification)
        {
            self.log(string:"\nKeyboardObserver: UIKeyboardWillHide()")
            
            if let delegate = self.delegate
            {
                delegate.keyboardDidChangeState(keyboardObserver: self, keyboardState: .willHide)
            }
        }
        else if (notification.name == UIResponder.keyboardDidHideNotification)
        {
            self.log(string: "\nKeyboardObserver: UIKeyboardDidHide()")
            
            self.keyboardIsUp = false
            
            if let delegate = self.delegate
            {
                delegate.keyboardDidChangeState(keyboardObserver: self, keyboardState: .didHide)
            }
        }
    }
}
