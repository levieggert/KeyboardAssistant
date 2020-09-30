//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class LongNestedScrollViewController: UIViewController, FilteredKeyboardAssistant
{
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
    var keyboardPositionConstraint: KeyboardAssistantPositionConstraint = .viewBottomToTopOfKeyboard
    var keyboardPositionOffset: CGFloat = 30
    var navigatorController: InputNavigatorAccessoryController? {
        return CustomNavigatorController()
    }
    var navigatorCustomAccessoryView: UIView? = CustomKeyboardView()
    var navigatorInputItems: [UIView] {
        return [txtFirstName, txtLastName, txtCity, txtState, txtZipCode, txtCountry, infoTextView, txtAnimal, txtColor, txtFood, txtHobby, notesTextView]
    }
    
    // MARK: - Properties
    
    // MARK: - Outlets
    
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var txtFirstName: UITextField!
    @IBOutlet weak private var txtLastName: UITextField!
    @IBOutlet weak private var txtCity: UITextField!
    @IBOutlet weak private var txtState: UITextField!
    @IBOutlet weak private var txtZipCode: UITextField!
    @IBOutlet weak private var txtCountry: UITextField!
    @IBOutlet weak private var infoTextView: UITextView!
    @IBOutlet weak private var txtAnimal: UITextField!
    @IBOutlet weak private var txtColor: UITextField!
    @IBOutlet weak private var txtFood: UITextField!
    @IBOutlet weak private var txtHobby: UITextField!
    @IBOutlet weak private var notesTextView: UITextView!
    
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
}

// MARK: - UITextFieldDelegate

extension LongNestedScrollViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _ = keyboardAssistant?.navigator.textFieldShouldReturn(textField)
        return true
    }
}

// MARK: - KeyboardAssistantDelegate

extension LongNestedScrollViewController: KeyboardAssistantDelegate {
    
    func keyboardAssistantManuallyReposition(keyboardAssistant: KeyboardAssistant, toInputItem: UIView, keyboardHeight: Double) {
        
        let constraint: KeyboardAssistantPositionConstraint = keyboardPositionConstraint
        let offset: CGFloat = keyboardPositionOffset
        
        if toInputItem == txtFirstName || toInputItem == txtLastName {
            keyboardAssistant.reposition(scrollView: scrollView, toInputItem: txtCity, constraint: constraint, offset: offset)
        }
        else if toInputItem == txtCity || toInputItem == txtState {
            keyboardAssistant.reposition(scrollView: scrollView, toInputItem: txtZipCode, constraint: constraint, offset: offset)
        }
        else if toInputItem == txtZipCode || toInputItem == txtCountry {
            keyboardAssistant.reposition(scrollView: scrollView, toInputItem: txtZipCode, constraint: constraint, offset: 80)
        }
        else if toInputItem == infoTextView {
            keyboardAssistant.reposition(scrollView: scrollView, toInputItem: txtZipCode, constraint: .viewTopToTopOfScreen, offset: 50)
        }
        else if toInputItem == txtAnimal {
            keyboardAssistant.reposition(scrollView: scrollView, toInputItem: txtColor, constraint: constraint, offset: offset)
        }
        else if toInputItem == txtColor {
            keyboardAssistant.reposition(scrollView: scrollView, toInputItem: txtFood, constraint: constraint, offset: offset)
        }
        else if toInputItem == txtFood {
            keyboardAssistant.reposition(scrollView: scrollView, toInputItem: txtHobby, constraint: constraint, offset: offset)
        }
        else if toInputItem == txtHobby {
            keyboardAssistant.reposition(scrollView: scrollView, toInputItem: txtHobby, constraint: constraint, offset: 50)
        }
        else if toInputItem == notesTextView {
            keyboardAssistant.reposition(scrollView: scrollView, toInputItem: notesTextView, constraint: .viewTopToTopOfScreen, offset: 50)
        }
    }
}
