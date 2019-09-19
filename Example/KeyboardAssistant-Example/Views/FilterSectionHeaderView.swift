//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class FilterHeaderSectionView: UIView, NibBased {
    
    @IBOutlet weak private var titleLabel: UILabel!
    
    public required init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        initialize()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        loadNib()
    }
    
    var title: String? = nil {
        didSet {
            titleLabel.text = title
        }
    }
}
