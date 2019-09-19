//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

protocol FilterableCell {
    var titleLabel: UILabel! { get }
    var separatorLine: UIView! { get }
}

extension FilterableCell {
    func setTitle(title: String?) {
        titleLabel.text = title
    }
    func setSeparatorLine(hidden: Bool) {
        separatorLine.isHidden = hidden
    }
}
