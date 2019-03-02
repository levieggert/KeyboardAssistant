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

This section is broken up into the following parts.
1. How to structure your controller for keyboard positioning.
2. How to create and use the auto assistant.
3. How to create and use the manual assistant.

#### Structuring your UIViewController

For Keyboard positioning, I prefer to use the UIScrollView approach.  There are a few major reasons for this.  
1. It's a lot more user friendly because it allows user's to scroll through input while the keyboard is open.  
2. It's much easier to manage than say a UITableView.  UITableView's are great, but when collecting input from user's they can become a pain to manage.  This is because as you scroll through a UITableView, cell's are getting recycled.  Extra management is required to collect input from UITextFields as well as navigating to previous and next textfield input items.  
3. I end up having to use a UIScrollView on most my view controllers anyways to handle shorter device sizes.

Here is how you will need to structure your view hier-archy.  UIView [root / UIViewController.view]  >  UIScrollView [scrollView]  >  UIView [contentView].

UIScrollView should set all edge constraints to the UIView [root / UIViewController.view].
UIView [contentView] should set all edge constraints to the UIScrollView and also set equal widths to UIScrollView.

That's it.  Then all your custom UI goes inside the UIVIew [contentView].  

Note:  This setup uses auto layout to determine the UIScrollView's content size.  That means, all of your subviews inside of the UIView [contentView] need to provide top and bottom constraints so the contentView's height can be satisfied.  It will also require some of your subviews height contraints to be set.  Unless ofcourse, their height is determined by their child views.  If you are unfamiliar with this concept read more about autolayout. 

#### Auto Assistant:

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

You can also use Seek's class methods to animate views.

```swift
Seek.view(view: myView, duration: 0.3, properties: SeekProperties(fromAlpha: 0, toAlpha: 1))

Seek.constraint(constraint: myConstraint, constraintLayoutView: layoutView, duration: 0.3, properties: SeekProperties(fromConstraintConstant: 0, toConstraintConstant: 50))
```

Use the SeekProperties class to define your from values and to values for a Seek animation.

Use the Seek class to animate your UIView's and constraints.  Seek uses UIView.animation to run the animations.

### Known Issues

There is an issue with obtaining the correct device keyboard height when the keyboard changes.  I believe this is a bug in Apple's Framework.  I will explain below.  

Since iOS 8, the device keyboard came with a new feature called predictive text.  This is a bar placed above the keyboard that provides word suggestions as you type.  Some UITextField's will not use the predictive text bar (example, enabling secure text entry).  This is causing a problem somewhere within the depths of Apple's Framework because the change isn't getting reported to the Keyboard.  Well, it is, but it isn't. I'll give a step by step process of the bug and how it can be produced.

Let's say you setup an account registration controller with 4 UITextFields in this order (first name, last name, email, and password).  For the password, you enable secure text entry.  Also note that predictive text bar is enabled.  User taps first name textfield, keyboard will show is notified and we obtain a keyboard height of 260.  Predictive text bar is showing.  Now, we tap on the password textfield, keyboard will show is called and this time we obtain a keyboard height of 216 because the predictive text bar is not showing becuse serure text entry is enabled.  The issue is, when we tap back on a textfield that is displaying a predictive text bar, keyboard will show is called and reports a keyboard height of 216 when the last time it was reporting 260.  Now,we have an incorrect keyboard height which will cause issues when repositioning views. 

We could get around this issue if there's a way to check if predictive text bar is showing.  If this logic doesn't exist, we will have to create "fake" logic for checking.  And by fake, I mean testing all possibilities that will disable the predictive text bar.  Secure text entry is one of them.  But, what happens with new iOS releases?  We will have to update this for every release and test for every change to the device keyboard.  It add's more complexity and logic to the original implementation that we really don't want.
