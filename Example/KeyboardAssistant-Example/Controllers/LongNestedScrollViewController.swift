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
    
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
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
        
        let navigator: InputNavigator = InputNavigator.createWithDefaultController()
        navigator.addInputItems(from: self)
        
        if (!allowToSetInputDelegates)
        {
            for item in navigator.inputItems
            {
                if let textField = item as? UITextField
                {
                    textField.delegate = self
                }
            }
        }
        
        if (useAutoKeyboardAssistant)
        {
            self.keyboardAssistant = KeyboardAssistant.createAutoScrollViewKeyboardAssistant(inputNavigator: navigator,
                                                                                             positionScrollView: self.scrollView,
                                                                                             positionConstraint: .viewBottomToTopOfKeyboard,
                                                                                             positionOffset: 30,
                                                                                             bottomConstraint: self.scrollViewBottomConstraint,
                                                                                             bottomConstraintLayoutView: self.view)
        }
        else
        {
            self.keyboardAssistant = KeyboardAssistant.createManualKeyboardAssistant(inputNavigator: navigator,
                                                                                     delegate: self,
                                                                                     bottomConstraint: self.scrollViewBottomConstraint,
                                                                                     bottomConstraintLayoutView: self.view)
        }
        
        self.keyboardAssistant.observer.loggingEnabled = true
        self.keyboardAssistant.observer.loggingEnabled = true
        
        let items: [UIView] = InputNavigator.getInputItems(from: self)
        print(" --> total input items: \(items.count)")
        for item in items
        {
            if let textField = item as? UITextField
            {
                print("  placeholder: \(String(describing: textField.placeholder))")
            }
        }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.keyboardAssistant.start()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.keyboardAssistant.stop()
    }
    
    // MARK: - Actions
    
    @IBAction func handleBack(barButtonItem: UIBarButtonItem)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleFilter(barButtonItem: UIBarButtonItem)
    {
        
    }
}

// MARK: - UITextFieldDelegate

extension LongNestedScrollViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        _ = self.keyboardAssistant.navigator.textFieldShouldReturn(textField)
        
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
