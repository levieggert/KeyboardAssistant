//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class InputCell: UITableViewCell
{
    static let nibName: String = "InputCell"
    static let reuseIdentifier: String = "InputCellReuseIdentifier"
    
    // MARK: - Outlets
    
    @IBOutlet weak var lbInput: UILabel!
    @IBOutlet weak var txtInput: UITextField!
    @IBOutlet weak var separatorLine: UIView!
    
    // MARK: - Life Cycle
}
