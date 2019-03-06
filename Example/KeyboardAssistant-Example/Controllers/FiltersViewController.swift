//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController
{
    class FilterOption
    {
        enum FilterType
        {
            case keyboardAssistant
            case inputNavigator
        }
        
        private(set) var id: Int = 0
        var title: String = ""
        var isActive: Bool = false
        
        required init(type: FilterOption.FilterType, id: Int)
        {
            self.id = id
        }
    }
    
    enum Section
    {
        case keyboardAssistant
        case inputNavigator
    }
    
    enum KeyboardAssistantIds: Int
    {
        case autoScrollView = 0
        case manualScrollView = 1
        case manual = 2
    }
    
    enum InputNavigatorIds: Int
    {
        case createDefaultController = 0
        case createController = 1
        case createCustomAccessoryView = 2
        case createKeyboardNavigation = 3
        case createKeyboardNavigationAndDefaultController = 4
        case createKeyboardNavigationAndController = 5
        case createKeyboardNavigationAndCustomAccessoryView = 6
    }
    
    // MARK: - Properties
    
    private let sections: [Section] = [.keyboardAssistant, .inputNavigator]
    
    private var keyboardAssistantFilterOptions: [FilterOption] = Array()
    private var inputNavigatorFilterOptions: [FilterOption] = Array()
    
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
    
        self.keyboardAssistantFilterOptions.append(FilterOption(type: .keyboardAssistant, id: KeyboardAssistantIds.autoScrollView.rawValue))
        self.keyboardAssistantFilterOptions.append(FilterOption(type: .keyboardAssistant, id: KeyboardAssistantIds.manualScrollView.rawValue))
        self.keyboardAssistantFilterOptions.append(FilterOption(type: .keyboardAssistant, id: KeyboardAssistantIds.manual.rawValue))
        
        self.inputNavigatorFilterOptions.append(FilterOption(type: .inputNavigator, id: InputNavigatorIds.createDefaultController.rawValue))
        self.inputNavigatorFilterOptions.append(FilterOption(type: .inputNavigator, id: InputNavigatorIds.createController.rawValue))
        self.inputNavigatorFilterOptions.append(FilterOption(type: .inputNavigator, id: InputNavigatorIds.createCustomAccessoryView.rawValue))
        self.inputNavigatorFilterOptions.append(FilterOption(type: .inputNavigator, id: InputNavigatorIds.createKeyboardNavigation.rawValue))
        self.inputNavigatorFilterOptions.append(FilterOption(type: .inputNavigator, id: InputNavigatorIds.createKeyboardNavigationAndDefaultController.rawValue))
        self.inputNavigatorFilterOptions.append(FilterOption(type: .inputNavigator, id: InputNavigatorIds.createKeyboardNavigationAndController.rawValue))
        self.inputNavigatorFilterOptions.append(FilterOption(type: .inputNavigator, id: InputNavigatorIds.createKeyboardNavigationAndCustomAccessoryView.rawValue))
        
        //filtersTableView
        self.filtersTableView.register(UINib(nibName: FilterCell.nibName, bundle: nil), forCellReuseIdentifier: FilterCell.reuseIdentifier)
        self.filtersTableView.separatorStyle = .none
    }
    
    // MARK: - Actions
    
    @IBAction func handleCancel(barButtonItem: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleApplyFilters(button: UIButton)
    {
        
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
        case .keyboardAssistant:
            filterHeader.lbTitle.text = "Keyboard Assistant"
            
        case .inputNavigator:
            filterHeader.lbTitle.text = "Input Navigator"
        }
        
        return filterHeader
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: FilterCell = self.filtersTableView.dequeueReusableCell(withIdentifier: FilterCell.reuseIdentifier, for: indexPath) as! FilterCell
        
        let filterSection: Section = self.sections[indexPath.section]
        var filterOptions: [FilterOption]!
        var filterOption: FilterOption!
        var isLastRow: Bool = false
        
        cell.selectionStyle = .none
        cell.lbTitle.text = ""
        cell.filterSwitch.isOn = false
        
        var title: String = ""
        
        switch (filterSection)
        {
        case .keyboardAssistant:
            
            filterOptions = self.keyboardAssistantFilterOptions
            filterOption = filterOptions[indexPath.row]
            
            if let id = KeyboardAssistantIds(rawValue: filterOption.id)
            {
                switch (id)
                {
                case .autoScrollView:
                    title = "Auto ScrollView"
                case .manualScrollView:
                    title = "Manual ScrollView"
                case .manual:
                    title = "Manual"
                }
            }
            
        case .inputNavigator:
            filterOptions = self.inputNavigatorFilterOptions
            filterOption = filterOptions[indexPath.row]
            
            if let id = InputNavigatorIds(rawValue: filterOption.id)
            {
                switch (id)
                {
                case .createDefaultController:
                    title = "Default Controller"
                    
                case .createController:
                    title = "Custom Controller"
                    
                case .createCustomAccessoryView:
                    title = "Custom Accessory View"
                    
                case .createKeyboardNavigation:
                    title = "Keyboard Navigation"
                    
                case .createKeyboardNavigationAndDefaultController:
                    title = "Keyboard Navigation And Default Controller"
                    
                case .createKeyboardNavigationAndController:
                    title = "Keyboard Navigation And Custom Controller"
                    
                case .createKeyboardNavigationAndCustomAccessoryView:
                    title = "Keyboard Navigation And Custom Accessory View"
                }
            }
        }
        
        cell.lbTitle.text = title
        
        isLastRow = indexPath.row == filterOptions.count - 1
        
        if (!isLastRow)
        {
            cell.separatorLine.isHidden = false
        }
        else
        {
            cell.separatorLine.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 65
    }
}
