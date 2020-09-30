//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class CustomNavigatorController: UIView, NibBased, InputNavigatorAccessoryController {
        
    public var controllerView: UIView { return self }
    public weak var buttonDelegate: InputNavigatorAccessoryControllerDelegate?
        
    @IBOutlet public weak var previousButton: UIButton!
    @IBOutlet public weak var nextButton: UIButton!
    @IBOutlet public weak var doneButton: UIButton!
        
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
        
        previousButton.addTarget(self, action: #selector(handlePrevious(button:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(handleNext(button:)), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(handleDone(button:)), for: .touchUpInside)
    }
    
    @objc func handlePrevious(button: UIButton) {
        buttonDelegate?.inputNavigatorAccessoryControllerPreviousButtonTapped(accessoryController: self)
    }
    
    @objc func handleNext(button: UIButton) {
        buttonDelegate?.inputNavigatorAccessoryControllerNextButtonTapped(accessoryController: self)
    }
    
    @objc func handleDone(button: UIButton) {
        buttonDelegate?.inputNavigatorAccessoryControllerDoneButtonTapped(accessoryController: self)
    }
}
