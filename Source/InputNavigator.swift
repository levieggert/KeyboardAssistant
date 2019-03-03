//
//  Created by Levi Eggert.
//  Copyright © 2017 Levi Eggert. All rights reserved.
//

import UIKit

public protocol InputNavigatorDelegate: class
{
    func inputNavigatorFocusChanged(inputNavigator: InputNavigator, inputItem: UIView?)
}

public class InputNavigator: NSObject
{
    public enum InputItemType { case textField; case textView; case bothTextFieldAndTextView; }
    
    // MARK: - Properties
    
    public private(set) var accessoryController: InputNavigatorAccessoryController?
    public private(set) var customAccessoryView: UIView?
    public private(set) var inputItems: [UIView] = Array()
    public private(set) var shouldUseKeyboardReturnKeyToNavigate: Bool = false
    public private(set) var shouldSetTextFieldDelegates: Bool = false
    public private(set) var shouldLoopAccessoryControllerNavigation: Bool = true
    public private(set) var didAddNotifications: Bool = false
    
    public weak var delegate: InputNavigatorDelegate?
    
    // MARK: - Life Cycle
    
    private init(shouldUseKeyboardReturnKeyToNavigate: Bool, shouldSetTextFieldDelegates: Bool?, accessoryController: InputNavigatorAccessoryController?, customAccessoryView: UIView?)
    {
        super.init()
        
        self.shouldUseKeyboardReturnKeyToNavigate = shouldUseKeyboardReturnKeyToNavigate
        
        if (self.shouldUseKeyboardReturnKeyToNavigate)
        {
            self.shouldSetTextFieldDelegates = true
            
            if let shouldSetTextFieldDelegates = shouldSetTextFieldDelegates
            {
                self.shouldSetTextFieldDelegates = shouldSetTextFieldDelegates
            }
        }
        else
        {
            self.shouldSetTextFieldDelegates = false
        }
        
        if (!self.shouldUseKeyboardReturnKeyToNavigate && self.accessoryController == nil && self.customAccessoryView == nil)
        {
            self.accessoryController = DefaultNavigationView()
        }
        
        if var accessoryController = accessoryController
        {
            self.accessoryController = accessoryController
            accessoryController.delegate = self
        }
        else if let customAccessoryView = customAccessoryView
        {
            self.customAccessoryView = customAccessoryView
        }
    }
    
    static public func createWithDefaultController() -> InputNavigator
    {
        return InputNavigator(shouldUseKeyboardReturnKeyToNavigate: false, shouldSetTextFieldDelegates: false, accessoryController: DefaultNavigationView(), customAccessoryView: nil)
    }
    
    static public func createWithController(accessoryController: InputNavigatorAccessoryController) -> InputNavigator
    {
        return InputNavigator(shouldUseKeyboardReturnKeyToNavigate: false, shouldSetTextFieldDelegates: false, accessoryController: accessoryController, customAccessoryView: nil)
    }
    
    static public func createWithCustomAccessoryView(accessoryView: UIView) -> InputNavigator
    {
        return InputNavigator(shouldUseKeyboardReturnKeyToNavigate: false, shouldSetTextFieldDelegates: false, accessoryController: nil, customAccessoryView: accessoryView)
    }
    
    static public func createWithKeyboardNavigation(shouldSetTextFieldDelegates: Bool) -> InputNavigator
    {
        return InputNavigator(shouldUseKeyboardReturnKeyToNavigate: true, shouldSetTextFieldDelegates: shouldSetTextFieldDelegates, accessoryController: nil, customAccessoryView: nil)
    }
    
    static public func createWithKeyboardNavigationAndDefaultController(shouldSetTextFieldDelegates: Bool) -> InputNavigator
    {
        return InputNavigator(shouldUseKeyboardReturnKeyToNavigate: true, shouldSetTextFieldDelegates: shouldSetTextFieldDelegates, accessoryController: DefaultNavigationView(), customAccessoryView: nil)
    }
    
    static public func createWithKeyboardNavigation(shouldSetTextFieldDelegates: Bool, andController: InputNavigatorAccessoryController) -> InputNavigator
    {
        return InputNavigator(shouldUseKeyboardReturnKeyToNavigate: true, shouldSetTextFieldDelegates: true, accessoryController: andController, customAccessoryView: nil)
    }
    
    static public func createWithKeyboardNavigation(shouldSetTextFieldDelegates: Bool, andCustomAccessoryView: UIView) -> InputNavigator
    {
        return InputNavigator(shouldUseKeyboardReturnKeyToNavigate: true, shouldSetTextFieldDelegates: true, accessoryController: nil, customAccessoryView: andCustomAccessoryView)
    }
    
    deinit
    {
        self.removeNotifications()
    }
    
    public func addNotifications()
    {
        if (!self.didAddNotifications)
        {
            self.didAddNotifications = true
            
            self.addNotification(name: UITextField.textDidBeginEditingNotification)
            self.addNotification(name: UITextView.textDidBeginEditingNotification)
        }
    }
    
    public func removeNotifications()
    {
        if (self.didAddNotifications)
        {
            self.didAddNotifications = false
                        
            self.removeNotification(name: UITextField.textDidBeginEditingNotification)
            self.removeNotification(name: UITextView.textDidBeginEditingNotification)
        }
    }
    
    public var defaultController: DefaultNavigationView? {
        return self.accessoryController as? DefaultNavigationView
    }
    
    // MARK: - Navigation
    
    public func gotoPreviousItem(shouldLoop: Bool)
    {
        if let focusedItem = self.focusedItem
        {
            self.gotoPreviousItem(fromInputItem: focusedItem, shouldLoop: shouldLoop)
        }
    }
    
    public func gotoNextItem(shouldLoop: Bool)
    {
        if let focusedItem = self.focusedItem
        {
            self.gotoNextItem(fromInputItem: focusedItem, shouldLoop: shouldLoop)
        }
    }
    
    public func gotoPreviousItem(fromInputItem: UIView, shouldLoop: Bool)
    {
        if let prevInputItem = self.getPreviousInputItem(inputItem: fromInputItem, shouldLoop: shouldLoop)
        {
            if let textField = prevInputItem as? UITextField
            {
                textField.becomeFirstResponder()
            }
            else if let textView = prevInputItem as? UITextView
            {
                textView.becomeFirstResponder()
            }
        }
    }
    
    public func gotoNextItem(fromInputItem: UIView, shouldLoop: Bool)
    {
        if let nextInputItem = self.getNextInputItem(inputItem: fromInputItem, shouldLoop: shouldLoop)
        {
            if let textField = nextInputItem as? UITextField
            {
                textField.becomeFirstResponder()
            }
            else if let textView = nextInputItem as? UITextView
            {
                textView.becomeFirstResponder()
            }
        }
    }
    
    // MARK: - ViewController Input Items
    
    public static func getInputItems(from: UIViewController, itemType: InputItemType) -> [UIView]
    {
        let rootView: UIView = from.view
        
        var inputItems: [UIView] = Array()
        
        self.recurseView(view: rootView, inputItems: &inputItems, itemType: itemType)
        
        inputItems.sort { (this: UIView, that: UIView) -> Bool in
            
            var thisPosition: CGPoint = this.convert(this.frame.origin, to: rootView)
            thisPosition.x = thisPosition.x - this.frame.origin.x
            thisPosition.y = thisPosition.y - this.frame.origin.y
            
            var thatPosition: CGPoint = that.convert(that.frame.origin, to: rootView)
            thatPosition.x = thatPosition.x - that.frame.origin.x
            thatPosition.y = thatPosition.y - that.frame.origin.y
            
            if (thisPosition.y < thatPosition.y)
            {
                return true
            }
            else if (thisPosition.y == thatPosition.y)
            {
                if (thisPosition.x < thatPosition.x)
                {
                    return true
                }
            }
            
            return false
        }
        
        return inputItems
    }
    
    private static func recurseView(view: UIView, inputItems: inout [UIView], itemType: InputItemType)
    {
        switch (itemType)
        {
        case .textField:
            if (view is UITextField)
            {
                inputItems.append(view)
            }
            
        case .textView:
            if (view is UITextView)
            {
                inputItems.append(view)
            }
            
        case .bothTextFieldAndTextView:
            if (view is UITextField || view is UITextView)
            {
                inputItems.append(view)
            }
        }
        
        for view in view.subviews
        {
            InputNavigator.recurseView(view: view, inputItems: &inputItems, itemType: itemType)
        }
    }
    
    // MARK: - Input Items
    
    public var focusedItem: UIView? {
        
        didSet(oldValue)
        {
            if let delegate = self.delegate
            {
                delegate.inputNavigatorFocusChanged(inputNavigator: self, inputItem: self.focusedItem)
            }
            
            let prevValueExists: Bool = oldValue != nil
            let newValueExists: Bool = self.focusedItem != nil
            
            if (prevValueExists && !newValueExists)
            {
                if let prevItem = oldValue
                {
                    prevItem.resignFirstResponder()
                }
            }
        }
    }
    
    public func indexIsInBounds(index: Int) -> Bool
    {
        return index >= 0 && index < self.inputItems.count
    }
    
    public func getPreviousInputItem(inputItem: UIView, shouldLoop: Bool) -> UIView?
    {
        if let index = self.inputItems.index(of: inputItem)
        {
            var prevIndex: Int = index - 1
            
            if (shouldLoop && prevIndex < 0)
            {
                prevIndex = self.inputItems.count - 1
            }
            
            if (self.indexIsInBounds(index: prevIndex))
            {
                return self.inputItems[prevIndex]
            }
        }
        
        return nil
    }
    
    public func getNextInputItem(inputItem: UIView, shouldLoop: Bool) -> UIView?
    {
        if let index = self.inputItems.index(of: inputItem)
        {
            var nextIndex: Int = index + 1
            
            if (shouldLoop && nextIndex > self.inputItems.count - 1)
            {
                nextIndex = 0
            }
            
            if (self.indexIsInBounds(index: nextIndex))
            {
                return self.inputItems[nextIndex]
            }
        }
        
        return nil
    }
    
    public func addInputItem(inputItem: UIView)
    {
        if (!self.inputItems.contains(inputItem))
        {
            self.inputItems.append(inputItem)
            
            if let textField = inputItem as? UITextField
            {
                if (self.shouldUseKeyboardReturnKeyToNavigate && self.shouldSetTextFieldDelegates)
                {
                    textField.delegate = self
                }
                
                if let accessoryController = self.accessoryController
                {
                    textField.inputAccessoryView = accessoryController.controllerView
                }
                else if let customAccessoryView = self.customAccessoryView
                {
                    textField.inputAccessoryView = customAccessoryView
                }
            }
            else if let textView = inputItem as? UITextView
            {
                if let accessoryController = self.accessoryController
                {
                    textView.inputAccessoryView = accessoryController.controllerView
                }
                else if let customAccessoryView = self.customAccessoryView
                {
                    textView.inputAccessoryView = customAccessoryView
                }
            }
        }
    }
    
    public func removeInputItem(inputItem: UIView)
    {
        if let index = self.inputItems.index(of: inputItem)
        {
            if (self.shouldUseKeyboardReturnKeyToNavigate && self.shouldSetTextFieldDelegates)
            {
                if let textField = inputItem as? UITextField
                {
                    textField.delegate = nil
                }
            }
            
            self.inputItems.remove(at: index)
        }
    }
    
    public func addInputItems(from: UIViewController, itemType: InputItemType)
    {
        self.addInputItems(inputItems: InputNavigator.getInputItems(from: from, itemType: itemType))
    }
    
    public func addInputItems(inputItems: [UIView])
    {
        for inputItem in inputItems
        {
            self.addInputItem(inputItem: inputItem)
        }
    }
    
    public func removeInputItems()
    {        
        for inputItem in self.inputItems.reversed()
        {
            self.removeInputItem(inputItem: inputItem)
        }
    }
}

// MARK: - NotificationHandler

extension InputNavigator: NotificationHandler
{
    func handleNotification(notification: Notification)
    {
        if (notification.name == UITextField.textDidBeginEditingNotification)
        {
            if let textField = notification.object as? UITextField
            {
                if (self.inputItems.contains(textField))
                {
                    self.focusedItem = textField
                    
                    if (self.shouldUseKeyboardReturnKeyToNavigate)
                    {
                        let isLastInput: Bool = textField == self.inputItems.last
                        
                        if (!isLastInput)
                        {
                            textField.returnKeyType = .next
                        }
                        else
                        {
                            textField.returnKeyType = .done
                        }
                    }
                }
            }
        }
        else if (notification.name == UITextView.textDidBeginEditingNotification)
        {
            if let textView = notification.object as? UITextView
            {
                if (self.inputItems.contains(textView))
                {
                    self.focusedItem = textView
                }
            }
        }
    }
}

// MARK: - InputNavigatorAccessoryControllerDelegate

extension InputNavigator: InputNavigatorAccessoryControllerDelegate
{
    public func inputNavigatorAccessoryControllerPreviousButtonTapped(accessoryController: InputNavigatorAccessoryController)
    {
        self.gotoPreviousItem(shouldLoop: self.shouldLoopAccessoryControllerNavigation)
    }
    
    public func inputNavigatorAccessoryControllerNextButtonTapped(accessoryController: InputNavigatorAccessoryController)
    {
        self.gotoNextItem(shouldLoop: self.shouldLoopAccessoryControllerNavigation)
    }
    
    public func inputNavigatorAccessoryControllerDoneButtonTapped(accessoryController: InputNavigatorAccessoryController)
    {
        self.focusedItem = nil
    }
}

// MARK: - UITextFieldDelegate

extension InputNavigator: UITextFieldDelegate
{
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if (textField == self.inputItems.last)
        {
            self.focusedItem = nil
        }
        else
        {
            self.gotoNextItem(fromInputItem: textField, shouldLoop: false)
        }
        
        return true
    }
}
