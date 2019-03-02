//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

// MARK: -
extension UIButton
{
    func setImageColor(color: UIColor)
    {
        if let image = self.image(for: .normal)
        {
            let newImage: UIImage = image.withRenderingMode(.alwaysTemplate)
            self.setImage(newImage, for: .normal)
            self.tintColor = color
        }
    }
}

// MARK: -
extension UIColor
{
    static func color(hex: Int, alpha: CGFloat = 1) -> UIColor
    {
        let red: Int = (hex >> 16) & 0xff
        let green: Int = (hex >> 8) & 0xff
        let blue: Int = hex & 0xff
        
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}
