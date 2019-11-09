//
//  Created by Levi Eggert.
//  Copyright © 2017 Levi Eggert. All rights reserved.
//

import Foundation

extension UserDefaults {
    static func saveData(data: Any?, key: String) {
        let standardUserDefaults = UserDefaults.standard
        standardUserDefaults.set(data, forKey: key)
        standardUserDefaults.synchronize()
    }
    
    static func getData(key:String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    static func deleteData() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
        }
    }
}
