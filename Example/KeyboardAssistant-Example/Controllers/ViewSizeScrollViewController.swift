//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class ViewSizeScrollViewController: UIViewController
{
    // MARK: - Properties
    
    private var keyboardAssistant: KeyboardAssistant!
    
    // MARK: - Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btRegisterAccount: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - Life Cycle
    
    deinit
    {
        print("deinit: \(type(of: self))")
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let useAutoKeyboardAssistant: Bool = true
        let allowToSetInputDelegates: Bool = true
        
        let inputItems: [UIView] = [self.txtFirstName, self.txtLastName, self.txtEmail, self.txtPassword]
        
        if (!allowToSetInputDelegates)
        {
            for item in inputItems
            {
                if let textField = item as? UITextField
                {
                    textField.delegate = self
                }
            }
        }
        
        if (useAutoKeyboardAssistant)
        {
            self.keyboardAssistant = KeyboardAssistant.createAutoKeyboardAssistant(allowToSetInputDelegates: allowToSetInputDelegates,
                                                                                   inputItems: inputItems,
                                                                                   positionScrollView: self.scrollView,
                                                                                   positionConstraint: .viewBottomToTopOfKeyboard,
                                                                                   positionOffset: 20,
                                                                                   bottomConstraint: self.bottomConstraint,
                                                                                   bottomConstraintLayoutView: self.view)
        }
        else
        {
            self.keyboardAssistant = KeyboardAssistant.createManualKeyboardAssistant(allowToSetInputDelegates: allowToSetInputDelegates,
                                                                                     inputItems: inputItems,
                                                                                     bottomConstraint: self.bottomConstraint,
                                                                                     bottomConstraintLayoutView: self.view,
                                                                                     delegate: self)
        }
        
        self.keyboardAssistant.loggingEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.keyboardAssistant.observer.start()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.keyboardAssistant.observer.stop()
    }
    
    // MARK: - Actions
    
    @IBAction func handleBack(barButtonItem: UIBarButtonItem)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleRegisterAccount(button: UIButton)
    {
        self.keyboardAssistant.closeKeyboard()
        //self.keyboardAssistant.navigator.focusedItem = nil // Same as self.keyboardAssistant.closeKeyboard()
    }
}

// MARK: - UITextFieldDelegate

extension ViewSizeScrollViewController: UITextFieldDelegate
{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.keyboardAssistant.navigator.textFieldDidBeginEditing(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        self.keyboardAssistant.navigator.textFieldDidEndEditing(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        _ = self.keyboardAssistant.navigator.textFieldShouldReturn(textField)
        
        return true
    }
}

// MARK: - UITextViewDelegate

extension ViewSizeScrollViewController: UITextViewDelegate
{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        self.keyboardAssistant.navigator.textViewShouldBeginEditing(textView)
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        self.keyboardAssistant.navigator.textViewDidBeginEditing(textView)
    }
}

// MARK: - KeyboardAssistantDelegate

extension ViewSizeScrollViewController: KeyboardAssistantDelegate
{
    func keyboardAssistantManuallyReposition(keyboardAssistant: KeyboardAssistant, inputItem: UIView, keyboardHeight: CGFloat)
    {
        let constraint: KeyboardAssistant.RepositionConstraint = .viewBottomToTopOfKeyboard
        let offset: CGFloat = 20
        
        if (inputItem == self.txtFirstName)
        {
            keyboardAssistant.reposition(scrollView: self.scrollView, toView: self.txtLastName, constraint: constraint, offset: offset)
        }
        else if (inputItem == self.txtLastName)
        {
            keyboardAssistant.reposition(scrollView: self.scrollView, toView: self.txtEmail, constraint: constraint, offset: offset)
        }
        else if (inputItem == self.txtEmail)
        {
            keyboardAssistant.reposition(scrollView: self.scrollView, toView: self.txtPassword, constraint: constraint, offset: offset)
        }
        else if (inputItem == self.txtPassword)
        {
            keyboardAssistant.reposition(scrollView: self.scrollView, toView: self.btRegisterAccount, constraint: constraint, offset: offset)
        }
    }
}

