//
//  Created by Levi Eggert.
//  Copyright © 2017 Levi Eggert. All rights reserved.
//

import UIKit

public protocol InputNavigatorDelegate: class {
    func inputNavigatorFocusChanged(inputNavigator: InputNavigator, inputItem: UIView?)
}

public class InputNavigator: NSObject {
    
    public enum NavigatorType {
        case defaultController
        case controller
        case customAccessoryView
        case keyboard
        case keyboardAndDefaultController
        case keyboardAndController
        case keyboardAndCustomAccessoryView
        
        public static var allTypes: [InputNavigator.NavigatorType] {
            return [.defaultController, .controller, .customAccessoryView, .keyboard, .keyboardAndDefaultController, .keyboardAndController, .keyboardAndCustomAccessoryView]
        }
    }
    
    public enum InputItemType {
        case textField
        case textView
        case bothTextFieldAndTextView
    }
    
    // MARK: - Properties
    
    public private(set) var accessoryController: InputNavigatorAccessoryController?
    public private(set) var customAccessoryView: UIView?
    public private(set) var inputItems: [UIView] = Array()
    public private(set) var type: InputNavigator.NavigatorType = .defaultController
    public private(set) var shouldUseKeyboardReturnKeyToNavigate: Bool = false
    public private(set) var shouldSetTextFieldDelegates: Bool = false
    public private(set) var shouldLoopAccessoryControllerNavigation: Bool = true
    public private(set) var didAddNotifications: Bool = false
    
    public weak var delegate: InputNavigatorDelegate?
    
    // MARK: - Life Cycle
    
    private init(shouldUseKeyboardReturnKeyToNavigate: Bool, shouldSetTextFieldDelegates: Bool?, accessoryController: InputNavigatorAccessoryController?, customAccessoryView: UIView?) {
        
        super.init()
        
        self.shouldUseKeyboardReturnKeyToNavigate = shouldUseKeyboardReturnKeyToNavigate
        
        if (shouldUseKeyboardReturnKeyToNavigate) {
            self.shouldSetTextFieldDelegates = true
            if let shouldSetTextFieldDelegates = shouldSetTextFieldDelegates {
                self.shouldSetTextFieldDelegates = shouldSetTextFieldDelegates
            }
        }
        else {
            self.shouldSetTextFieldDelegates = false
        }
        
        if var accessoryController = accessoryController {
            self.accessoryController = accessoryController
            accessoryController.buttonDelegate = self
        }
        else if let customAccessoryView = customAccessoryView {
            self.customAccessoryView = customAccessoryView
        }
    }
    
    static public func createWithDefaultController() -> InputNavigator {
        let navigator = InputNavigator(
            shouldUseKeyboardReturnKeyToNavigate: false,
            shouldSetTextFieldDelegates: false,
            accessoryController: DefaultNavigationView(),
            customAccessoryView: nil
        )
        navigator.type = .defaultController
        return navigator
    }
    
    static public func createWithController(accessoryController: InputNavigatorAccessoryController) -> InputNavigator {
        let navigator = InputNavigator(
            shouldUseKeyboardReturnKeyToNavigate: false,
            shouldSetTextFieldDelegates: false,
            accessoryController: accessoryController,
            customAccessoryView: nil
        )
        navigator.type = .controller
        return navigator
    }
    
    static public func createWithCustomAccessoryView(accessoryView: UIView) -> InputNavigator {
        let navigator = InputNavigator(
            shouldUseKeyboardReturnKeyToNavigate: false,
            shouldSetTextFieldDelegates: false,
            accessoryController: nil,
            customAccessoryView: accessoryView
        )
        navigator.type = .customAccessoryView
        return navigator
    }
    
    static public func createWithKeyboardNavigation(shouldSetTextFieldDelegates: Bool) -> InputNavigator {
        let navigator = InputNavigator(
            shouldUseKeyboardReturnKeyToNavigate: true,
            shouldSetTextFieldDelegates: shouldSetTextFieldDelegates,
            accessoryController: nil,
            customAccessoryView: nil
        )
        navigator.type = .keyboard
        return navigator
    }
    
    static public func createWithKeyboardNavigationAndDefaultController(shouldSetTextFieldDelegates: Bool) -> InputNavigator {
        let navigator = InputNavigator(
            shouldUseKeyboardReturnKeyToNavigate: true,
            shouldSetTextFieldDelegates: shouldSetTextFieldDelegates,
            accessoryController: DefaultNavigationView(),
            customAccessoryView: nil
        )
        navigator.type = .keyboardAndDefaultController
        return navigator
    }
    
    static public func createWithKeyboardNavigation(shouldSetTextFieldDelegates: Bool, andController: InputNavigatorAccessoryController) -> InputNavigator {
        let navigator = InputNavigator(
            shouldUseKeyboardReturnKeyToNavigate: true,
            shouldSetTextFieldDelegates: true,
            accessoryController: andController,
            customAccessoryView: nil
        )
        navigator.type = .keyboardAndController
        return navigator
    }
    
    static public func createWithKeyboardNavigation(shouldSetTextFieldDelegates: Bool, andCustomAccessoryView: UIView) -> InputNavigator {
        let navigator = InputNavigator(
            shouldUseKeyboardReturnKeyToNavigate: true,
            shouldSetTextFieldDelegates: true,
            accessoryController: nil,
            customAccessoryView: andCustomAccessoryView
        )
        navigator.type = .keyboardAndCustomAccessoryView
        return navigator
    }
    
    deinit {
        removeInputItems()
        removeNotifications()
    }
    
    public func addNotifications() {
        if (!didAddNotifications) {
            didAddNotifications = true
            
            addNotification(name: UITextField.textDidBeginEditingNotification)
            addNotification(name: UITextView.textDidBeginEditingNotification)
        }
    }
    
    public func removeNotifications() {
        if (didAddNotifications) {
            didAddNotifications = false
                        
            removeNotification(name: UITextField.textDidBeginEditingNotification)
            removeNotification(name: UITextView.textDidBeginEditingNotification)
        }
    }
    
    public var defaultController: DefaultNavigationView? {
        return accessoryController as? DefaultNavigationView
    }
    
    public var keyboardNavigationEnabled: Bool {
        return type == .keyboard || type == .keyboardAndDefaultController || type == .keyboardAndController || type == .keyboardAndCustomAccessoryView
    }
    
    // MARK: - Navigation
    
    public func gotoPreviousItem(shouldLoop: Bool) {
        if let focusedItem = focusedItem {
            gotoPreviousItem(fromInputItem: focusedItem, shouldLoop: shouldLoop)
        }
    }
    
    public func gotoNextItem(shouldLoop: Bool) {
        if let focusedItem = focusedItem {
            gotoNextItem(fromInputItem: focusedItem, shouldLoop: shouldLoop)
        }
    }
    
    public func gotoPreviousItem(fromInputItem: UIView, shouldLoop: Bool) {
        if let prevInputItem = getPreviousInputItem(inputItem: fromInputItem, shouldLoop: shouldLoop) {
            if let textField = prevInputItem as? UITextField {
                textField.becomeFirstResponder()
            }
            else if let textView = prevInputItem as? UITextView {
                textView.becomeFirstResponder()
            }
        }
    }
    
    public func gotoNextItem(fromInputItem: UIView, shouldLoop: Bool) {
        if let nextInputItem = getNextInputItem(inputItem: fromInputItem, shouldLoop: shouldLoop) {
            if let textField = nextInputItem as? UITextField {
                textField.becomeFirstResponder()
            }
            else if let textView = nextInputItem as? UITextView {
                textView.becomeFirstResponder()
            }
        }
    }
    
    // MARK: - ViewController Input Items
    
    public static func getInputItems(from: UIViewController, itemType: InputItemType) -> [UIView] {
        let rootView: UIView = from.view
        var inputItems: [UIView] = Array()
        recurseView(view: rootView, inputItems: &inputItems, itemType: itemType)
        inputItems = InputNavigator.sortInputItems(inputItems: inputItems, from: from)
        return inputItems
    }
    
    public static func sortInputItems(inputItems: [UIView], from: UIViewController) -> [UIView] {
        
        let rootView: UIView = from.view
        
        let items: [UIView] = inputItems.sorted { (this: UIView, that: UIView) -> Bool in
            
            var thisPosition: CGPoint = this.convert(this.frame.origin, to: rootView)
            thisPosition.x = thisPosition.x - this.frame.origin.x
            thisPosition.y = thisPosition.y - this.frame.origin.y
            
            var thatPosition: CGPoint = that.convert(that.frame.origin, to: rootView)
            thatPosition.x = thatPosition.x - that.frame.origin.x
            thatPosition.y = thatPosition.y - that.frame.origin.y
            
            if (thisPosition.y < thatPosition.y) {
                return true
            }
            else if (thisPosition.y == thatPosition.y) {
                if (thisPosition.x < thatPosition.x) {
                    return true
                }
            }
            return false
        }
        
        return items
    }
    
    private static func recurseView(view: UIView, inputItems: inout [UIView], itemType: InputItemType) {
        
        switch (itemType) {
            
        case .textField:
            if (view is UITextField) {
                inputItems.append(view)
            }
            
        case .textView:
            if (view is UITextView) {
                inputItems.append(view)
            }
            
        case .bothTextFieldAndTextView:
            if (view is UITextField || view is UITextView) {
                inputItems.append(view)
            }
        }
        
        for view in view.subviews {
            InputNavigator.recurseView(view: view, inputItems: &inputItems, itemType: itemType)
        }
    }
    
    // MARK: - Input Items
    
    public var focusedItem: UIView? {
        didSet(oldValue) {
            
            delegate?.inputNavigatorFocusChanged(inputNavigator: self, inputItem: focusedItem)
            
            let prevValueExists: Bool = oldValue != nil
            let newValueExists: Bool = focusedItem != nil
            
            if (prevValueExists && !newValueExists) {
                if let prevItem = oldValue {
                    prevItem.resignFirstResponder()
                }
            }
        }
    }
    
    public func indexIsInBounds(index: Int) -> Bool {
        return index >= 0 && index < inputItems.count
    }
    
    public func getPreviousInputItem(inputItem: UIView, shouldLoop: Bool) -> UIView? {
        
        if let index = inputItems.firstIndex(of: inputItem) {
            var prevIndex: Int = index - 1
            
            if shouldLoop && prevIndex < 0 {
                prevIndex = inputItems.count - 1
            }
            
            if indexIsInBounds(index: prevIndex) {
                return inputItems[prevIndex]
            }
        }
        
        return nil
    }
    
    public func getNextInputItem(inputItem: UIView, shouldLoop: Bool) -> UIView? {
        
        if let index = inputItems.firstIndex(of: inputItem) {
            var nextIndex: Int = index + 1
            
            if shouldLoop && nextIndex > inputItems.count - 1 {
                nextIndex = 0
            }
            
            if indexIsInBounds(index: nextIndex) {
                return inputItems[nextIndex]
            }
        }
        
        return nil
    }
    
    public func addInputItem(inputItem: UIView) {
        
        if !inputItems.contains(inputItem) {
            
            inputItems.append(inputItem)
            
            if let textField = inputItem as? UITextField {
                if shouldUseKeyboardReturnKeyToNavigate && shouldSetTextFieldDelegates {
                    textField.delegate = self
                }
                if let accessoryController = accessoryController {
                    textField.inputAccessoryView = accessoryController.controllerView
                }
                else if let customAccessoryView = customAccessoryView {
                    textField.inputAccessoryView = customAccessoryView
                }
            }
            else if let textView = inputItem as? UITextView {
                if let accessoryController = accessoryController {
                    textView.inputAccessoryView = accessoryController.controllerView
                }
                else if let customAccessoryView = customAccessoryView {
                    textView.inputAccessoryView = customAccessoryView
                }
            }
        }
    }
    
    public func removeInputItem(inputItem: UIView) {
        
        if let index = inputItems.firstIndex(of: inputItem) {
            if let textField = inputItem as? UITextField {
                textField.inputAccessoryView = nil
                
                if keyboardNavigationEnabled {
                    textField.returnKeyType = .default
                }
            }
            else if let textView = inputItem as? UITextView {
                textView.inputAccessoryView = nil
            }
            
            if shouldUseKeyboardReturnKeyToNavigate && shouldSetTextFieldDelegates {
                if let textField = inputItem as? UITextField {
                    textField.delegate = nil
                }
            }
            
            inputItems.remove(at: index)
        }
    }
    
    public func addInputItems(from: UIViewController, itemType: InputItemType) {
        addInputItems(inputItems: InputNavigator.getInputItems(from: from, itemType: itemType))
    }
    
    public func addInputItems(inputItems: [UIView]) {
        for inputItem in inputItems {
            addInputItem(inputItem: inputItem)
        }
    }
    
    public func removeInputItems() {
        for inputItem in inputItems.reversed() {
            removeInputItem(inputItem: inputItem)
        }
    }
}

// MARK: - NotificationHandler

extension InputNavigator: NotificationHandler
{
    func handleNotification(notification: Notification) {
        if notification.name == UITextField.textDidBeginEditingNotification {
            if let textField = notification.object as? UITextField {
                if inputItems.contains(textField) {
                    
                    focusedItem = textField
                    
                    if shouldUseKeyboardReturnKeyToNavigate {
                        let isLastInput: Bool = textField == inputItems.last
                        if !isLastInput {
                            textField.returnKeyType = .next
                        }
                        else {
                            textField.returnKeyType = .done
                        }
                    }
                }
            }
        }
        else if notification.name == UITextView.textDidBeginEditingNotification {
            if let textView = notification.object as? UITextView {
                if inputItems.contains(textView) {
                    focusedItem = textView
                }
            }
        }
    }
}

// MARK: - InputNavigatorAccessoryControllerDelegate

extension InputNavigator: InputNavigatorAccessoryControllerDelegate {
    public func inputNavigatorAccessoryControllerPreviousButtonTapped(accessoryController: InputNavigatorAccessoryController) {
        gotoPreviousItem(shouldLoop: shouldLoopAccessoryControllerNavigation)
    }
    
    public func inputNavigatorAccessoryControllerNextButtonTapped(accessoryController: InputNavigatorAccessoryController) {
        gotoNextItem(shouldLoop: shouldLoopAccessoryControllerNavigation)
    }
    
    public func inputNavigatorAccessoryControllerDoneButtonTapped(accessoryController: InputNavigatorAccessoryController) {
        focusedItem = nil
    }
}

// MARK: - UITextFieldDelegate

extension InputNavigator: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == inputItems.last {
            focusedItem = nil
        }
        else {
            gotoNextItem(fromInputItem: textField, shouldLoop: false)
        }
        
        return true
    }
}
