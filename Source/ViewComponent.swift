//
//  Created by Levi Eggert.
//  Copyright © 2015 Levi Eggert. All rights reserved.
//

import UIKit

extension UIView
{
    func loadNibWithName(nibName: String, constrainEdgesToSuperview: Bool)
    {
        let isLoaded: Bool = self.subviews.count > 0
        
        if (!isLoaded)
        {
            let nib: [Any]? = Bundle(for: type(of: self)).loadNibNamed(nibName, owner: self, options: nil)
            
            var didLoad: Bool = false
            
            if let nib = nib as? [UIView]
            {
                if let view = nib.first
                {
                    didLoad = true
                    
                    self.addSubview(view)
                    
                    view.frame = self.bounds
                    
                    if (constrainEdgesToSuperview)
                    {
                        self.constraintEdgesToSuperview()
                    }
                    else
                    {
                        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    }
                }
            }
            
            if (!didLoad)
            {
                print("\nWARNING: Component: loadNibWithName() Failed to load nib with name: \(nibName)")
            }
        }
    }
    
    private func constraintEdgesToSuperview()
    {
        if let superview = self.superview
        {
            self.translatesAutoresizingMaskIntoConstraints = false
            
            let leading: NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
            
            let trailing: NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
            
            let top: NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: 0)
            
            let bottom: NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: 0)
            
            superview.addConstraint(leading)
            superview.addConstraint(trailing)
            superview.addConstraint(top)
            superview.addConstraint(bottom)
        }
    }
}

