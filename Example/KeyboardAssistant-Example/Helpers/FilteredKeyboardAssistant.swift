//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

protocol FilteredKeyboardAssistant: FiltersViewControllerDelegate {
    
    var viewController: UIViewController { get }
    var keyboardAssistant: KeyboardAssistant? { get set }
    var keyboardScrollView: UIScrollView? { get }
    var keyboardBottomConstraint: NSLayoutConstraint? { get }
    var navigatorController: InputNavigatorAccessoryController? { get }
    var navigatorCustomAccessoryView: UIView? { get }
    var navigatorInputItems: [UIView] { get }
    var keyboardPositionConstraint: KeyboardAssistant.PositionConstraint { get set }
    var keyboardPositionOffset: CGFloat { get set }
}

extension FilteredKeyboardAssistant {
    
    func presentFiltersViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let filterNavigation: UINavigationController = storyboard.instantiateViewController(withIdentifier: "FiltersNavigationController") as! UINavigationController
        
        if let filtersViewController = filterNavigation.viewControllers.first as? FiltersViewController {
            
            var availableKeyboardAssistantFilters: [KeyboardAssistant.AssistantType] = Array()
            var availableInputNavigatorFilters: [InputNavigator.NavigatorType] = Array()
            
            if keyboardScrollView != nil {
                availableKeyboardAssistantFilters.append(.autoScrollView)
            }
            
            if keyboardBottomConstraint != nil {
                availableKeyboardAssistantFilters.append(.manualWithBottomConstraint)
            }
            
            if navigatorController != nil {
                availableInputNavigatorFilters.append(.controller)
                availableInputNavigatorFilters.append(.keyboardAndController)
            }
            
            if navigatorCustomAccessoryView != nil {
                availableInputNavigatorFilters.append(.customAccessoryView)
                availableInputNavigatorFilters.append(.keyboardAndCustomAccessoryView)
            }
            
            availableKeyboardAssistantFilters.append(.manual)
            availableInputNavigatorFilters.append(.defaultController)
            availableInputNavigatorFilters.append(.keyboard)
            availableInputNavigatorFilters.append(.keyboardAndDefaultController)

            filtersViewController.keyboardAssistant = keyboardAssistant
            filtersViewController.keyboardPositionConstraint = keyboardPositionConstraint
            filtersViewController.keyboardPositionOffset = keyboardPositionOffset
            filtersViewController.availableKeyboardAssistantTypes = availableKeyboardAssistantFilters
            filtersViewController.availableInputNavigatorTypes = availableInputNavigatorFilters
            filtersViewController.delegate = self
        }
        
        viewController.present(filterNavigation, animated: true, completion: nil)
    }
    
    func filtersViewControllerApplyFilters(filtersViewController: FiltersViewController, keyboardAssistantType: KeyboardAssistant.AssistantType, inputNavigatorType: InputNavigator.NavigatorType, positionConstraint: KeyboardAssistant.PositionConstraint, positionOffset: CGFloat, shouldSetTextFieldDelegates: Bool) {
        
        keyboardPositionConstraint = positionConstraint
        keyboardPositionOffset = positionOffset
        
        if let keyboardAssistant = keyboardAssistant {
            
            /*
            print("\nApply Filters")
            print("  keyboardAssistantType: \(keyboardAssistantType)")
            print("  inputNavigatorType: \(inputNavigatorType)")
            print("  positionConstraint: \(positionConstraint)")
            print("  positionOffset: \(positionOffset)")
            print("  shouldSetTextFieldDelegates: \(shouldSetTextFieldDelegates)")
            */
            
            keyboardAssistant.closeKeyboard()
            keyboardAssistant.stop()
            keyboardAssistant.navigator.removeInputItems()
            self.keyboardAssistant = nil
            
            var navigator: InputNavigator!
            
            switch inputNavigatorType {
                
            case .defaultController:
                navigator = InputNavigator.createWithDefaultController()
        
            case .controller:
                if let controller = navigatorController {
                    navigator = InputNavigator.createWithController(accessoryController: controller)
                }
                
            case .customAccessoryView:
                if let customAccessoryView = navigatorCustomAccessoryView {
                    navigator = InputNavigator.createWithCustomAccessoryView(accessoryView: customAccessoryView)
                }
                
            case .keyboard:
                navigator = InputNavigator.createWithKeyboardNavigation(shouldSetTextFieldDelegates: shouldSetTextFieldDelegates)
                
            case .keyboardAndDefaultController:
                navigator = InputNavigator.createWithKeyboardNavigationAndDefaultController(shouldSetTextFieldDelegates: shouldSetTextFieldDelegates)
                
            case .keyboardAndController:
                if let controller = navigatorController {
                    navigator = InputNavigator.createWithKeyboardNavigation(shouldSetTextFieldDelegates: shouldSetTextFieldDelegates, andController: controller)
                }
                
            case .keyboardAndCustomAccessoryView:
                if let customAccessoryView = navigatorCustomAccessoryView {
                    navigator = InputNavigator.createWithKeyboardNavigation(shouldSetTextFieldDelegates: shouldSetTextFieldDelegates, andCustomAccessoryView: customAccessoryView)
                }
            }
            
            if navigator == nil {
                print("\nWARNING: Failed to create InputNavigator.  Creating InputNavigator with default controller.")
                navigator = InputNavigator.createWithDefaultController()
            }
            
            navigator.addInputItems(inputItems: navigatorInputItems)
            
            var newKeyboardAssistant: KeyboardAssistant!
            
            switch keyboardAssistantType {
            case .autoScrollView:
                // TODO: Handle cases where scrollView and bottomConstraint are nil
                if let scrollView = keyboardScrollView, let bottomConstraint = keyboardBottomConstraint {
                    newKeyboardAssistant = KeyboardAssistant.createAutoScrollView(
                        inputNavigator: navigator,
                        positionScrollView: scrollView,
                        positionConstraint: positionConstraint,
                        positionOffset: positionOffset,
                        bottomConstraint: bottomConstraint,
                        bottomConstraintLayoutView: viewController.view)
                }
                
            case .manualWithBottomConstraint:
                // TODO: Handle cases where bottomConstraint is nil and keyboardAssistantDelegate is nil
                if let bottomConstraint = keyboardBottomConstraint, let keyboardAssistantDelegate = viewController as? KeyboardAssistantDelegate {
                    newKeyboardAssistant = KeyboardAssistant.createManual(inputNavigator: navigator, delegate: keyboardAssistantDelegate, bottomConstraint: bottomConstraint, bottomConstraintLayoutView: viewController.view)
                }
                
            case .manual:
                // TODO: Handle cases where keyboardAssistantDelegate is nil
                if let keyboardAssistantDelegate = viewController as? KeyboardAssistantDelegate {
                    newKeyboardAssistant = KeyboardAssistant.createManual(inputNavigator: navigator, delegate: keyboardAssistantDelegate)
                }
            }
            
            newKeyboardAssistant.start()
            self.keyboardAssistant = newKeyboardAssistant
        }
        
        if let presentedViewController = viewController.presentedViewController {
            presentedViewController.dismiss(animated: true, completion: nil)
        }        
    }
}
