# Method Spies
Method Spies (intelligent breakpoints) for [Dolphin Smalltalk 7.1](https://github.com/dolphinsmalltalk/Dolphin)

## Getting Started
* Install [Dolphin Smalltalk 7.1](https://github.com/dolphinsmalltalk/Dolphin)

### Automated Installation
* To download and install, evaluate the following code snippet:    
`SourceManager default fileItIn: (File readAllText: (URLMonLibrary default urlDownloadToCacheFile: 'https://raw.githubusercontent.com/rko281/MethodSpies/master/install.st'))`

### Manual Installation
* This repository should be cloned/downloaded to your image directory
* Install Method Spies package

### Using Method Spies
* In method source editor use F9 to toggle a simple breakpoint or use the Method Spies context menu item to set/edit more advanced breakpoints (one-time breakpoint, conditional breakpoint etc.)
