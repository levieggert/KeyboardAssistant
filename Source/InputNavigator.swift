//
//  Created by Levi Eggert.
//  Copyright © 2015 Levi Eggert. All rights reserved.
//

import UIKit

public protocol InputNavigatorDelegate: class
{
    func inputNavigatorFocusChanged(inputNavigator: InputNavigator, inputItem: UIView?)
}

public class InputNavigator: NSObject
{
    // MARK: - Properties
    
    public private(set) var inputItems: [UIView] = Array()
    public private(set) var shouldSetInputDelegates: Bool = true
    
    public var shouldLayoutIfNeededOnDidEndEditing: Bool = false
    
    public weak var delegate: InputNavigatorDelegate?
    
    // MARK: - Life Cycle
    
    required init(allowToSetInputDelegates: Bool)
    {
        super.init()
        
        self.shouldSetInputDelegates = allowToSetInputDelegates
    }
    
    deinit
    {
        
    }
    
    // MARK: - Navigation
    
    public func gotoNextItem()
    {
        if let focusedItem = self.focusedItem
        {
            self.gotoNextItem(fromInputItem: focusedItem)
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
    
    public func getNextInputItem(inputItem: UIView) -> UIView?
    {
        if let index = self.inputItems.index(of: inputItem)
        {
            let nextIndex: Int = index + 1
            
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

// MARK: - UITextFieldDelegate

extension InputNavigator: UITextFieldDelegate
{
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
    public func textViewDidBeginEditing(_ textView: UITextView)
    {
        self.focusedItem = textView
    }
}
