KeyboardAssistant
==============

Version 1.0.0

Keyboard Assistant faciliates in the repositioning of views when the device Keyboard is present.  It does this by observing keyboard notifications (willShow, didShow, willHide, didHide) and by responding to UITextField and UITextView objects when they become active and resign. 

- [Requirements](#requirements)
- [Cocoapods Installation](#cocoapods)
- [Documentation](#documentation)
- [How to use](#how-to-use)

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

* KeyboardObserver, as the name of this class states, has the sole responsibility of observing the device Keyboard.  It will register keyboard notifications (willShow, didShow, willHide, didHide, didChangeFrame) and retrieve the height of the keyboard.  Its job is to tell the observee (KeyboardAssistant) about keyboard state changes and height changes. 

* InputNavigator manages a sequence of input and is responsible for creating and handling the navigation between these inputs.  On iOS, input can be obtained from user's by using UITextField and UITextView objects.  This class supports both UITextField and UITextView.  To handle navigation between these inputs, Input Navigator can be configured to use the keyboard return key, it can also use a custom accessory view that conforms to InputNavigatorAccessoryController, or you can create your own custom input accessory view of type UIView and directly call InputNavigator's navigation methods.

- KeyboardAssistant is the main class you will be working with.  It holds an observer (KeyboardObserver) and navigator (InputNavigator) and handles repositioning views when the keyboard height changes and when new input items are navigated to.  There are currently two different ways to instantiate and use this class.  You can read more on that in the How to use section.

### How to use

This section is broken up into the following parts.
1. How to structure your controller for keyboard positioning.
2. How to create and use the auto scrollview assistant.
3. How to create and use the manual assistant.

#### Structuring your UIViewController

For Keyboard positioning, I prefer to use the UIScrollView approach.  There are a few major reasons for this.  
1. It's a lot more user friendly because it allows user's to scroll through input while the keyboard is open.  
2. It's much easier to manage than say a UITableView.  UITableView's are great, but when collecting input from user's they can become a pain to manage.  This is because as you scroll through a UITableView, cell's are getting recycled.  Extra management is required to collect input from UITextFields as well as navigating to previous and next textfield input items.  
3. I end up having to use a UIScrollView on most my view controllers anyways to handle shorter device sizes.

Here is how you will need to structure your controller view hier-archy.  UIView [root / UIViewController.view]  >  UIScrollView [scrollView]  >  UIView [contentView].

UIScrollView should set all edge constraints to the UIView [root / UIViewController.view].
UIView [contentView] should set all edge constraints to the UIScrollView and also set equal widths to UIScrollView.

That's it.  Then all your custom UI goes inside the UIVIew [contentView].  

Note:  This setup uses auto layout to determine the UIScrollView's content size.  That means, all of your subviews inside of the UIView [contentView] need to provide top and bottom constraints so the contentView's height can be satisfied.  It will also require some of your subviews height contraints to be set.  Unless ofcourse, their height is determined by their child views.  If you are unfamiliar with this concept read more about autolayout. 

The below screenshot is an example of this structure.  The constraints on the right show how to setup the UIScrollView and UIView [contentView] constraints.

![alt text](ReadMeAssets/scrollview_structure_constraints.jpg)

Lastly, make sure to connect the UIScrollView's bottom constrant to an outlet.

![alt text](ReadMeAssets/scrollview_bottom_constraint.jpg)

#### Auto ScrollView Assistant:

#### Manual Assistant:

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
