//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

protocol FiltersViewControllerDelegate: class {
    func filtersViewControllerApplyFilters(filtersViewController: FiltersViewController, keyboardAssistantType: KeyboardAssistant.AssistantType, inputNavigatorType: InputNavigator.NavigatorType, positionConstraint: KeyboardAssistant.PositionConstraint, positionOffset: CGFloat, shouldSetTextFieldDelegates: Bool)
}

class FiltersViewController: UIViewController {
    
    class FilterOption {
        var inputValue: NSNumber = NSNumber(value: 0)
        var filterInputType: FilterInputType = .filterSwitch
    }
    
    class KeyboardOption: FilterOption {
        var type: KeyboardAssistant.AssistantType!
    }
    
    class NavigatorOption: FilterOption {
        var type: InputNavigator.NavigatorType!
    }
    
    class MiscOption: FilterOption {
        var type: MiscType!
    }
    
    class PositionConstraintOption: FilterOption {
        var type: KeyboardAssistant.PositionConstraint!
    }
    
    enum Section {
        case miscellaneous
        case positionConstraint
        case keyboardAssistant
        case inputNavigator
    }
    
    enum MiscType {
        case positionOffset
        case shouldSetTextFieldDelegates
        
        static var allTypes: [MiscType] {
            return [.positionOffset, .shouldSetTextFieldDelegates]
        }
    }
    
    enum FilterInputType {
        case filterInput
        case filterSwitch
    }
    
    // MARK: - Properties
    
    private let sections: [Section] = [.miscellaneous, .positionConstraint, .keyboardAssistant, .inputNavigator]
    private let filterInputCellHeight: CGFloat = 100
    private let filterSwitchCellHeight: CGFloat = 65
    
    private var miscFilterOptionsDictionary: [MiscType: MiscOption] = Dictionary()
    private var miscFilterOptions: [MiscOption] = Array()
    private var positionFilterOptionsDictionary: [KeyboardAssistant.PositionConstraint: PositionConstraintOption] = Dictionary()
    private var positionFilterOptions: [PositionConstraintOption] = Array()
    private var keyboardAssistantFilterOptionsDictionary: [KeyboardAssistant.AssistantType: KeyboardOption] = Dictionary()
    private var keyboardAssistantFilterOptions: [KeyboardOption] = Array()
    private var inputNavigatorFilterOptionsDictionary: [InputNavigator.NavigatorType: NavigatorOption] = Dictionary()
    private var inputNavigatorFilterOptions: [NavigatorOption] = Array()
    
    private weak var positionOffsetTextField: UITextField?
    
    var keyboardAssistant: KeyboardAssistant?
    var keyboardPositionConstraint: KeyboardAssistant.PositionConstraint = .viewBottomToTopOfKeyboard
    var keyboardPositionOffset: CGFloat = 30
    var availableKeyboardAssistantTypes: [KeyboardAssistant.AssistantType] = Array()
    var availableInputNavigatorTypes: [InputNavigator.NavigatorType] = Array()
    
    weak var delegate: FiltersViewControllerDelegate?
    
    // MARK: - Outlets
    
    @IBOutlet weak private var filtersTableView: UITableView!
    @IBOutlet weak private var btApplyFilters: UIButton!
    
    // MARK: - Life Cycle
    
    deinit {
        print("deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // - misc options
        var miscOption: MiscOption!
        for miscType in MiscType.allTypes {
            miscOption = MiscOption()
            miscOption.type = miscType
            miscFilterOptionsDictionary[miscType] = miscOption
            miscFilterOptions.append(miscOption)
        }
        
        miscFilterOptionsDictionary[.positionOffset]?.filterInputType = .filterInput
        miscFilterOptionsDictionary[.positionOffset]?.inputValue = NSNumber(value: 20)
        miscFilterOptionsDictionary[.shouldSetTextFieldDelegates]?.filterInputType = .filterSwitch
        miscFilterOptionsDictionary[.shouldSetTextFieldDelegates]?.inputValue = NSNumber(value: true)
        
        // - position constraint options
        var positionOption: PositionConstraintOption!
        for positionType in KeyboardAssistant.PositionConstraint.all {
            positionOption = PositionConstraintOption()
            positionOption.type = positionType
            positionFilterOptionsDictionary[positionType] = positionOption
            positionFilterOptions.append(positionOption)
        }
        
        // - keyboard assistant options
        var keyboardOption: KeyboardOption!
        for assistantType in KeyboardAssistant.AssistantType.allTypes {
            keyboardOption = KeyboardOption()
            keyboardOption.type = assistantType
            keyboardAssistantFilterOptionsDictionary[assistantType] = keyboardOption
            keyboardAssistantFilterOptions.append(keyboardOption)
        }
        
        // - input navigator options
        var navigatorOption: NavigatorOption!
        for navigatorType in InputNavigator.NavigatorType.allTypes {
            navigatorOption = NavigatorOption()
            navigatorOption.type = navigatorType
            inputNavigatorFilterOptionsDictionary[navigatorType] = navigatorOption
            inputNavigatorFilterOptions.append(navigatorOption)
        }
        
        //filtersTableView
        filtersTableView.register(UINib(nibName: FilterSwitchCell.nibName, bundle: nil), forCellReuseIdentifier: FilterSwitchCell.reuseIdentifier)
        filtersTableView.register(UINib(nibName: FilterInputCell.nibName, bundle: nil), forCellReuseIdentifier: FilterInputCell.reuseIdentifier)
        filtersTableView.separatorStyle = .none
        
        //keyboardAssistant
        if let keyboardAssistant = keyboardAssistant {
            if let filterOption = keyboardAssistantFilterOptionsDictionary[keyboardAssistant.type] {
                filterOption.inputValue = NSNumber(value: true)
            }
            
            if let filterOption = inputNavigatorFilterOptionsDictionary[keyboardAssistant.navigator.type] {
                filterOption.inputValue = NSNumber(value: true)
            }
        }
        
        if let filterOption = positionFilterOptionsDictionary[keyboardPositionConstraint] {
            filterOption.inputValue = NSNumber(value: true)
        }
        
        miscFilterOptionsDictionary[.positionOffset]?.inputValue = NSNumber(value: Float(keyboardPositionOffset))
    }
    
    private func closeKeyboard() {
        positionOffsetTextField?.resignFirstResponder()
    }
    
    // MARK: - Actions
    
    @IBAction func handleCancel(barButtonItem: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleApplyFilters(button: UIButton) {
        
        if let delegate = delegate {
            
            var keyboardAssistantType: KeyboardAssistant.AssistantType = .autoScrollView
            var inputNavigatorType: InputNavigator.NavigatorType = .defaultController
            var positionConstraint: KeyboardAssistant.PositionConstraint = .viewBottomToTopOfKeyboard
            var positionOffset: CGFloat = 20
            var shouldSetTextFieldDelegates: Bool = true
            
            for keyboardOption in keyboardAssistantFilterOptions {
                if keyboardOption.inputValue.boolValue {
                    keyboardAssistantType = keyboardOption.type
                    break
                }
            }
            
            for navigatorOption in inputNavigatorFilterOptions {
                if navigatorOption.inputValue.boolValue {
                    inputNavigatorType = navigatorOption.type
                    break
                }
            }
            
            for positionOption in positionFilterOptions {
                if positionOption.inputValue.boolValue {
                    positionConstraint = positionOption.type
                    break
                }
            }
            
            if let pPositionOffset = miscFilterOptionsDictionary[.positionOffset]?.inputValue.floatValue {
                positionOffset = CGFloat(pPositionOffset)
            }
            
            if let pShouldSetTextFieldDelegates = miscFilterOptionsDictionary[.shouldSetTextFieldDelegates]?.inputValue.boolValue {
                shouldSetTextFieldDelegates = pShouldSetTextFieldDelegates
            }
            
            delegate.filtersViewControllerApplyFilters(filtersViewController: self, keyboardAssistantType: keyboardAssistantType, inputNavigatorType: inputNavigatorType, positionConstraint: positionConstraint, positionOffset: positionOffset, shouldSetTextFieldDelegates: shouldSetTextFieldDelegates)
        }
    }
}

extension FiltersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let filterSection: Section = sections[section]
        
        switch filterSection {
            
        case .miscellaneous:
            return miscFilterOptions.count
            
        case .positionConstraint:
            return positionFilterOptions.count
            
        case .keyboardAssistant:
            return keyboardAssistantFilterOptions.count
            
        case .inputNavigator:
            return inputNavigatorFilterOptions.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        closeKeyboard()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let filterHeader: FilterHeaderSectionView = FilterHeaderSectionView()
        
        let filterSection: Section = sections[section]
        
        switch filterSection {
            
        case .miscellaneous:
            filterHeader.title = "Miscellaneous Options"
            
        case .positionConstraint:
            filterHeader.title = "Position Constraint"
            
        case .keyboardAssistant:
            filterHeader.title = "Keyboard Assistant Type"
            
        case .inputNavigator:
            filterHeader.title = "Input Navigator Type"
        }
        
        return filterHeader
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let filterSection: Section = sections[indexPath.section]
        var filterOptions: [FilterOption]!
        
        // - get filter options
        switch (filterSection) {
            
        case .miscellaneous:
            filterOptions = miscFilterOptions
            
        case .positionConstraint:
            filterOptions = positionFilterOptions
        
        case .keyboardAssistant:
            filterOptions = keyboardAssistantFilterOptions
            
        case .inputNavigator:
            filterOptions = inputNavigatorFilterOptions
        }
        
        var tableCell: UITableViewCell?
        let filterOption: FilterOption = filterOptions[indexPath.row]
        let isLastRow: Bool = indexPath.row == filterOptions.count - 1
        var title: String = ""
        var filterOptionIsAvailable: Bool = false
        
        // - get table cell
        switch filterOption.filterInputType
        {
        case .filterInput:
            tableCell = filtersTableView.dequeueReusableCell(withIdentifier: FilterInputCell.reuseIdentifier, for: indexPath) as? FilterInputCell
            
        case .filterSwitch:
            tableCell = filtersTableView.dequeueReusableCell(withIdentifier: FilterSwitchCell.reuseIdentifier, for: indexPath) as? FilterSwitchCell
        }
        
        switch (filterSection)
        {
        case .miscellaneous:
            
            if let miscOption = filterOption as? MiscOption {
                
                filterOptionIsAvailable = true
                
                switch miscOption.type! {
                    
                case .positionOffset:
                    title = "Position Offset"
                    
                    if let inputTextField = (tableCell as? FilterInputCell)?.inputTextField {
                        if let offset = miscFilterOptionsDictionary[.positionOffset]?.inputValue.floatValue {
                            inputTextField.text = String(offset)
                        }
                        
                        inputTextField.keyboardType = .numberPad
                        inputTextField.delegate = self
                        positionOffsetTextField = inputTextField
                    }
                    
                case .shouldSetTextFieldDelegates:
                    title = "Should Set TextField Delegates"
                }
            }
            
        case .positionConstraint:
            
            if let positionOption = filterOption as? PositionConstraintOption {
                
                filterOptionIsAvailable = true
                
                switch positionOption.type! {
                case .viewBottomToTopOfKeyboard:
                    title = "View Bottom To Top Of Keyboard"
                    
                case .viewTopToTopOfScreen:
                    title = "View Top To Top Of Screen"
                }
            }
            
        case .keyboardAssistant:
            
            if let keyboardOption = filterOption as? KeyboardOption {
                
                filterOptionIsAvailable = availableKeyboardAssistantTypes.contains(keyboardOption.type)
                
                switch keyboardOption.type! {
                case .autoScrollView:
                    title = "Auto ScrollView"
                case .manualWithBottomConstraint:
                    title = "Manual ScrollView"
                case .manual:
                    title = "Manual"
                }
            }
            
        case .inputNavigator:
            
            if let navigatorOption = filterOption as? NavigatorOption {
                
                filterOptionIsAvailable = availableInputNavigatorTypes.contains(navigatorOption.type)
                
                switch navigatorOption.type! {
                    
                case .defaultController:
                    title = "Default Controller"
                    
                case .controller:
                    title = "Custom Controller"
                    
                case .customAccessoryView:
                    title = "Custom Accessory View"
                    
                case .keyboard:
                    title = "Keyboard Navigation"
                    
                case .keyboardAndDefaultController:
                    title = "Keyboard Navigation And Default Controller"
                    
                case .keyboardAndController:
                    title = "Keyboard Navigation And Custom Controller"
                    
                case .keyboardAndCustomAccessoryView:
                    title = "Keyboard Navigation And Custom Accessory View"
                }
            }
        }
        
        // - configure cell
        tableCell?.selectionStyle = .none
        
        if let filterableCell = tableCell as? FilterableCell {
            filterableCell.setTitle(title: title)
            filterableCell.setSeparatorLine(hidden: isLastRow)
        }
        
        if let switchCell = tableCell as? FilterSwitchCell {
            
            switchCell.delegate = self
            switchCell.filterSwitchIsOn = filterOption.inputValue.boolValue
            
            if filterOptionIsAvailable {
                switchCell.titleLabel.isEnabled = true
                switchCell.filterSwitchEnabled = true
            }
            else {
                switchCell.titleLabel.isEnabled = false
                switchCell.filterSwitchIsOn = false
                switchCell.filterSwitchEnabled = false
            }
        }
        
        return tableCell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let filterSection: Section = sections[indexPath.section]
        var filterOptions: [FilterOption]!
        
        switch filterSection {
            
        case .miscellaneous:
            filterOptions = miscFilterOptions
            
        case .positionConstraint:
            filterOptions = positionFilterOptions
            
        case .keyboardAssistant:
            filterOptions = keyboardAssistantFilterOptions
            
        case .inputNavigator:
            filterOptions = inputNavigatorFilterOptions
        }
        
        let filterOption: FilterOption = filterOptions[indexPath.row]
        
        switch filterOption.filterInputType {
        case .filterInput:
            return filterInputCellHeight
            
        case .filterSwitch:
            return filterSwitchCellHeight
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        closeKeyboard()
    }
}

// MARK: - UITextField

extension FiltersViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == positionOffsetTextField {
            if let textOffset = textField.text {
                if let positionOffset = Float(textOffset) {
                    miscFilterOptionsDictionary[.positionOffset]?.inputValue = NSNumber(value: positionOffset)
                }
            }
        }
    }
}

// MARK: - FilterSwitchCellDelegate

extension FiltersViewController: FilterSwitchCellDelegate {
    
    func filterSwitchCellSwitchChanged(filterSwitchCell: FilterSwitchCell) {
        if let indexPath = filtersTableView.indexPath(for: filterSwitchCell) {
            let filterSection: Section = sections[indexPath.section]
            
            switch filterSection {
                
            case .miscellaneous:
                let filterOption: MiscOption = miscFilterOptions[indexPath.row]
                let isActive: Bool = filterOption.inputValue.boolValue
                filterOption.inputValue = NSNumber(value: !isActive)
                
            case .positionConstraint:
                for option in positionFilterOptions {
                    option.inputValue = NSNumber(value: false)
                }
                
                let filterOption: FilterOption = positionFilterOptions[indexPath.row]
                filterOption.inputValue = NSNumber(value: true)
                
            case .keyboardAssistant:
                for option in keyboardAssistantFilterOptions {
                    option.inputValue = NSNumber(value: false)
                }
                
                let filterOption: FilterOption = keyboardAssistantFilterOptions[indexPath.row]
                filterOption.inputValue = NSNumber(value: true)
                
            case .inputNavigator:
                for option in inputNavigatorFilterOptions {
                    option.inputValue = NSNumber(value: false)
                }
                
                let filterOption: FilterOption = inputNavigatorFilterOptions[indexPath.row]
                filterOption.inputValue = NSNumber(value: true)
            }
            
            filtersTableView.reloadData()
        }
    }
}
