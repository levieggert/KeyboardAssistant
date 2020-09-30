//
//  Created by Levi Eggert.
//  Copyright © 2020 Levi Eggert. All rights reserved.
//

import Foundation

public class ObservableValue<T> {
    
    private var observers: [String: ((_ value: T) -> Void)] = Dictionary()
    
    private(set) var value: T
    
    deinit {
        observers.removeAll()
    }
    
    required init(value: T) {
        self.value = value
    }
    
    public func accept(value: T) {
        self.value = value
        notifyAllObservers()
    }
    
    public func setValue(value: T) {
        self.value = value
    }
    
    public func addObserver(_ observer: NSObject, onObserve: @escaping ((_ value: T) -> Void)) {
        observers[observer.description] = onObserve
        onObserve(value)
    }
    
    public func removeObserver(_ observer: NSObject) {
        observers[observer.description] = nil
    }
    
    private func notifyAllObservers() {
        for (_, onObserve) in observers {
            onObserve(value)
        }
    }
}
