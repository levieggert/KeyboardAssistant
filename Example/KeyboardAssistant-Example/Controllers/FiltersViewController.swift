//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

protocol FiltersViewControllerDelegate: class
{
    func filtersViewControllerApplyFilters(filtersViewController: FiltersViewController, keyboardAssistantType: KeyboardAssistant.AssistantType, inputNavigatorType: InputNavigator.NavigatorType)
}

class FiltersViewController: UIViewController
{
    class FilterOption
    {
        var isActive: Bool = false
    }
    
    class KeyboardOption: FilterOption
    {
        var type: KeyboardAssistant.AssistantType!
    }
    
    class NavigatorOption: FilterOption
    {
        var type: InputNavigator.NavigatorType!
    }
    
    class MiscOption: FilterOption
    {
        var type: MiscType!
        var inputValue: NSNumber?
        var filterInputType: FilterInputType = .filterSwitch
    }
    
    enum Section
    {
        case miscellaneous
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
    
    private let sections: [Section] = [.miscellaneous, .keyboardAssistant, .inputNavigator]
    private let filterInputCellHeight: CGFloat = 100
    private let filterSwitchCellHeight: CGFloat = 65
    
    private var miscFilterOptionsDictionary: [MiscType: MiscOption] = Dictionary()
    private var miscFilterOptions: [MiscOption] = Array()
    private var keyboardAssistantFilterOptionsDictionary: [KeyboardAssistant.AssistantType: KeyboardOption] = Dictionary()
    private var keyboardAssistantFilterOptions: [KeyboardOption] = Array()
    private var inputNavigatorFilterOptionsDictionary: [InputNavigator.NavigatorType: NavigatorOption] = Dictionary()
    private var inputNavigatorFilterOptions: [NavigatorOption] = Array()
    
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
        
        var keyboardOption: KeyboardOption!
        for assistantType in KeyboardAssistant.AssistantType.allTypes
        {
            keyboardOption = KeyboardOption()
            keyboardOption.type = assistantType
            self.keyboardAssistantFilterOptionsDictionary[assistantType] = keyboardOption
            self.keyboardAssistantFilterOptions.append(keyboardOption)
        }
        
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
                filterOption.isActive = true
            }
            
            if let filterOption = self.inputNavigatorFilterOptionsDictionary[keyboardAssistant.navigator.type]
            {
                filterOption.isActive = true
            }
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
            
            for keyboardOption in self.keyboardAssistantFilterOptions
            {
                if (keyboardOption.isActive)
                {
                    keyboardAssistantType = keyboardOption.type
                    break
                }
            }
            
            for navigatorOption in self.inputNavigatorFilterOptions
            {
                if (navigatorOption.isActive)
                {
                    inputNavigatorType = navigatorOption.type
                    break
                }
            }
            
            delegate.filtersViewControllerApplyFilters(filtersViewController: self, keyboardAssistantType: keyboardAssistantType, inputNavigatorType: inputNavigatorType)
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
            
        case .keyboardAssistant:
            return self.keyboardAssistantFilterOptions.count
            
        case .inputNavigator:
            return self.inputNavigatorFilterOptions.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let filterHeader: FilterHeaderSectionView = FilterHeaderSectionView()
        
        let filterSection: Section = self.sections[section]
        
        switch (filterSection)
        {
        case .miscellaneous:
            filterHeader.lbTitle.text = "Miscellaneous Options"
            
        case .keyboardAssistant:
            filterHeader.lbTitle.text = "Keyboard Assistant"
            
        case .inputNavigator:
            filterHeader.lbTitle.text = "Input Navigator"
        }
        
        return filterHeader
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let filterSection: Section = self.sections[indexPath.section]
        var filterSwitchCell: FilterSwitchCell?
        var filterInputCell: FilterInputCell?
        var filterOptions: [FilterOption]!
        
        // - get cell and filter options
        switch (filterSection)
        {
        case .miscellaneous:
            let miscOption: MiscOption = self.miscFilterOptions[indexPath.row]
            
            switch (miscOption.filterInputType)
            {
            case .filterSwitch:
                filterSwitchCell = self.filtersTableView.dequeueReusableCell(withIdentifier: FilterSwitchCell.reuseIdentifier, for: indexPath) as? FilterSwitchCell
            
            case .filterInput:
                filterInputCell = self.filtersTableView.dequeueReusableCell(withIdentifier: FilterInputCell.reuseIdentifier, for: indexPath) as? FilterInputCell
            }
            
            filterOptions = self.miscFilterOptions
        
        case .keyboardAssistant:
            filterSwitchCell = self.filtersTableView.dequeueReusableCell(withIdentifier: FilterSwitchCell.reuseIdentifier, for: indexPath) as? FilterSwitchCell
            filterOptions = self.keyboardAssistantFilterOptions
            
        case .inputNavigator:
            filterSwitchCell = self.filtersTableView.dequeueReusableCell(withIdentifier: FilterSwitchCell.reuseIdentifier, for: indexPath) as? FilterSwitchCell
            filterOptions = self.inputNavigatorFilterOptions
        }
        
        let filterOption: FilterOption = filterOptions[indexPath.row]
        let isLastRow: Bool = indexPath.row == filterOptions.count - 1
        var title: String = ""
        var filterOptionIsAvailable: Bool = false
        
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
                    
                case .shouldSetTextFieldDelegates:
                    title = "Should Set TextField Delegates"
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
        if let switchCell = filterSwitchCell
        {
            switchCell.delegate = self
            switchCell.selectionStyle = .none
            switchCell.lbTitle.text = title
            switchCell.filterSwitch.isOn = filterOption.isActive
            
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
            
            if (!isLastRow) {
                switchCell.separatorLine.isHidden = false
            }
            else {
                switchCell.separatorLine.isHidden = true
            }
        }
        else if let inputCell = filterInputCell
        {
            inputCell.selectionStyle = .none
            inputCell.lbTitle.text = title
            inputCell.txtInput.text = ""
            
            if (!isLastRow) {
                inputCell.separatorLine.isHidden = false
            }
            else {
                inputCell.separatorLine.isHidden = true
            }
        }
        
        if let filterSwitchCell = filterSwitchCell
        {
            return filterSwitchCell
        }
        else if let filterInputCell = filterInputCell
        {
            return filterInputCell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let filterSection: Section = self.sections[indexPath.section]
        
        if (filterSection == .miscellaneous)
        {
            let miscOption: MiscOption = self.miscFilterOptions[indexPath.row]
            
            if (miscOption.filterInputType == .filterInput)
            {
                return self.filterInputCellHeight
            }
        }
        
        return self.filterSwitchCellHeight
    }
}

// MARK: - FilterCellDelegate

extension FiltersViewController: FilterSwitchCellDelegate
{
    func filterSwitchCellSwitchChanged(filterSwitchCell: FilterSwitchCell)
    {
        if let indexPath = self.filtersTableView.indexPath(for: filterSwitchCell)
        {
            let filterSection: Section = self.sections[indexPath.section]
            var filterOptions: [FilterOption]!
            
            switch (filterSection)
            {
            case .miscellaneous:
                filterOptions = self.miscFilterOptions
                let filterOption: FilterOption = filterOptions[indexPath.row]
                filterOption.isActive = !filterOption.isActive
                
            case .keyboardAssistant:
                filterOptions = self.keyboardAssistantFilterOptions
                for option in filterOptions {
                    option.isActive = false
                }
                
                let filterOption: FilterOption = filterOptions[indexPath.row]
                filterOption.isActive = true
                
            case .inputNavigator:
                filterOptions = self.inputNavigatorFilterOptions
                for option in filterOptions {
                    option.isActive = false
                }
                
                let filterOption: FilterOption = filterOptions[indexPath.row]
                filterOption.isActive = true
            }
            
            self.filtersTableView.reloadData()
        }
    }
}
