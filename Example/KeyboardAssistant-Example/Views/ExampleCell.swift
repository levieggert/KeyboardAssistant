//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class ExampleCell: UITableViewCell {
    
    static let nibName: String = "ExampleCell"
    static let reuseIdentifier: String = "ExampleCellReuseIdentifier"
        
    @IBOutlet weak private var titleLabel: UILabel!
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
