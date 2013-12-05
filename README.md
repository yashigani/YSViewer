# YSViewer
YSViewer is image viewer like Tweetbot3.

![screenshot](./screenshot.png)

# Requirements
- iOS 7 or later
- ARC

# Usage
## Show image
Set `UIImage` to `YSViewer`. Call `show` method only.

``` objc
YSViewer *viewer = [YSViewer new];
viewer.image = [UIImage imageNamed:@"imageToShow"];
[viewer show];
```

## Set background effect
Tweetbot 3 set frosted glass effect to background of viewer. but, `YSViewer` doesn't include it. If you want, you can use `backgroundView` property.

``` objc
viewer.backgroundview = ... // set your original background effect.
```

## Show customized view
`YSViewer` show not only image. You can show your customized view.

``` objc
viewer.view = ... // set your customized view. e.g. viewer for animation gif
```

# Install

## CocoaPods
```
pod 'YSViewer', :git => 'https://github.com/yashigani/YSViewer.git'
```

## Manually
Drag and Drop `YSViewer` directory to your project.

# Licence
MIT Licene

Copyright (c) 2013 Taiki Fukui

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
