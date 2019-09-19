//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

protocol FilterSwitchCellDelegate: class {
    func filterSwitchCellSwitchChanged(filterSwitchCell: FilterSwitchCell)
}

class FilterSwitchCell: UITableViewCell, FilterableCell {
    
    static let nibName: String = "FilterSwitchCell"
    static let reuseIdentifier: String = "FilterSwitchCellReuseIdentifier"
    
    weak var delegate: FilterSwitchCellDelegate?
    
    @IBOutlet weak private(set) var titleLabel: UILabel!
    @IBOutlet weak private var filterSwitch: UISwitch!
    @IBOutlet weak private(set) var separatorLine: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        filterSwitch.isOn = false
    }
    
    var filterSwitchIsOn: Bool = false {
        didSet {
            filterSwitch.isOn = filterSwitchIsOn
        }
    }
    
    var filterSwitchEnabled: Bool = true {
        didSet {
            filterSwitch.isEnabled = filterSwitchEnabled
        }
    }
    
    @IBAction func handleFilterSwitchChanged() {
        delegate?.filterSwitchCellSwitchChanged(filterSwitchCell: self)
    }
}
