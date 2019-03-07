//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class CustomNavigatorController: UIView, InputNavigatorAccessoryController
{
    // MARK: - InputNavigatorAccessoryController protocol
    
    public var controllerView: UIView { return self }
    public weak var buttonDelegate: InputNavigatorAccessoryControllerDelegate?
    
    // MARK: - Properties
    
    // MARK: - Outlets
    
    @IBOutlet public weak var btPrev: UIButton!
    @IBOutlet public weak var btNext: UIButton!
    @IBOutlet public weak var btDone: UIButton!
    
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
        self.loadNibWithName(nibName: "CustomNavigatorController", constrainEdgesToSuperview: true)
    }
    
    // MARK: - Actions
    
    @IBAction func handlePrev(button: UIButton)
    {
        if let buttonDelegate = self.buttonDelegate
        {
            buttonDelegate.inputNavigatorAccessoryControllerPreviousButtonTapped(accessoryController: self)
        }
    }
    
    @IBAction func handleNext(button: UIButton)
    {
        if let buttonDelegate = self.buttonDelegate
        {
            buttonDelegate.inputNavigatorAccessoryControllerNextButtonTapped(accessoryController: self)
        }
    }
    
    @IBAction func handleDone(button: UIButton)
    {
        if let buttonDelegate = self.buttonDelegate
        {
            buttonDelegate.inputNavigatorAccessoryControllerDoneButtonTapped(accessoryController: self)
        }
    }
}
