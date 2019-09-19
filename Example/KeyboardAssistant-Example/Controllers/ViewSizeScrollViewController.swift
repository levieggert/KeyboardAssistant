//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class ViewSizeScrollViewController: UIViewController, FilteredKeyboardAssistant {
    
    // MARK: - FilteredKeyboardAssistant protocol
    
    var viewController: UIViewController {
        return self
    }
    var keyboardAssistant: KeyboardAssistant?
    var keyboardScrollView: UIScrollView? {
        return scrollView
    }
    var keyboardBottomConstraint: NSLayoutConstraint? {
        return scrollViewBottomConstraint
    }
    var keyboardPositionConstraint: KeyboardAssistant.PositionConstraint = .viewBottomToTopOfKeyboard
    var keyboardPositionOffset: CGFloat = 30
    var navigatorController: InputNavigatorAccessoryController? {
        return CustomNavigatorController()
    }
    var navigatorCustomAccessoryView: UIView? = CustomKeyboardView()
    var navigatorInputItems: [UIView] {
        return [txtFirstName, txtLastName, txtEmail, txtPassword]
    }
    
    // MARK: - Properties
    
    // MARK: - Outlets
    
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var lbTitle: UILabel!
    @IBOutlet weak private var txtFirstName: UITextField!
    @IBOutlet weak private var txtLastName: UITextField!
    @IBOutlet weak private var txtEmail: UITextField!
    @IBOutlet weak private var txtPassword: UITextField!
    @IBOutlet weak private var btRegisterAccount: UIButton!
    
    @IBOutlet weak private var scrollViewBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Life Cycle
    
    deinit {
        print("deinit: \(type(of: self))")
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let navigator: InputNavigator = InputNavigator.createWithDefaultController()
        navigator.addInputItems(inputItems: navigatorInputItems)
        keyboardAssistant = KeyboardAssistant.createAutoScrollView(
            inputNavigator: navigator,
            positionScrollView: scrollView,
            positionConstraint: keyboardPositionConstraint,
            positionOffset: keyboardPositionOffset,
            bottomConstraint: scrollViewBottomConstraint,
            bottomConstraintLayoutView: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardAssistant?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardAssistant?.stop()
    }
    
    // MARK: - Actions
    
    @IBAction func handleBack(barButtonItem: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleFilter(barButtonItem: UIBarButtonItem) {
        presentFiltersViewController()
    }
    
    @IBAction func handleRegisterAccount(button: UIButton) {
        keyboardAssistant?.closeKeyboard()
    }
}

// MARK: - UITextFieldDelegate

extension ViewSizeScrollViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let keyboardAssistant = keyboardAssistant {
            _ = keyboardAssistant.navigator.textFieldShouldReturn(textField)
        }
        return true
    }
}

// MARK: - KeyboardAssistantDelegate

extension ViewSizeScrollViewController: KeyboardAssistantDelegate {
    
    func keyboardAssistantManuallyReposition(keyboardAssistant: KeyboardAssistant, toInputItem: UIView, keyboardHeight: CGFloat) {
        
        let constraint: KeyboardAssistant.PositionConstraint = keyboardPositionConstraint
        let offset: CGFloat = keyboardPositionOffset
        
        if let nextInputItem = keyboardAssistant.navigator.getNextInputItem(inputItem: toInputItem, shouldLoop: false) {
            keyboardAssistant.reposition(scrollView: scrollView, toInputItem: nextInputItem, constraint: constraint, offset: offset)
        }
        else {
            keyboardAssistant.reposition(scrollView: scrollView, toInputItem: btRegisterAccount, constraint: constraint, offset: offset)
        }
    }
}

