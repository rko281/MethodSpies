# MethodSpies
Method Spies (intelligent breakpoints) for [Dolphin Smalltalk 7.1](https://github.com/dolphinsmalltalk/Dolphin)

## Getting Started
* Install [Dolphin Smalltalk 7.1](https://github.com/dolphinsmalltalk/Dolphin)

### Automated Installation
* Download and install [GitHub Package Manager](https://github.com/rko281/GitHub)
* Evaluate:
  `GitHubPackageManager install: 'rko281/MethodSpies'`

### Manual Installation
* This repository should be cloned/downloaded to your image directory
* Install Method Spies package

### Using Method Spies
* In method source editor use F9 to toggle a simple breakpoint or use the Method Spies context menu item to set/edit more advanced breakpoints (one-time breakpoint, conditional breakpoint etc.)
* Use new "Step into Block" Debugger toolbar button to quickly step into a block's code without needing to step into the internals of the evaluation method (do:, collect: etc.)
