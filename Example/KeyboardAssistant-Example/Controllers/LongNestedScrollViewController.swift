//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class LongNestedScrollViewController: UIViewController
{
    // MARK: - Properties
    
    private var keyboardAssistant: KeyboardAssistant!
    
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
        
        let inputItems: [UIView] = []
        
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
        
        self.keyboardAssistant.observer.loggingEnabled = true
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
}

// MARK: - UITextFieldDelegate

extension LongNestedScrollViewController: UITextFieldDelegate
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

// MARK: - KeyboardAssistantDelegate

extension LongNestedScrollViewController: KeyboardAssistantDelegate
{
    func keyboardAssistantManuallyReposition(keyboardAssistant: KeyboardAssistant, view: UIView, keyboardHeight: CGFloat)
    {
        
    }
}
