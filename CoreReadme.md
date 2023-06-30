
StreamSDK Core Module
=====================
StreamSDK-Core is the only mandatory component in the StreamSDK toolkit. It a requirement for any of the other StreamSDK modules to have StreamSDK-Core implemented before they will function.

Core provides the networking and logging components of the SDK as well as Error reporting and common model and constants components.

The version of Core implemented in a project should always be the same as the component modules it is supporting.

Quick Start Guide
======

Cocoapods implementation
=====

Currently, the only supported way of installing the StreamAMG SDK is via Cocoapods.

The Core module is automatically installed as a pod dependency for all pods that support it, but if you do, for any reason, require the Core module only, it can be installed via Cocoapods

If Cocoapods is not installed on your Mac, follow the instructions [here](https://guides.cocoapods.org/using/getting-started.html)

If Cocoapods is not initialted for your project, open a terminal window, navigate to the root directory of your project and enter the following command:

```
pod init
```

In the Podfile file that has been created, add the following line after the '# Pods for (your project) line:

```
pod 'StreamAMGSDK/Core'
```

Now, again from the root directory of your project, in a terminal, enter the following command:

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

##Initialisation

To set the SDK to point to any staging URLs, you must initialise the StreamAMGSDK object

```
StreamAMGSDK.initialise(env: .DEVELOPMENT)
```

The SDK will automatically point to production URLs in a production build of the app.


##StreamSDK Internal Logging

Core provides internal logging of all calls and model construction that occurs when modules are used. Logging is disabled by default, but can be enabled either fully, or at a component level, by a call to StreamAMGSDK

To enable full logging:

```
StreamAMGSDK.enableLogging()
```
Logging of the following components can be enabled or disabled:

Network – Details of network calls to servers, including URLs called

Lists – Lists of items parsed into modules

BoolValues – (Unused) Logging of Boolean values and descriptors

Standard – Any other feedback, eg: initialisation

These can be activated / deactivated by a call to StreamAMGSDK:

The following calls will enable only Network and Standard logs (Called instead of enableLogging())

```
StreamAMGSDK.enableLogging(components: .BOOLVALUES, .LISTS)
```
You can, similarly, enable all logging and disable, for example only ModelLogs:


```
StreamAMGSDK.enableLogging()
StreamAMGSDK.disable(components: .BOOLVALUES)
```

##API Error Model
The Core SDK contains a standard error response model that is returned if an unsuccessful request is returned. If a callback error model is not null, it can be assumed the API call did not succeed:

The model is very simple. It contains the HTTP code returned and an array of String values that may have been passed to the SDK when the error occurred.

These details can be retrieved from the error model using the following calls:

Http code
error.getErrorCode()

Any messages – returned as an array of Strings
error.getAllMessages()

Any messages – returned as a single String containing all errors
error.getMessages()

##Batch processing

In a normal call to the server, you will likely want the response to be immediately delivered back to the callback so the app can respond accordingly. There may be occasions, however, where it would be preferable for multiple jobs to complete before processing.

In these situations, the StreamSDKBatchJob service can collate any number of jobs, from either a single module or a mixture of any modules, make a request from the API and hold the responses until all jobs have been completed.

Once all jobs are complete, the service will then fire all callbacks.

```
let queue = StreamSDKBatchJob()
        queue.add(request: CloudMatrixJob(request: cloudMatrixSearch, completion: cmCompletion))
        queue.add(request: StreamPlayJob(request: streamPlayFeed, completion: spCompletion))
        ....
        queue.fireBatch()
```

The batch job can be fired as many times as required once created, but will not allow a restart until any running batch has completed


Change Log:
===========

All notable changes to this project will be documented [here](Changelog.md)
