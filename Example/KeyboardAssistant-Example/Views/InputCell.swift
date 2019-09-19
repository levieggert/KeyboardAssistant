//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class InputCell: UITableViewCell {
    
    static let nibName: String = "InputCell"
    static let reuseIdentifier: String = "InputCellReuseIdentifier"
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var inputTextField: UITextField!
    @IBOutlet weak private var separatorLine: UIView!
    
    var title: String? = nil {
        didSet {
            titleLabel.text = title
        }
    }
    
    var separatorLineIsHidden: Bool = false {
        didSet {
            separatorLine.isHidden = separatorLineIsHidden
        }
    }
}
