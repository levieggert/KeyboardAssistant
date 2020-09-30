//
//  Created by Levi Eggert.
//  Copyright © 2015 Levi Eggert. All rights reserved.
//

import Foundation

@objc
protocol NotificationHandler: class {
    func handleNotification(notification: Notification)
}

extension NotificationHandler {
    func addNotification(name: Notification.Name) {
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationHandler.handleNotification(notification:)), name: name, object: nil)
    }
    func removeNotification(name: Notification.Name) {
        NotificationCenter.default.removeObserver(self, name: name, object: nil)
    }
}
