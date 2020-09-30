//
//  Created by Levi Eggert.
//  Copyright © 2020 Levi Eggert. All rights reserved.
//

import Foundation

public enum KeyboardAssistantRepositionType {
    
    case autoScrollView
    case manualWithBottomConstraint
    case manual
    
    public static var allTypes: [KeyboardAssistantRepositionType] {
        return [.autoScrollView, .manualWithBottomConstraint, .manual]
    }
}
