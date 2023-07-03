
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

##Setting up PlayKit2Go

The PlayKit2Go SDK should be accessed via it's singleton instance

```
let playKit2Go = PlayKit2Go.instance
```

PlayKit2Go does not require an instance of PlayKit to be active (except for during playback), and can be set up at any point in the app's lifecycle

PlayKit2Go manages an internal database, which app developers do not need to access at all. To access this database, however, PlayKit2Go must run a setup function before any attempt is made to use it further.

``` Swift
    playKit2Go.setup()
```

This setup function not only allows access for PlayKit2Go to the database, but also restarts any downloads that are not complete or have not yet started

##Background downloads
PlayKit2Go can download media when the app is in the backgroung.

To achieve this, you should add the Background capability 'Background Fetch' in the 'Signing & Capabilities' tab in the app target.

You will also need to tell the app to process during backgrounding by adding the following to your AppDelegate

``` Swift
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        playKit2Go.handleEventsForBackgroundURLSession(identifier: identifier, completionHandler: completionHandler)
    }
```

##The PlayKit2GoDelegate

To react to any updates or errors from PlayKit2Go, a listener is provided:

``` Swift
interface PlayKit2GoDelegate {
    func downloadDidError(item: PlayKitDownloadItem)
    func downloadDidUpdate(item: PlayKitDownloadItem)
    func downloadDidComplete(item: PlayKitDownloadItem)
    func downloadDidChangeStatus(item: PlayKitDownloadItem)
}
```

This listener is set using the following method:

``` Swift
    playKit2Go.setDelegate(delegate) //Where 'delegate' is a class that conforms to PlayKit2GoDelegate
```

The PlayKitDownloads model
=========

PlayKit2Go keeps track of the status of all requestd downloads on the device and provides a sorted model of them that is available to the app developers on request

The PlayKitDownloads model keeps Arrays of all available states of downloads is this structure:

``` Swift
    public var completed: [PlayKitDownloadItem] = []
    public var new: [PlayKitDownloadItem] = []
    public var paused: [PlayKitDownloadItem] = []
    public var downloading: [PlayKitDownloadItem] = []
    public var failed: [PlayKitDownloadItem] = []
    public var metadataLoaded: [PlayKitDownloadItem] = []
    public var removed: [PlayKitDownloadItem] = []
```

The PlayKitDownloadItem model is a summary of everything that PlayKit2Go stores in it's database and gives an exact picture of a single download at a specific point in time:

``` Swift
    var entryID: String = "",
    var completedFraction: Float = 0.0f, // As a Float from 0 (not started) to 1 (completed)
    var totalSize: Int64 = 0, // Total estimated size of file in bytes
    var currentDownloadedSize: Int64 = 0, // Current size of download in bytes
    var available: Boolean = false,
    var error: PlayKit2GoError? = null
```

The PlayKit2GoError enum returns only if an error is encountered during download:

``` Swift
public enum PlayKit2GoError {
    case Already_Queued_Or_Completed, Download_Error, Unknown_Error, Download_Does_Not_Exist, Item_Not_Found, Internal_Error
}
```

Checking the status of downloading media
=======================

To obtain the latest version of the PlayKitDownloads model, the followin function is provided:

``` Swift
    playKit2Go.fetchAllStoredItems()
```

This will contain all current information for all downloaded and requested media

Downloading media
=======================

To download media, you must pass all relevent information to PlayKit2Go:

``` Swift
    public func download(serverUrl: String, partnerID: Int, entryID: String, ks: String? = nil)
```

This will start the download process for the media, and will report back to the listener for each individual download, allowing the developer to keep the UI up to date.


Local media playback
=======================

If the item is available for playback (PlayKitDownloadItem.available == true) then the media can be played through PlayKit by simply sending it's entryID:

``` Swift
    playKit.loadPlayKit2GoMedia(entryID: ENTRY_ID) // where playKit is a valid instance of the PlayKit module and ENTRY_ID is the ID of some downloaded media
```

Removing media
=======================

To remove downloaded media, you should call the following function:

``` Swift
     public func remove(entryID: String)
```

This will immediately remove the media from local storage and also from the database.

Media can be 'removed' at any point in it's download lifecycle, and should be removed before attempting to redownload.

Change Log:
===========

All notable changes to this project will be documented [here](Changelog.md)
