
StreamSDK PlayKit2Go Module
=====================
The PlayKit2Go SDK allows Downloading and playback of videos in PlayKit

It depends on the PlayKit module.

Quick Start Guide
======

Cocoapods implementation
=====

Currently, the only supported way of installing the StreamAMG SDK is via Cocoapods.

The Core module is automatically installed as a pod dependency for all pods that support it

If Cocoapods is not installed on your Mac, follow the instructions [here](https://guides.cocoapods.org/using/getting-started.html)

If Cocoapods is not initialted for your project, open a terminal window, navigate to the root directory of your project and enter the following command:

```
pod init
```

In the Podfile file that has been created, add the following line after the '# Pods for (your project) line:

```
pod 'StreamAMGSDK/PlayKit2Go'
```

Now, again from the rood directory of your project, in a terminal, enter the following command:

```
pod install (or... pod update to also refresh any pods you already have)
```

The pod will be installed and available to use when your project is opened using the newly created (projectname).xcworkspace file, this should always be used instead of the xcodeproj file in a pods project.

Please use the same version for all modules to prevent dependency errors.

API Overview
============

##Accesing the SDK

To access the SDK, you should import it in any swift file that requires it:

```
import StreamAMGSDK
```

##Setting up PlayKit2Go



Change Log:
===========

All notable changes to this project will be documented in this section.

### 0.10 - PlayKit2Go Module added to SDK

### 0.1 -> 0.9 - No Purchases Module
