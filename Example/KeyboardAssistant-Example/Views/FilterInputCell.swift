//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class FilterInputCell: UITableViewCell, FilterableCell {
    
    static let nibName: String = "FilterInputCell"
    static let reuseIdentifier: String = "FilterInputCellReuseIdentifier"
    
    @IBOutlet weak private(set) var titleLabel: UILabel!
    @IBOutlet weak private(set) var inputTextField: UITextField!
    @IBOutlet weak private(set) var separatorLine: UIView!
}
