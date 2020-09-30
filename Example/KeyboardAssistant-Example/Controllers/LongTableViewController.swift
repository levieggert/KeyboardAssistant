//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class LongTableViewController: UIViewController {
    
    enum InputField {
        case animal
        case color
        case email
        case firstName
        case food
        case hobby
        case lastName
        case password
    }
    
    // MARK: - Properties
    
    private let inputFields: [InputField] = [.firstName, .lastName, .email, .password, .animal, .food, .color, .hobby]
    private var inputFieldValues: [InputField: String] = [:]
    
    // MARK: - Outlets
    
    @IBOutlet weak private var tableView: UITableView!
    
    @IBOutlet weak private var bottomConstraint: NSLayoutConstraint!
    
    private var keyboardAssistant: KeyboardAssistant!
    
    // MARK: - Life Cycle
    
    deinit
    {
        print("deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /*
        let useAutoKeyboardAssistant: Bool = true
        let allowToSetInputDelegates: Bool = true
        
        let inputItems: [UIView] = []
        
        if !allowToSetInputDelegates {
            for item in inputItems {
                if let textField = item as? UITextField {
                    textField.delegate = self
                }
            }
        }
        */
        
        /*
        
        if useAutoKeyboardAssistant
        {
            keyboardAssistant = KeyboardAssistant.createAutoKeyboardAssistant(allowToSetInputDelegates: allowToSetInputDelegates,
                                                                                   inputItems: inputItems, 
                                                                                   accessoryController: nil,
                                                                                   positionScrollView: tableView,
                                                                                   positionConstraint: .viewTopToTopOfScreen,
                                                                                   positionOffset: 20,
                                                                                   bottomConstraint: bottomConstraint,
                                                                                   bottomConstraintLayoutView: view)
        }
        else
        {
            keyboardAssistant = KeyboardAssistant.createManualKeyboardAssistant(allowToSetInputDelegates: allowToSetInputDelegates,
                                                                                     inputItems: inputItems,
                                                                                     accessoryController: nil,
                                                                                     bottomConstraint: bottomConstraint,
                                                                                     bottomConstraintLayoutView: view,
                                                                                     delegate: self)
        }
 
         */
                
        // tableView
        tableView.register(UINib(nibName: InputCell.nibName, bundle: nil), forCellReuseIdentifier: InputCell.reuseIdentifier)
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardAssistant.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardAssistant.stop()
    }
    
    // MARK: - Actions
    
    @IBAction func handleBack(barButtonItem: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate

extension LongTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inputFields.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: InputCell = tableView.dequeueReusableCell(withIdentifier: InputCell.reuseIdentifier, for: indexPath) as! InputCell
        let inputField: InputField = inputFields[indexPath.row]
        
        cell.selectionStyle = .none
        
        var fieldLabel: String = ""
        
        switch inputField {
            
        case .animal:
            fieldLabel = "Favorite Animal"
            
        case .color:
            fieldLabel = "Favorite Color"
            
        case .email:
            fieldLabel = "Email"
            
        case .firstName:
            fieldLabel = "First Name"
            
        case .food:
            fieldLabel = "Favorite Food"
            
        case .hobby:
            fieldLabel = "Favorite Hobby"
            
        case .lastName:
            fieldLabel = "Last Name"
            
        case .password:
            fieldLabel = "Password"
        }
        
        cell.title = fieldLabel
        
        cell.separatorLineIsHidden = indexPath.row == inputFields.count - 1
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - UITextFieldDelegate

extension LongTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _ = keyboardAssistant.navigator.textFieldShouldReturn(textField)
        return true
    }
}

// MARK: - KeyboardAssistantDelegate

extension LongTableViewController: KeyboardAssistantDelegate {
    func keyboardAssistantManuallyReposition(keyboardAssistant: KeyboardAssistant, toInputItem: UIView, keyboardHeight: Double) {
        
    }
}
