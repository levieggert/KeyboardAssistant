//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

protocol FiltersViewControllerDelegate: class
{
    func filtersViewControllerApplyFilters(filtersViewController: FiltersViewController, keyboardAssistantType: KeyboardAssistant.AssistantType, inputNavigatorType: InputNavigator.NavigatorType, positionConstraint: KeyboardAssistant.RepositionConstraint, positionOffset: CGFloat, shouldSetTextFieldDelegates: Bool)
}

class FiltersViewController: UIViewController
{
    class FilterOption
    {
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
        var type: KeyboardAssistant.RepositionConstraint!
    }
    
    enum Section
    {
        case miscellaneous
        case positionConstraint
        case keyboardAssistant
        case inputNavigator
    }
    
    enum MiscType
    {
        case positionOffset
        case shouldSetTextFieldDelegates
        
        static var allTypes: [MiscType] {
            return [.positionOffset, .shouldSetTextFieldDelegates]
        }
    }
    
    enum FilterInputType
    {
        case filterInput
        case filterSwitch
    }
    
    // MARK: - Properties
    
    private let sections: [Section] = [.miscellaneous, .positionConstraint, .keyboardAssistant, .inputNavigator]
    private let filterInputCellHeight: CGFloat = 100
    private let filterSwitchCellHeight: CGFloat = 65
    
    private var miscFilterOptionsDictionary: [MiscType: MiscOption] = Dictionary()
    private var miscFilterOptions: [MiscOption] = Array()
    private var positionFilterOptionsDictionary: [KeyboardAssistant.RepositionConstraint: PositionConstraintOption] = Dictionary()
    private var positionFilterOptions: [PositionConstraintOption] = Array()
    private var keyboardAssistantFilterOptionsDictionary: [KeyboardAssistant.AssistantType: KeyboardOption] = Dictionary()
    private var keyboardAssistantFilterOptions: [KeyboardOption] = Array()
    private var inputNavigatorFilterOptionsDictionary: [InputNavigator.NavigatorType: NavigatorOption] = Dictionary()
    private var inputNavigatorFilterOptions: [NavigatorOption] = Array()
    
    private weak var positionOffsetTextField: UITextField?
    
    var keyboardAssistant: KeyboardAssistant?
    var availableKeyboardAssistantTypes: [KeyboardAssistant.AssistantType] = Array()
    var availableInputNavigatorTypes: [InputNavigator.NavigatorType] = Array()
    
    weak var delegate: FiltersViewControllerDelegate?
    
    // MARK: - Outlets
    
    @IBOutlet weak var filtersTableView: UITableView!
    @IBOutlet weak var btApplyFilters: UIButton!
    
    // MARK: - Life Cycle
    
    deinit
    {
        print("deinit: \(type(of: self))")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // - misc options
        var miscOption: MiscOption!
        for miscType in MiscType.allTypes
        {
            miscOption = MiscOption()
            miscOption.type = miscType
            self.miscFilterOptionsDictionary[miscType] = miscOption
            self.miscFilterOptions.append(miscOption)
        }
        
        self.miscFilterOptionsDictionary[.positionOffset]?.filterInputType = .filterInput
        self.miscFilterOptionsDictionary[.positionOffset]?.inputValue = NSNumber(value: 20)
        self.miscFilterOptionsDictionary[.shouldSetTextFieldDelegates]?.filterInputType = .filterSwitch
        self.miscFilterOptionsDictionary[.shouldSetTextFieldDelegates]?.inputValue = NSNumber(value: true)
        
        // - position constraint options
        var positionOption: PositionConstraintOption!
        for positionType in KeyboardAssistant.RepositionConstraint.all
        {
            positionOption = PositionConstraintOption()
            positionOption.type = positionType
            self.positionFilterOptionsDictionary[positionType] = positionOption
            self.positionFilterOptions.append(positionOption)
        }
        
        // - keyboard assistant options
        var keyboardOption: KeyboardOption!
        for assistantType in KeyboardAssistant.AssistantType.allTypes
        {
            keyboardOption = KeyboardOption()
            keyboardOption.type = assistantType
            self.keyboardAssistantFilterOptionsDictionary[assistantType] = keyboardOption
            self.keyboardAssistantFilterOptions.append(keyboardOption)
        }
        
        // - input navigator options
        var navigatorOption: NavigatorOption!
        for navigatorType in InputNavigator.NavigatorType.allTypes
        {
            navigatorOption = NavigatorOption()
            navigatorOption.type = navigatorType
            self.inputNavigatorFilterOptionsDictionary[navigatorType] = navigatorOption
            self.inputNavigatorFilterOptions.append(navigatorOption)
        }
        
        //filtersTableView
        self.filtersTableView.register(UINib(nibName: FilterSwitchCell.nibName, bundle: nil), forCellReuseIdentifier: FilterSwitchCell.reuseIdentifier)
        self.filtersTableView.register(UINib(nibName: FilterInputCell.nibName, bundle: nil), forCellReuseIdentifier: FilterInputCell.reuseIdentifier)
        self.filtersTableView.separatorStyle = .none
        
        //keyboardAssistant
        if let keyboardAssistant = self.keyboardAssistant
        {
            if let filterOption = self.keyboardAssistantFilterOptionsDictionary[keyboardAssistant.type]
            {
                filterOption.inputValue = NSNumber(value: true)
            }
            
            if let filterOption = self.inputNavigatorFilterOptionsDictionary[keyboardAssistant.navigator.type]
            {
                filterOption.inputValue = NSNumber(value: true)
            }
            
            self.miscFilterOptionsDictionary[.positionOffset]?.inputValue = NSNumber(value: Float(keyboardAssistant.repositionOffset))
            
            if let filterOption = self.positionFilterOptionsDictionary[keyboardAssistant.repositionConstraint]
            {
                filterOption.inputValue = NSNumber(value: true)
            }
        }
    }
    
    private func closeKeyboard()
    {
        if let positionOffsetTextField = self.positionOffsetTextField
        {
            positionOffsetTextField.resignFirstResponder()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func handleCancel(barButtonItem: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleApplyFilters(button: UIButton)
    {
        if let delegate = self.delegate
        {
            var keyboardAssistantType: KeyboardAssistant.AssistantType = .autoScrollView
            var inputNavigatorType: InputNavigator.NavigatorType = .defaultController
            var positionConstraint: KeyboardAssistant.RepositionConstraint = .viewBottomToTopOfKeyboard
            var positionOffset: CGFloat = 20
            var shouldSetTextFieldDelegates: Bool = true
            
            for keyboardOption in self.keyboardAssistantFilterOptions
            {
                if (keyboardOption.inputValue.boolValue)
                {
                    keyboardAssistantType = keyboardOption.type
                    break
                }
            }
            
            for navigatorOption in self.inputNavigatorFilterOptions
            {
                if (navigatorOption.inputValue.boolValue)
                {
                    inputNavigatorType = navigatorOption.type
                    break
                }
            }
            
            for positionOption in self.positionFilterOptions
            {
                if (positionOption.inputValue.boolValue)
                {
                    positionConstraint = positionOption.type
                    break
                }
            }
            
            if let pPositionOffset = self.miscFilterOptionsDictionary[.positionOffset]?.inputValue.floatValue
            {
                positionOffset = CGFloat(pPositionOffset)
            }
            
            if let pShouldSetTextFieldDelegates = self.miscFilterOptionsDictionary[.shouldSetTextFieldDelegates]?.inputValue.boolValue
            {
                shouldSetTextFieldDelegates = pShouldSetTextFieldDelegates
            }
            
            delegate.filtersViewControllerApplyFilters(filtersViewController: self, keyboardAssistantType: keyboardAssistantType, inputNavigatorType: inputNavigatorType, positionConstraint: positionConstraint, positionOffset: positionOffset, shouldSetTextFieldDelegates: shouldSetTextFieldDelegates)
        }
    }
}

extension FiltersViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let filterSection: Section = self.sections[section]
        
        switch (filterSection)
        {
        case .miscellaneous:
            return self.miscFilterOptions.count
            
        case .positionConstraint:
            return self.positionFilterOptions.count
            
        case .keyboardAssistant:
            return self.keyboardAssistantFilterOptions.count
            
        case .inputNavigator:
            return self.inputNavigatorFilterOptions.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.closeKeyboard()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let filterHeader: FilterHeaderSectionView = FilterHeaderSectionView()
        
        let filterSection: Section = self.sections[section]
        
        switch (filterSection)
        {
        case .miscellaneous:
            filterHeader.lbTitle.text = "Miscellaneous Options"
            
        case .positionConstraint:
            filterHeader.lbTitle.text = "Position Constraint"
            
        case .keyboardAssistant:
            filterHeader.lbTitle.text = "Keyboard Assistant Type"
            
        case .inputNavigator:
            filterHeader.lbTitle.text = "Input Navigator Type"
        }
        
        return filterHeader
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let filterSection: Section = self.sections[indexPath.section]
        var filterOptions: [FilterOption]!
        
        // - get filter options
        switch (filterSection)
        {
        case .miscellaneous:
            filterOptions = self.miscFilterOptions
            
        case .positionConstraint:
            filterOptions = self.positionFilterOptions
        
        case .keyboardAssistant:
            filterOptions = self.keyboardAssistantFilterOptions
            
        case .inputNavigator:
            filterOptions = self.inputNavigatorFilterOptions
        }
        
        var tableCell: UITableViewCell?
        let filterOption: FilterOption = filterOptions[indexPath.row]
        let isLastRow: Bool = indexPath.row == filterOptions.count - 1
        var title: String = ""
        var filterOptionIsAvailable: Bool = false
        
        // - get table cell
        switch (filterOption.filterInputType)
        {
        case .filterInput:
            tableCell = self.filtersTableView.dequeueReusableCell(withIdentifier: FilterInputCell.reuseIdentifier, for: indexPath) as? FilterInputCell
            
        case .filterSwitch:
            tableCell = self.filtersTableView.dequeueReusableCell(withIdentifier: FilterSwitchCell.reuseIdentifier, for: indexPath) as? FilterSwitchCell
        }
        
        switch (filterSection)
        {
        case .miscellaneous:
            
            if let miscOption = filterOption as? MiscOption
            {
                filterOptionIsAvailable = true
                
                switch (miscOption.type!)
                {
                case .positionOffset:
                    title = "Position Offset"
                    
                    if let txtInput = (tableCell as? FilterInputCell)?.txtInput
                    {
                        if let offset = self.miscFilterOptionsDictionary[.positionOffset]?.inputValue.floatValue
                        {
                            txtInput.text = String(offset)
                        }
                        
                        txtInput.keyboardType = .numberPad
                        txtInput.delegate = self
                        self.positionOffsetTextField = txtInput
                    }
                    
                case .shouldSetTextFieldDelegates:
                    title = "Should Set TextField Delegates"
                }
            }
            
        case .positionConstraint:
            
            if let positionOption = filterOption as? PositionConstraintOption
            {
                filterOptionIsAvailable = true
                
                switch (positionOption.type!)
                {
                case .viewBottomToTopOfKeyboard:
                    title = "View Bottom To Top Of Keyboard"
                    
                case .viewTopToTopOfScreen:
                    title = "View Top To Top Of Screen"
                }
            }
            
        case .keyboardAssistant:
            
            if let keyboardOption = filterOption as? KeyboardOption
            {
                filterOptionIsAvailable = self.availableKeyboardAssistantTypes.contains(keyboardOption.type)
                
                switch (keyboardOption.type!)
                {
                case .autoScrollView:
                    title = "Auto ScrollView"
                case .manualWithBottomConstraint:
                    title = "Manual ScrollView"
                case .manual:
                    title = "Manual"
                }
            }
            
        case .inputNavigator:
            
            if let navigatorOption = filterOption as? NavigatorOption
            {
                filterOptionIsAvailable = self.availableInputNavigatorTypes.contains(navigatorOption.type)
                
                switch (navigatorOption.type!)
                {
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
        
        if let filterableCell = tableCell as? FilterableCell
        {
            
            filterableCell.lbTitle.text = title
            
            if (!isLastRow)
            {
                filterableCell.separatorLine.isHidden = false
            }
            else
            {
                filterableCell.separatorLine.isHidden = true
            }
        }
        
        if let switchCell = tableCell as? FilterSwitchCell
        {
            switchCell.delegate = self
            switchCell.filterSwitch.isOn = filterOption.inputValue.boolValue
            
            if (filterOptionIsAvailable)
            {
                switchCell.lbTitle.isEnabled = true
                switchCell.filterSwitch.isEnabled = true
            }
            else
            {
                switchCell.lbTitle.isEnabled = false
                switchCell.filterSwitch.isOn = false
                switchCell.filterSwitch.isEnabled = false
            }
        }
        
        return tableCell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let filterSection: Section = self.sections[indexPath.section]
        var filterOptions: [FilterOption]!
        
        switch (filterSection)
        {
        case .miscellaneous:
            filterOptions = self.miscFilterOptions
            
        case .positionConstraint:
            filterOptions = self.positionFilterOptions
            
        case .keyboardAssistant:
            filterOptions = self.keyboardAssistantFilterOptions
            
        case .inputNavigator:
            filterOptions = self.inputNavigatorFilterOptions
        }
        
        let filterOption: FilterOption = filterOptions[indexPath.row]
        
        switch (filterOption.filterInputType)
        {
        case .filterInput:
            return self.filterInputCellHeight
            
        case .filterSwitch:
            return self.filterSwitchCellHeight
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        self.closeKeyboard()
    }
}

// MARK: - UITextField

extension FiltersViewController: UITextFieldDelegate
{
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if (textField == self.positionOffsetTextField)
        {
            if let textOffset = textField.text
            {
                if let positionOffset = Float(textOffset)
                {
                    self.miscFilterOptionsDictionary[.positionOffset]?.inputValue = NSNumber(value: positionOffset)
                }
            }
        }
    }
}

// MARK: - FilterSwitchCellDelegate

extension FiltersViewController: FilterSwitchCellDelegate
{
    func filterSwitchCellSwitchChanged(filterSwitchCell: FilterSwitchCell)
    {
        if let indexPath = self.filtersTableView.indexPath(for: filterSwitchCell)
        {
            let filterSection: Section = self.sections[indexPath.section]
            
            switch (filterSection)
            {
            case .miscellaneous:
                let filterOption: MiscOption = self.miscFilterOptions[indexPath.row]
                let isActive: Bool = filterOption.inputValue.boolValue
                filterOption.inputValue = NSNumber(value: !isActive)
                
            case .positionConstraint:
                for option in self.positionFilterOptions {
                    option.inputValue = NSNumber(value: false)
                }
                
                let filterOption: FilterOption = self.positionFilterOptions[indexPath.row]
                filterOption.inputValue = NSNumber(value: true)
                
            case .keyboardAssistant:
                for option in self.keyboardAssistantFilterOptions {
                    option.inputValue = NSNumber(value: false)
                }
                
                let filterOption: FilterOption = self.keyboardAssistantFilterOptions[indexPath.row]
                filterOption.inputValue = NSNumber(value: true)
                
            case .inputNavigator:
                for option in self.inputNavigatorFilterOptions {
                    option.inputValue = NSNumber(value: false)
                }
                
                let filterOption: FilterOption = self.inputNavigatorFilterOptions[indexPath.row]
                filterOption.inputValue = NSNumber(value: true)
            }
            
            self.filtersTableView.reloadData()
        }
    }
}
