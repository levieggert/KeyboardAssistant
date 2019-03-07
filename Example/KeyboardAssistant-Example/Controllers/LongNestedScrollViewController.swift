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

extension LongNestedScrollViewController: UITextFieldDelegate
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

extension LongNestedScrollViewController: KeyboardAssistantDelegate
{
    func keyboardAssistantManuallyReposition(keyboardAssistant: KeyboardAssistant, toInputItem: UIView, keyboardHeight: CGFloat)
    {
        
    }
}
