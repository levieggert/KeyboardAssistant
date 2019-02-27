//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class ExampleCell: UITableViewCell
{
    static let nibName: String = "ExampleCell"
    static let reuseIdentifier: String = "ExampleCellReuseIdentifier"
    
    // MARK: - Outlets
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var separatorLine: UIView!
}
