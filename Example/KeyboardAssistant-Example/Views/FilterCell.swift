//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class FilterCell: UITableViewCell
{
    static let nibName: String = "FilterCell"
    static let reuseIdentifier: String = "FilterCellReuseIdentifier"
    
    // MARK: - Outlets
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var filterSwitch: UISwitch!
    @IBOutlet weak var separatorLine: UIView!
}
