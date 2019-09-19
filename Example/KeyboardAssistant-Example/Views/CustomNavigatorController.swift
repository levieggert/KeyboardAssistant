//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class CustomNavigatorController: UIView, NibBased, InputNavigatorAccessoryController {
    
    // MARK: - InputNavigatorAccessoryController protocol
    
    public var controllerView: UIView { return self }
    public weak var buttonDelegate: InputNavigatorAccessoryControllerDelegate?
    
    // MARK: - Outlets
    
    @IBOutlet public weak var btPrev: UIButton!
    @IBOutlet public weak var btNext: UIButton!
    @IBOutlet public weak var btDone: UIButton!
    
    // MARK: - Life Cycle
    
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
    
    @IBAction func handlePrev(button: UIButton) {
        buttonDelegate?.inputNavigatorAccessoryControllerPreviousButtonTapped(accessoryController: self)
    }
    
    @IBAction func handleNext(button: UIButton) {
        buttonDelegate?.inputNavigatorAccessoryControllerNextButtonTapped(accessoryController: self)
    }
    
    @IBAction func handleDone(button: UIButton) {
        buttonDelegate?.inputNavigatorAccessoryControllerDoneButtonTapped(accessoryController: self)
    }
}
