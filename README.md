# Viva - Augmented Reality Charts for iOS - Built with ARKit and SceneKit

<p align="center"><img src="https://raw.github.com/txaiwieser/Viva/master/screenshots/viva_banner.png"/></p>  

**Viva** is a library making it easy to create beautiful charts tailored for augmented reality. 


## Project Details

![Demo Gif](https://raw.github.com/txaiwieser/Viva/master/screenshots/viva_showcase_00.gif)
[1](https://raw.github.com/txaiwieser/Viva/master/screenshots/viva_showcase_01.png)
[2](https://raw.github.com/txaiwieser/Viva/master/screenshots/viva_showcase_02.png)
[3](https://raw.github.com/txaiwieser/Viva/master/screenshots/viva_showcase_03.png)
[4](https://raw.github.com/txaiwieser/Viva/master/screenshots/viva_showcase_04.png)

### Requirements
- Optimized for A9 and A10 processors (ARKit)
- Xcode 9.x
- Requires iOS 11 or later

ARKit is available on any iOS 11 device, but the world tracking features that enable high-quality AR experiences require a device with the A9 chip or later processor.

**IMPORTANT: Here’s the list of iPhone and iPad models compatible with ARKit in iOS 11 (with A9 Chip)**

* iPhone 6s
* iPhone 6s Plus
* iPhone SE
* iPhone 7
* iPhone 7 Plus
* iPhone 8
* iPhone 8 Plus
* iPhone X
* iPad 9.7-inch (2017)
* iPad Pro (All variants)


### Sample App
The Viva-Example App included in this projects demonstrates one way of setting up and using **Viva**. Give it a try to see what can be accomplished! 

## Getting Started

### Installation

#### Carthage

```carthage
github "txaiwieser/Viva"
github "txaiwieser/Viva" == 1.0.0
github "txaiwieser/Viva" ~> 1.0.0
```
`carthage update Viva`

#### Manual
You can always install **Viva** manually by dragging the `Viva` folder into your XCode project. When you do so, make sure to check the *"Copy items into destination group's folder"* box.

### Setup
**Viva** gives you a `ARViewController` class that should be presented and dismissed by your application. Also a `ARViewControllerDataSource` `ARViewControllerDelegate` for data input. That makes it very easy to use in your project!


##### import Viva
```swift
import Viva
```

##### Creating the ARViewController
```swift
let arViewController = ARViewController()
arViewController.delegate = self
arViewController.dataSource = self
```

##### Presenting/Dismissing (from a ViewController)
```swift
arViewController.defaultDismissButtonEnabled = true
self.present(arViewController, animated: true)
```

##### Debug Options
```swift
arViewController.showDebugVisuals = true
```

##### ARViewControllerDelegate
```swift
import Graphs

extension YourViewController: ARViewControllerDelegate {
    func willDismiss(arViewController: ARViewController) {}
}
```

##### ARViewControllerDataSource
```swift
import Graphs

extension YourViewController: ARViewControllerDataSource {
    func availableCharts(for arViewController: ARViewController) -> {}
}
```

Features
=======

**Core features:**
 - 4 different chart types
 - Scaling
 - Dragging / Panning (with touch-gesture)
 - Inspect values
 
**Chart types:**

 - **Line Chart**
![alt tag](https://raw.github.com/txaiwieser/Viva/master/screenshots/charttype_example_linechart.png)

 - **Bar Chart**
![alt tag](https://raw.github.com/txaiwieser/Viva/master/screenshots/charttype_example_barchart.png)

 - **Pie Chart**
![alt tag](https://raw.github.com/txaiwieser/Viva/master/screenshots/charttype_example_piechart.png)

 - **ScatterChart**
![alt tag](https://raw.github.com/txaiwieser/Viva/master/screenshots/charttype_example_scatterchart.png)
