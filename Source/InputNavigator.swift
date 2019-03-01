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
    // MARK: - Properties
    
    public private(set) var accessoryController: InputNavigatorAccessoryController?
    public private(set) var inputItems: [UIView] = Array()
    public private(set) var shouldSetInputDelegates: Bool = true
    public private(set) var shouldLoopNavigation: Bool = false
    
    public var shouldLayoutIfNeededOnDidEndEditing: Bool = false
    public var shouldDisableAutoCorrection: Bool = false
    
    public weak var delegate: InputNavigatorDelegate?
    
    // MARK: - Life Cycle
    
    public required init(allowToSetInputDelegates: Bool, accessoryController: InputNavigatorAccessoryController?)
    {
        super.init()
        
        self.shouldSetInputDelegates = allowToSetInputDelegates
                
        if var controller = accessoryController
        {
            self.accessoryController = controller
            controller.delegate = self
            self.shouldLoopNavigation = true
        }
    }
    
    deinit
    {
        
    }
    
    // TODO: Make a note of using this function in the ReadMe known issues for disabling predictive text bar.
    public func disableAutoCorrection(disable: Bool)
    {
        self.shouldDisableAutoCorrection = disable
        
        if (disable)
        {
            print("\nWARNING: InputNavigator: disableAutoCorrection()")
            print("  Disabling auto correction will remove the predictive text from the device keyboard.  Disabling auto correction solves issues with obtaining the correct keyboard height when the keyboard changes to a keyboard with secure text entry or keyboards that don't use predictive text.")
        }
    }
    
    // MARK: - Navigation
    
    public func allowNavigationToLoop(loop: Bool)
    {
        if let _ = self.accessoryController
        {
            self.shouldLoopNavigation = loop
        }
        else
        {
            self.shouldLoopNavigation = false
            print("\nWARNING: InputNavigator: allowNavigationToLoop()")
            print("  Navigation is only allowed to loop on InputNavigator's with an accessory controller.")
        }
    }
    
    public func gotoPreviousItem()
    {
        if let focusedItem = self.focusedItem
        {
            self.gotoPreviousItem(fromInputItem: focusedItem)
        }
    }
    
    public func gotoNextItem()
    {
        if let focusedItem = self.focusedItem
        {
            self.gotoNextItem(fromInputItem: focusedItem)
        }
    }
    
    public func gotoPreviousItem(fromInputItem: UIView)
    {
        if let prevInputItem = self.getPreviousInputItem(inputItem: fromInputItem)
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
    
    public func gotoNextItem(fromInputItem: UIView)
    {
        if let nextInputItem = self.getNextInputItem(inputItem: fromInputItem)
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
        else if (fromInputItem == self.inputItems.last)
        {
            self.focusedItem = nil
        }
    }
    
    // MARK: - ViewController Input Items
    
    public static func getInputItems(from: UIViewController) -> [UIView]
    {
        let rootView: UIView = from.view
        
        var inputItems: [UIView] = Array()
        
        self.recurseView(view: rootView, inputItems: &inputItems)
        
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
    
    private static func recurseView(view: UIView, inputItems: inout [UIView])
    {        
        if (view is UITextField || view is UITextView)
        {
            inputItems.append(view)
        }
        
        for view in view.subviews
        {
            InputNavigator.recurseView(view: view, inputItems: &inputItems)
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
    
    public func getPreviousInputItem(inputItem: UIView) -> UIView?
    {
        if let index = self.inputItems.index(of: inputItem)
        {
            var prevIndex: Int = index - 1
            
            if (self.shouldLoopNavigation && prevIndex < 0)
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
    
    public func getNextInputItem(inputItem: UIView) -> UIView?
    {
        if let index = self.inputItems.index(of: inputItem)
        {
            var nextIndex: Int = index + 1
            
            if (self.shouldLoopNavigation && nextIndex > self.inputItems.count - 1)
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
    
    public func addAllInputItems(fromView: UIView)
    {
        // TODO: Loop through view hierarchy and all all textfields and textviews.
    }
    
    public func addInputItem(inputItem: UIView)
    {
        if (!self.inputItems.contains(inputItem))
        {
            self.inputItems.append(inputItem)
                        
            if (self.shouldSetInputDelegates)
            {
                if let textField = inputItem as? UITextField
                {
                    textField.delegate = self
                }
                else if let textView = inputItem as? UITextView
                {
                    textView.delegate = self
                }
            }
        }
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
        if (self.shouldSetInputDelegates)
        {
            for inputItem in self.inputItems
            {
                if let textField = inputItem as? UITextField
                {
                    textField.delegate = nil
                }
                else if let textView = inputItem as? UITextView
                {
                    textView.delegate = nil
                }
            }
        }
        
        self.inputItems.removeAll()
    }
}

// MARK: - InputNavigatorAccessoryControllerDelegate

extension InputNavigator: InputNavigatorAccessoryControllerDelegate
{
    public func inputNavigatorAccessoryControllerPreviousButtonTapped(accessoryController: InputNavigatorAccessoryController)
    {
        self.gotoPreviousItem()
    }
    
    public func inputNavigatorAccessoryControllerNextButtonTapped(accessoryController: InputNavigatorAccessoryController)
    {
        self.gotoNextItem()
    }
    
    public func inputNavigatorAccessoryControllerDoneButtonTapped(accessoryController: InputNavigatorAccessoryController)
    {
        self.focusedItem = nil
    }
}

// MARK: - UITextFieldDelegate

extension InputNavigator: UITextFieldDelegate
{
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if let accessoryView = self.accessoryController?.accessoryView
        {
            textField.inputAccessoryView = accessoryView
        }
        
        if (self.shouldDisableAutoCorrection)
        {
            textField.autocorrectionType = .no // Setting this disables predictive keyboard and issues with keyboard height.
        }
        
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.focusedItem = textField
        
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
    
    public func textFieldDidEndEditing(_ textField: UITextField)
    {
        if (self.shouldLayoutIfNeededOnDidEndEditing)
        {
            textField.layoutIfNeeded()
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.gotoNextItem(fromInputItem: textField)
        
        return true
    }
}

// MARK: - UITextViewDelegate

extension InputNavigator: UITextViewDelegate
{
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        if let accessoryView = self.accessoryController?.accessoryView
        {
            textView.inputAccessoryView = accessoryView
        }
        
        if (self.shouldDisableAutoCorrection)
        {
            textView.autocorrectionType = .no // Setting this disables predictive keyboard and issues with keyboard height.
        }
        
        return true
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView)
    {
        self.focusedItem = textView
    }
}
