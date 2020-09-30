//
//  Created by Levi Eggert.
//  Copyright © 2020 Levi Eggert. All rights reserved.
//

import Foundation

public protocol KeyboardObserverType {
    
    var keyboardStateDidChangeSignal: SignalValue<KeyboardStateChange> { get }
    var keyboardHeightDidChangeSignal: SignalValue<Double> { get }
    var keyboardState: KeyboardState { get }
    var keyboardHeight: Double { get }
    var keyboardAnimationDuration: Double { get }
    var keyboardIsUp: Bool { get }
    var isObservingKeyboardChanges: Bool { get }
    
    func startObservingKeyboardChanges()
    func stopObservingKeyboardChanges()
}
