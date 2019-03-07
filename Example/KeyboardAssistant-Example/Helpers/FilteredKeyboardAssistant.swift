//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

protocol FilteredKeyboardAssistant: FiltersViewControllerDelegate
{
    var viewController: UIViewController { get }
    var keyboardAssistant: KeyboardAssistant? { get set }
    var keyboardScrollView: UIScrollView? { get }
    var keyboardBottomConstraint: NSLayoutConstraint? { get }
    var navigatorController: InputNavigatorAccessoryController? { get }
    var navigatorCustomAccessoryView: UIView? { get }
    var navigatorInputItems: [UIView] { get }
}

extension FilteredKeyboardAssistant
{
    func presentFiltersViewController()
    {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let filterNavigation: UINavigationController = storyboard.instantiateViewController(withIdentifier: "FiltersNavigationController") as! UINavigationController
        
        if let filtersViewController = filterNavigation.viewControllers.first as? FiltersViewController
        {
            var availableKeyboardAssistantFilters: [KeyboardAssistant.AssistantType] = Array()
            var availableInputNavigatorFilters: [InputNavigator.NavigatorType] = Array()
            
            if (self.keyboardScrollView != nil)
            {
                availableKeyboardAssistantFilters.append(.autoScrollView)
            }
            
            if (self.keyboardBottomConstraint != nil)
            {
                availableKeyboardAssistantFilters.append(.manualWithBottomConstraint)
            }
            
            if (self.navigatorController != nil)
            {
                availableInputNavigatorFilters.append(.controller)
                availableInputNavigatorFilters.append(.keyboardAndController)
            }
            
            if (self.navigatorCustomAccessoryView != nil)
            {
                availableInputNavigatorFilters.append(.customAccessoryView)
                availableInputNavigatorFilters.append(.keyboardAndCustomAccessoryView)
            }
            
            availableKeyboardAssistantFilters.append(.manual)
            availableInputNavigatorFilters.append(.defaultController)
            availableInputNavigatorFilters.append(.keyboard)
            availableInputNavigatorFilters.append(.keyboardAndDefaultController)

            filtersViewController.keyboardAssistant = self.keyboardAssistant
            filtersViewController.availableKeyboardAssistantTypes = availableKeyboardAssistantFilters
            filtersViewController.availableInputNavigatorTypes = availableInputNavigatorFilters
            filtersViewController.delegate = self
        }
        
        self.viewController.present(filterNavigation, animated: true, completion: nil)
    }
    
    func filtersViewControllerApplyFilters(filtersViewController: FiltersViewController, keyboardAssistantType: KeyboardAssistant.AssistantType, inputNavigatorType: InputNavigator.NavigatorType)
    {
        if let keyboardAssistant = self.keyboardAssistant
        {
            print("\nApply Filters")
            print("  keyboardAssistantType: \(keyboardAssistantType)")
            print("  inputNavigatorType: \(inputNavigatorType)")
            
            keyboardAssistant.closeKeyboard()
            keyboardAssistant.stop()
            keyboardAssistant.navigator.removeInputItems()
            self.keyboardAssistant = nil
            
            var navigator: InputNavigator!
            
            switch (inputNavigatorType)
            {
            case .defaultController:
                navigator = InputNavigator.createWithDefaultController()
        
            case .controller:
                if let controller = self.navigatorController
                {
                    navigator = InputNavigator.createWithController(accessoryController: controller)
                }
                
            case .customAccessoryView:
                if let customAccessoryView = self.navigatorCustomAccessoryView
                {
                    navigator = InputNavigator.createWithCustomAccessoryView(accessoryView: customAccessoryView)
                }
                
            case .keyboard:
                // TODO: Implement bool value in filters.
                navigator = InputNavigator.createWithKeyboardNavigation(shouldSetTextFieldDelegates: true)
                
            case .keyboardAndDefaultController:
                // TODO: Implement bool value in filters.
                navigator = InputNavigator.createWithKeyboardNavigationAndDefaultController(shouldSetTextFieldDelegates: true)
                
            case .keyboardAndController:
                // TODO: Implement bool value in filters.
                if let controller = self.navigatorController
                {
                    navigator = InputNavigator.createWithKeyboardNavigation(shouldSetTextFieldDelegates: true, andController: controller)
                }
                
            case .keyboardAndCustomAccessoryView:
                // TODO: Implement bool value in filters.
                if let customAccessoryView = self.navigatorCustomAccessoryView
                {
                    navigator = InputNavigator.createWithKeyboardNavigation(shouldSetTextFieldDelegates: true, andCustomAccessoryView: customAccessoryView)
                }
            }
            
            navigator.addInputItems(inputItems: self.navigatorInputItems)
            
            var newKeyboardAssistant: KeyboardAssistant!
            switch (keyboardAssistantType)
            {
            case .autoScrollView:
                // TODO: Handle cases where scrollView and bottomConstraint are nil
                if let scrollView = self.keyboardScrollView, let bottomConstraint = self.keyboardBottomConstraint
                {
                    // TODO: Add positionConstraint and positionOffset to filters
                    newKeyboardAssistant = KeyboardAssistant.createAutoScrollView(
                        inputNavigator: navigator,
                        positionScrollView: scrollView,
                        positionConstraint: .viewBottomToTopOfKeyboard,
                        positionOffset: 30,
                        bottomConstraint: bottomConstraint,
                        bottomConstraintLayoutView: self.viewController.view)
                }
                
            case .manualWithBottomConstraint:
                // TODO: Handle cases where bottomConstraint is nil and keyboardAssistantDelegate is nil
                if let bottomConstraint = self.keyboardBottomConstraint, let keyboardAssistantDelegate = self.viewController as? KeyboardAssistantDelegate
                {
                    newKeyboardAssistant = KeyboardAssistant.createManual(inputNavigator: navigator, delegate: keyboardAssistantDelegate, bottomConstraint: bottomConstraint, bottomConstraintLayoutView: self.viewController.view)
                }
                
            case .manual:
                // TODO: Handle cases where keyboardAssistantDelegate is nil
                if let keyboardAssistantDelegate = self.viewController as? KeyboardAssistantDelegate
                {
                    newKeyboardAssistant = KeyboardAssistant.createManual(inputNavigator: navigator, delegate: keyboardAssistantDelegate)
                }
            }
            
            newKeyboardAssistant.start()
            self.keyboardAssistant = newKeyboardAssistant
        }
        
        if let presentedViewController = self.viewController.presentedViewController
        {
            presentedViewController.dismiss(animated: true, completion: nil)
        }        
    }
}
