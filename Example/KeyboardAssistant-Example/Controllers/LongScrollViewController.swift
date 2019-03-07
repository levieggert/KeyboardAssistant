//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class LongScrollViewController: UIViewController, FilteredKeyboardAssistant
{
    // MARK: - FilteredKeyboardAssistant protocol
    
    var viewController: UIViewController {
        return self
    }
    var keyboardAssistant: KeyboardAssistant?
    var keyboardScrollView: UIScrollView? {
        return self.scrollView
    }
    var keyboardBottomConstraint: NSLayoutConstraint? {
        return self.scrollViewBottomConstraint
    }
    var navigatorController: InputNavigatorAccessoryController? {
        return CustomNavigatorController()
    }
    var navigatorCustomAccessoryView: UIView? = CustomKeyboardView()
    var navigatorInputItems: [UIView] {
        return [self.txtFirstName, self.txtLastName, self.txtCity, self.txtState, self.txtZipCode, self.txtCountry, self.infoTextView, self.txtAnimal, self.txtColor, self.txtFood, self.txtHobby, self.notesTextView]
    }
    
    // MARK: - Properties
        
    // MARK: - Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtState: UITextField!
    @IBOutlet weak var txtZipCode: UITextField!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var txtAnimal: UITextField!
    @IBOutlet weak var txtColor: UITextField!
    @IBOutlet weak var txtFood: UITextField!
    @IBOutlet weak var txtHobby: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Life Cycle
    
    deinit
    {
        print("deinit: \(type(of: self))")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let navigator: InputNavigator = InputNavigator.createWithDefaultController()
        navigator.addInputItems(inputItems: self.navigatorInputItems)
        self.keyboardAssistant = KeyboardAssistant.createAutoScrollView(
            inputNavigator: navigator,
            positionScrollView: self.scrollView,
            positionConstraint: .viewBottomToTopOfKeyboard,
            positionOffset: 30,
            bottomConstraint: self.scrollViewBottomConstraint,
            bottomConstraintLayoutView: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if let keyboardAssistant = self.keyboardAssistant
        {
            keyboardAssistant.start()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if let keyboardAssistant = self.keyboardAssistant
        {
            keyboardAssistant.stop()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func handleBack(barButtonItem: UIBarButtonItem)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleFilter(barButtonItem: UIBarButtonItem)
    {
        self.presentFiltersViewController()
    }
}

// MARK: - UITextFieldDelegate

extension LongScrollViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if let keyboardAssistant = self.keyboardAssistant
        {
            _ = keyboardAssistant.navigator.textFieldShouldReturn(textField)
        }
        
        return true
    }
}

// MARK: - KeyboardAssistantDelegate

extension LongScrollViewController: KeyboardAssistantDelegate
{
    func keyboardAssistantManuallyReposition(keyboardAssistant: KeyboardAssistant, toInputItem: UIView, keyboardHeight: CGFloat)
    {
        let constraint: KeyboardAssistant.RepositionConstraint = .viewBottomToTopOfKeyboard
        let offset: CGFloat = 30
        
        if (toInputItem == self.txtFirstName || toInputItem == self.txtLastName)
        {
            keyboardAssistant.reposition(scrollView: self.scrollView, toInputItem: self.txtCity, constraint: constraint, offset: offset)
        }
        else if (toInputItem == self.txtCity || toInputItem == self.txtState)
        {
            keyboardAssistant.reposition(scrollView: self.scrollView, toInputItem: self.txtZipCode, constraint: constraint, offset: offset)
        }
        else if (toInputItem == self.txtZipCode || toInputItem == self.txtCountry)
        {
            keyboardAssistant.reposition(scrollView: self.scrollView, toInputItem: self.txtZipCode, constraint: constraint, offset: 80)
        }
        else if (toInputItem == self.infoTextView)
        {
            keyboardAssistant.reposition(scrollView: self.scrollView, toInputItem: self.txtZipCode, constraint: .viewTopToTopOfScreen, offset: 50)
        }
        else if (toInputItem == self.txtAnimal)
        {
            keyboardAssistant.reposition(scrollView: self.scrollView, toInputItem: self.txtColor, constraint: constraint, offset: offset)
        }
        else if (toInputItem == self.txtColor)
        {
            keyboardAssistant.reposition(scrollView: self.scrollView, toInputItem: self.txtFood, constraint: constraint, offset: offset)
        }
        else if (toInputItem == self.txtFood)
        {
            keyboardAssistant.reposition(scrollView: self.scrollView, toInputItem: self.txtHobby, constraint: constraint, offset: offset)
        }
        else if (toInputItem == self.txtHobby)
        {
            keyboardAssistant.reposition(scrollView: self.scrollView, toInputItem: self.txtHobby, constraint: constraint, offset: 50)
        }
        else if (toInputItem == self.notesTextView)
        {
            keyboardAssistant.reposition(scrollView: self.scrollView, toInputItem: self.notesTextView, constraint: .viewTopToTopOfScreen, offset: 50)
        }
    }
}
