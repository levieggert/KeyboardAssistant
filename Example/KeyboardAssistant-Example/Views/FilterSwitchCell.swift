//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

protocol FilterSwitchCellDelegate: class
{
    func filterSwitchCellSwitchChanged(filterSwitchCell: FilterSwitchCell)
}

class FilterSwitchCell: UITableViewCell
{
    static let nibName: String = "FilterSwitchCell"
    static let reuseIdentifier: String = "FilterSwitchCellReuseIdentifier"
    
    // MARK: - Properties
    
    weak var delegate: FilterSwitchCellDelegate?
    
    // MARK: - Outlets
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var filterSwitch: UISwitch!
    @IBOutlet weak var separatorLine: UIView!
    
    // MARK: - Life Cycle
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        self.filterSwitch.isOn = false
    }
    
    // MARK: - Actions
    
    @IBAction func handleFilterSwitchChanged()
    {
        if let delegate = self.delegate
        {
            delegate.filterSwitchCellSwitchChanged(filterSwitchCell: self)
        }
    }
}
