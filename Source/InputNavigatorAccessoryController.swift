//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

public protocol InputNavigatorAccessoryControllerDelegate: class {
    func inputNavigatorAccessoryControllerPreviousButtonTapped(accessoryController: InputNavigatorAccessoryController)
    func inputNavigatorAccessoryControllerNextButtonTapped(accessoryController: InputNavigatorAccessoryController)
    func inputNavigatorAccessoryControllerDoneButtonTapped(accessoryController: InputNavigatorAccessoryController)
}

public protocol InputNavigatorAccessoryController {
    var controllerView: UIView { get }
    var btPrev: UIButton! { get set }
    var btNext: UIButton! { get set }
    var btDone: UIButton! { get set }
    var buttonDelegate: InputNavigatorAccessoryControllerDelegate? { get set }
}
