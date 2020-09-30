//
//  Created by Levi Eggert.
//  Copyright © 2020 Levi Eggert. All rights reserved.
//

import Foundation

public enum KeyboardAssistantPositionConstraint {
    
    case viewTopToTopOfScreen
    case viewBottomToTopOfKeyboard
    
    public static var all: [KeyboardAssistantPositionConstraint] {
        return [.viewTopToTopOfScreen, .viewBottomToTopOfKeyboard]
    }
}
