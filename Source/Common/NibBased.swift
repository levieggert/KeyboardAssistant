//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

protocol NibBased: class {
    static var nib: UINib { get }
}

extension NibBased {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

extension NibBased where Self: UIView {
    
    func loadNib() {
        
        let contents: [Any]? = Self.nib.instantiate(withOwner: self, options: nil)
        
        if let views = contents as? [UIView] {
            
            if let rootView = views.first {
                
                addSubview(rootView)
                
                rootView.frame = bounds
                
                constraintEdgesToSuperview()
            }
        }
    }
}

extension UIView {
    
    fileprivate func constraintEdgesToSuperview() {
        
        if let superview = superview {
            
            translatesAutoresizingMaskIntoConstraints = false
            
            let leading: NSLayoutConstraint = NSLayoutConstraint(
                item: self,
                attribute: .leading,
                relatedBy: .equal,
                toItem: superview,
                attribute: .leading,
                multiplier: 1,
                constant: 0)
            
            let trailing: NSLayoutConstraint = NSLayoutConstraint(
                item: self,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: superview,
                attribute: .trailing,
                multiplier: 1,
                constant: 0)
            
            let top: NSLayoutConstraint = NSLayoutConstraint(
                item: self,
                attribute: .top,
                relatedBy: .equal,
                toItem: superview,
                attribute: .top,
                multiplier: 1,
                constant: 0)
            
            let bottom: NSLayoutConstraint = NSLayoutConstraint(
                item: self,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: superview,
                attribute: .bottom,
                multiplier: 1,
                constant: 0)
            
            superview.addConstraint(leading)
            superview.addConstraint(trailing)
            superview.addConstraint(top)
            superview.addConstraint(bottom)
        }
    }
}

