//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class FilterInputCell: UITableViewCell
{
    static let nibName: String = "FilterInputCell"
    static let reuseIdentifier: String = "FilterInputCellReuseIdentifier"
    
    // MARK: - Properties
    
    // MARK: - Outlets
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var txtInput: UITextField!
    @IBOutlet weak var separatorLine: UIView!
}
