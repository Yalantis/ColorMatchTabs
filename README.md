# ColorMatchTabs

![Swift 2.3.x](https://img.shields.io/badge/Swift-2.3.x-orange.svg)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ColorMatchTabs.svg)](https://img.shields.io/cocoapods/v/GuillotineMenu.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Inspired by [this project on Dribbble](https://dribbble.com/shots/2702517-Review-App-Concept)

![Preview](Resources/preview.gif)

Also, read how it was done in [our blog](https://yalantis.com/blog/how-we-developed-colormatchtabs-animation-for-ios/)

## Requirements

* iOS 9.0
* Swift 3
* Xcode 8

## Installation

####[CocoaPods](https://cocoapods.org/)

```ruby
pod 'ColorMatchTabs', '~> 2.0'
```

#### [Carthage](https://github.com/Carthage/Carthage)


```
github "Yalantis/ColorMatchTabs" ~> 2.0
```

## How to use

### Complete screen

To setup and customize the component you should implement `ColorMatchTabsViewControllerDataSource` for `ColorMatchTabsViewController`. 

```swift
public protocol ColorMatchTabsDataSource: class {
    
    func numberOfItems(inController controller: ColorMatchTabsViewController) -> Int
    
    func tabsViewController(controller: ColorMatchTabsViewController, viewControllerAt index: Int) -> UIViewController
    
    func tabsViewController(controller: ColorMatchTabsViewController, titleAt index: Int) -> String
    func tabsViewController(controller: ColorMatchTabsViewController, iconAt index: Int) -> UIImage
    func tabsViewController(controller: ColorMatchTabsViewController, hightlightedIconAt index: Int) -> UIImage
    func tabsViewController(controller: ColorMatchTabsViewController, tintColorAt index: Int) -> UIColor

}
```

To customize popup view controller create a subclass of `PopoverViewController` and set it in the view controller: 

```swift
tabsViewController.popoverViewController = ExamplePopoverViewController()
```

### Customization

The component contains of:
- top tabbar
- scrollable content view
- plus button
- popover view controller
 
Menu view controller aggregates the elements described above. If you want to fully customize or rearrange the elements, just create your own view controller instead of `MenuViewController`.

## Support

Feel free to [open issuses](https://github.com/Yalantis/ColorMatchTabs/issues/new) with any suggestions, bug reports, feature requests, questions.

## Let us know!

We’d be really happy if you sent us links to your projects where you use our component. Just send an email to github@yalantis.com And do let us know if you have any questions or suggestion regarding the animation. 

P.S. We’re going to publish more awesomeness wrapped in code and a tutorial on how to make UI for iOS (Android) better than better. Stay tuned!


### License

The MIT License (MIT)

Copyright (c) 2017 Yalantis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
