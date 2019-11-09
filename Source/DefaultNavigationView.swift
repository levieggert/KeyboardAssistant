//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

public class DefaultNavigationView: UIView, NibBased, InputNavigatorAccessoryController {
    
    // MARK: - InputNavigatorAccessoryController protocol
    
    public var controllerView: UIView { return self }
    public weak var buttonDelegate: InputNavigatorAccessoryControllerDelegate?
    
    // MARK: - Properties
        
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
        
        btPrev.setTitle(nil, for: .normal)
        btNext.setTitle(nil, for: .normal)
        
        layer.shadowOffset = CGSize(width: 0, height: -1)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.2
        
        setButtonColors(color: .black)
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
        
    public func setButtonColors(color: UIColor) {
        setBtPrevColor(color: color)
        setBtNextColor(color: color)
        setBtDoneColor(color: color)
    }
    
    public func setBtPrevColor(color: UIColor) {
        btPrev.setImageColor(color: color)
    }
    
    public func setBtNextColor(color: UIColor) {
        btNext.setImageColor(color: color)
    }
    
    public func setBtDoneColor(color: UIColor) {
        btDone.setTitleColor(color, for: .normal)
    }
}
