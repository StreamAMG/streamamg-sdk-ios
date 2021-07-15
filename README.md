
StreamAMGSDK
=========
The StreamAMGSDK provides simple and efficient access to StreamAMG's APIs and services

There are currently four modules available, each of which perform a particular task, or set of tasks, within the SDK, they are:

Core:
  The Core module provides networking, logging and batch processing functionality to other modules. It is a mandatory requirement of StreamSDK CloudMatrix, StreamPlay and Authentication that Core is included in your project
  [Full details](CoreReadme.md)

CloudMatrix:
  CloudMatrix provides a historical reference of video, audio and other media types for specific events.
  [Full details](CloudMatrixReadme.md)

StreamPlay:
  StreamPlay contains information regarding upcoming events
  [Full details](StreamPlayReadme.md)

 Authentication:
   Authentication enables use of the StreamAMG Auth API
   [Full details](AuthReadme.md)

PlayKit:
   PlayKit provides video playback for Stream AMG clients
   [Full details](PlayKitReadme.md)

Requirements
----------------

- iOS 11.3+
- Xcode 12.0+

Installation
------------

Currently, the only supported way of installing the StreamAMG SDK is via Cocoapods.

The Core module is automatically installed as a pod dependency for all pods that require it, but if you do, for any reason, require the Core module only, it can be installed via Cocoapods

If Cocoapods is not installed on your Mac, follow the instructions [here](https://guides.cocoapods.org/using/getting-started.html)

To add the SDK to you project, include the required modules in your Podfile

```
pod 'StreamAMGSDK/Core'
pod 'StreamAMGSDK/CloudMatrix'
pod 'StreamAMGSDK/StreamPlay'
pod 'StreamAMGSDK/Authentication'
pod 'StreamAMGSDK/PlayKit'
```

Please use the same version for all modules to prevent dependency errors.

Accessing the SDK
----------------------

To use any of the SDK modules, import the pods into your Swift files:

```
import StreamAMGSDK
```

More Information
--------------------

More information about the individual modules can be found at their respective pages:

- [Core](CoreReadme.md)

- [CloudMatrix](CloudMatrixReadme.md)

- [StreamPlay](StreamPlayReadme.md)

- [Authentication](AuthReadme.md)

- [PlayKit](PlayKitReadme.md)


Change Log:
---------------

All notable changes to this project will be documented in this section.

### 0.3 - PlayKit State listener changes

### 0.2 - PlayKit UI updates

### 0.1 - Initial build
