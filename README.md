KeyboardAssistant
==============

Version 1.0.0

Keyboard Assistant faciliates in the repositioning of views when the device Keyboard is present.  It does this by observing keyboard notifications (willShow, didShow, willHide, didHide) and by responding to UITextField and UITextView delegates when these objects become active and resign. 

### Requirements

- iOS 9.0+
- Xcode 10.1
- Swift 4.2

### Cocoapods

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'KeyboardAssistant', '1.0.0'
end
```

### Documentation

KeyboardAssistant is broken into 3 core classes.  KeyboardObserver, InputNavigator, and KeyboardAssistant.  KeyboardAssistant acts as a layer on top of KeyboardObserver and InputNavigator and depends on these 2 classes.  You can read more about these classes and their responsibilities below.

* KeyboardObserver, as the name of this class states, has the sole responsibility of observing the device Keyboard.  It will register keyboard notifications (willShow, didShow, willHide, didHide) and retrieve the height of the keyboard.  Its job is to tell the observee (KeyboardAssistant) about keyboard state changes and height changes. 

* InputNavigator manages a sequence of input and the navigation between these inputs.  On iOS, input can be obtained from user's by using UITextField and UITextView objects.  This class supports both UITextField and UITextView.  To handle navigation between these inputs, InputNavigator will set the input's returnKeyType (UIReturnKeyType) when editing begins on an input.  The UIReturnKeyType is determined based on the position of the input item.  If the position is at the end of the input items array, the returnKeyType is set to Done, otherwise it is set to Next. 

- KeyboardAssistant

### How to use

KeyboardAssistant is broken into 2 main configurations, auto assistant and manual assistant.  Auto assistant is the most simplest way to use KeyboardAssistant.  However, if you find yourself requiring more control over keyboard positioning, manual assistant is best for you.

Auto Assistant:

Manual Assistant:

In this example Seek will animate a view's alpha and translate the view.

```swift
let seek: Seek = Seek()

seek.view = myView
seek.duration = 0.3
seek.properties.fromAlpha = 0
seek.properties.toAlpha = 1
seek.properties.fromTransform = Seek.getTransform(x: 0, y: 0)
seek.properties.toTransform = Seek.getTransform(x: 80, y: 80)

seek.to(position: 1)
```

You can also use Seek's class methods to animate views.

```swift
Seek.view(view: myView, duration: 0.3, properties: SeekProperties(fromAlpha: 0, toAlpha: 1))

Seek.constraint(constraint: myConstraint, constraintLayoutView: layoutView, duration: 0.3, properties: SeekProperties(fromConstraintConstant: 0, toConstraintConstant: 50))
```

Use the SeekProperties class to define your from values and to values for a Seek animation.

Use the Seek class to animate your UIView's and constraints.  Seek uses UIView.animation to run the animations.
