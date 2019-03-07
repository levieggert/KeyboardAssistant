//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class ViewSizeScrollViewController: UIViewController, FilteredKeyboardAssistant
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
        return [self.txtFirstName, self.txtLastName, self.txtEmail, self.txtPassword]
    }
    
    // MARK: - Properties
    
    // MARK: - Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btRegisterAccount: UIButton!
    
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
    
    @IBAction func handleRegisterAccount(button: UIButton)
    {
        if let keyboardAssistant = self.keyboardAssistant
        {
            keyboardAssistant.closeKeyboard()
        }
    }
}

// MARK: - UITextFieldDelegate

extension ViewSizeScrollViewController: UITextFieldDelegate
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

extension ViewSizeScrollViewController: KeyboardAssistantDelegate
{
    func keyboardAssistantManuallyReposition(keyboardAssistant: KeyboardAssistant, toInputItem: UIView, keyboardHeight: CGFloat)
    {
        // TODO: Should add these variables to FilteredKeyboardAssistant protocol and use them here.
        let constraint: KeyboardAssistant.PositionConstraint = .viewBottomToTopOfKeyboard
        let offset: CGFloat = 20
        
        if let nextInputItem = keyboardAssistant.navigator.getNextInputItem(inputItem: toInputItem, shouldLoop: false)
        {
            keyboardAssistant.reposition(scrollView: self.scrollView, toInputItem: nextInputItem, constraint: constraint, offset: offset)
        }
        else
        {
            keyboardAssistant.reposition(scrollView: self.scrollView, toInputItem: self.btRegisterAccount, constraint: constraint, offset: offset)
        }
    }
}

