//
//  Created by Levi Eggert.
//  Copyright © 2020 Levi Eggert. All rights reserved.
//

import Foundation

public class SignalValue<T> {
    
    public typealias Handler = ((_ value: T) -> Void)
    
    private var observers: [String: Handler] = Dictionary()
        
    required init() {

    }
    
    deinit {
        observers.removeAll()
    }
    
    public func accept(value: T) {
        notifyAllObservers(value: value)
    }
    
    public func addObserver(_ observer: NSObject, onObserve: @escaping Handler) {
        observers[observer.description] = onObserve
    }
    
    public func removeObserver(_ observer: NSObject) {
        observers[observer.description] = nil
    }
    
    private func notifyAllObservers(value: T) {
        for (_, onObserve) in observers {
            onObserve(value)
        }
    }
}
