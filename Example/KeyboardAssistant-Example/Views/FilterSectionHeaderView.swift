//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class FilterHeaderSectionView: UIView
{
    // MARK: - Outlets
    
    @IBOutlet weak var lbTitle: UILabel!
    
    // MARK: - Life Cycle
    
    public required init()
    {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        
        self.load()
    }
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.load()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.load()
    }
    
    // MARK: - Load
    
    private func load()
    {
        self.loadNibWithName(nibName: "FilterHeaderSectionView", constrainEdgesToSuperview: true)
    }
}
