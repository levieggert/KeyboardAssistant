//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

public protocol InputNavigatorAccessoryControllerDelegate: class
{
    func inputNavigatorAccessoryControllerPreviousButtonTapped(accessoryController: InputNavigatorAccessoryController)
    func inputNavigatorAccessoryControllerNextButtonTapped(accessoryController: InputNavigatorAccessoryController)
    func inputNavigatorAccessoryControllerDoneButtonTapped(accessoryController: InputNavigatorAccessoryController)
}

public protocol InputNavigatorAccessoryController
{
    var controllerView: UIView { get }
    var delegate: InputNavigatorAccessoryControllerDelegate? { get set }
}
