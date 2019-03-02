//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class LongScrollViewController: UIViewController
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
        
        let inputItems: [UIView] = [self.txtFirstName, self.txtLastName, self.txtCity, self.txtState, self.txtZipCode, self.txtCountry, self.infoTextView, self.txtAnimal, self.txtColor, self.txtFood, self.txtHobby, self.notesTextView]
        
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
        
        /*
        
        if (useAutoKeyboardAssistant)
        {
            self.keyboardAssistant = KeyboardAssistant.createAutoKeyboardAssistant(allowToSetInputDelegates: allowToSetInputDelegates,
                                                                                   inputItems: inputItems,
                                                                                   accessoryController: DefaultNavigationView(),
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
                                                                                     accessoryController: nil,
                                                                                     bottomConstraint: self.bottomConstraint,
                                                                                     bottomConstraintLayoutView: self.view,
                                                                                     delegate: self)
        }
 
        */
        
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
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        if (self.scrollView.constraints.contains(self.bottomConstraint))
        {
            print("view did layout - scrollview contains bottom constraint")
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

extension LongScrollViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        _ = self.keyboardAssistant.navigator.textFieldShouldReturn(textField)
        
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
