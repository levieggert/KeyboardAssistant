//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

public class DefaultNavigationView: UIView, InputNavigatorAccessoryController
{
    // MARK: - InputNavigatorAccessoryController protocol
    
    public var controllerView: UIView { return self }
    public weak var delegate: InputNavigatorAccessoryControllerDelegate?
    
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
        self.loadNibWithName(nibName: "DefaultNavigationView", constrainEdgesToSuperview: true)
        
        // top shadow
        self.layer.shadowOffset = CGSize(width: 0, height: -1)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.2
        
        // button colors
        self.setButtonColors(color: .black)
    }
    
    // MARK: - Actions
    
    @IBAction func handlePrev(button: UIButton)
    {
        if let delegate = self.delegate
        {
            delegate.inputNavigatorAccessoryControllerPreviousButtonTapped(accessoryController: self)
        }
    }
    
    @IBAction func handleNext(button: UIButton)
    {
        if let delegate = self.delegate
        {
            delegate.inputNavigatorAccessoryControllerNextButtonTapped(accessoryController: self)
        }
    }
    
    @IBAction func handleDone(button: UIButton)
    {        
        if let delegate = self.delegate
        {
            delegate.inputNavigatorAccessoryControllerDoneButtonTapped(accessoryController: self)
        }
    }
    
    // MARK: - Colors
    
    public func setButtonColors(color: UIColor)
    {
        self.setBtPrevColor(color: color)
        self.setBtNextColor(color: color)
        self.setBtDoneColor(color: color)
    }
    
    public func setBtPrevColor(color: UIColor)
    {
        self.btPrev.setImageColor(color: color)
    }
    
    public func setBtNextColor(color: UIColor)
    {
        self.btNext.setImageColor(color: color)
    }
    
    public func setBtDoneColor(color: UIColor)
    {
        self.btDone.setTitleColor(color, for: .normal)
    }
}
