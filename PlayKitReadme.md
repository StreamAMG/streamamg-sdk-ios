#  StreamSDK PlayKit Module

The AMG PlayKit library is a simple to use wrapper around the Kaltura PlayKit suite. It provides a single UIView (AMGPlayKit) with which to play and interact with standard AMG provided media streams, whilst automatically taking care of media analytics, Google IMA (media advertising) and basic player UI.

## Installing AMG PlayKit

The library can be installed via Cocoapods, by simply adding the following lines to your PodFile:

```
pod 'StreamAMGSDK/PlayKit'
```

## Getting Started

Once the library is installed, you can add AMG PlayKit to your project either programatically, or via Storyboards.

The class a developer would interact with is simply called 'AMGPlayKit', this single class provides all standard functions of the PlayKit and will be used for the vast majority of interactions with the PlayKit

### Programatic use

To instantiate an instance of AMGPlaykit, the following initialiser should be called:

``` Swift
public init(frame: CGRect, partnerID: Int, analytics: AMGAnalyticsConfig? = nil)
```
for example, to create a 16:9 video player at :

``` Swift
let width = self.view.frame.size.width
let height = width * 0.5625
let analyticsConfig = AMGAnalyticsConfig(youboraAccountCode: "youbora_account_code") // Optional
let playKit = AMGPlayKit(frame: CGRect(x: 0, y: 0, width: width, height: height), partnerID: 1111111, analytics: analyticsConfig)
```
You can also initialise the PlayKit without a PartnerID
``` Swift
public init(frame: CGRect, analytics: AMGAnalyticsConfig? = nil)
```
But you will be required to send the PartnerID separately to play media.

### StoryBoard use

To instantiate via Storyboard, you should first drag a new UIView onto your Storyboard, then change it's 'custom class' to 'AMGPlayKit'

Once this is done, you can position the PlayKit on your Storyboard as you would any other element.

You must link your PlayKit to your View Controller as normal.

The following setup code should be carried out in the 'viewDidAppear' function:

Create the player:

``` Swift
amgPlaykit?.createPlayer(analytics: AMGAnalyticsConfig? = nil)
```

(Optional) Add the partnerID - see 'Manually updating the PartnerID'

### Removing the player

When your ViewController is destroyed, you should remove the player to stop all callbacks and listeners cleanly.

``` Swift
override func viewDidDisappear(_ animated: Bool) {
    super .viewDidDisappear(animated)
    amgPlayKit?.removePlayer()
}
```

### Adding an analytics service

Currently Playkit supports 2 anayltics services, StreamAMG's own Media Player analyics service, and Youbora analytics.
To use either service, you should instantiate the player with a configuration model:

``` Swift
init(youboraAccountCode: String)
```

or 

``` Swift
init(amgAnalyticsPartnerID: Int)
```

If you do not pass an analytics configuration during initialisation, no analytics service will be used

Youbora analytics can handle up to 20 extra static parameters being passed to it. To do this, you should use the YouboraService builder class:

``` Swift
        let analyticsConfig = AMGAnalyticsConfig.YouboraService()
            .accountCode("streamamgdev") // REQUIRED
            .userName("A USER CODE") // Should be non identifying
            .parameter(1, value: "Static Parameter Value 1")
            .parameter(2, value: "Static Parameter Value 2")
            .parameter(3, value: "Static Parameter Value 3") // through to 20
            .build()
        amgPlayKit = AMGPlayKit(frame: playKitView.bounds, analytics: analyticsConfig)
```

If you do not pass an account code in this instance, the configuration file will not work

### Manually updating the PartnerID

PartnerID can be added or changed programatically with the function
```
public func addPartnerID(partnerId: Int)
```
This is particularly important when instantiating via StoryBoard.

It should be noted that you cam also send a new PartnerID with any new media sent.

``` Swift
amgPlaykit?.addPartnerID(partnerId: 11111111)
```

## Standard Media controls

A set of UI Controls are provided as standard for the Play Kit, but these are not enabled by default.

To allow the basic configuration of the controls to be used (overlayed on the player itself), simple add the following line to your Play Kit set up code:

``` Swift
playKit.addStandardControl()
```

This adds a UI that appears when the user touches the Play Kit window, and has the following characteristics:

- Scrub bar is positioned at the bottom of the player
- The play state is NOT toggled when the user reveals the controls
- The controls disappear after 5 seconds of no interaction
- Skip forward and backward buttons skip 5 seconds

You can control some of these defaults programatically:

Set the skip forward time:
``` Swift
playKit.skipForwardDuration(_ duration: TimeInterval) // in seconds (eg, 5.25)
```

``` Swift
playKit.skipForwardTime(_ duration: Int) // in milliseconds (eg, 5250)
```

Set the skip backward time:
``` Swift
playKit.skipBackwardDuration(_ duration: TimeInterval) // in seconds (eg, 5.25)
```

``` Swift
playKit.skipBackwardTime(_ duration: Int) // in milliseconds (eg, 5250)
```

Set the skip forward and backward time:
``` Swift
playKit.skipDuration(_ duration: TimeInterval) // in seconds (eg, 5.25)
```

``` Swift
playKit.skipTime(_ duration: Int) // in milliseconds (eg, 5250)
```


## Media controls config builder
It is also possible to configure these settings by using the AMGControlBuilder class.

``` Swift
let controls = AMGControlBuilder()
    .setHideDelay(2500) // sets the delay of inactivity to 2.5 seconds (2500 Milliseconds) before hiding the controls
    .setTrackTimeShowing(false) // Hides the start and end times
    .build()

    playKit.addStandardControl(config: controls)
```

The following options are available with the builder:

Set the delay, in milliseconds, of the inactivity timer before hiding the controls
``` Swift
.setHideDelay(_ time: Int)
```

Toggle the visibility of the current track time
``` Swift
.setTrackTimeShowing(_ isOn: Bool)
```

Specify the image to use for the play button
``` Swift
.playImage(_ image: String)
```

Specify the image to use for the pause button
``` Swift
.pauseImage(_ image: String)
```

Specify the image to use for the fullscreen button
``` Swift
.fullScreenImage(_ image: String)
```

Hide the 'fullscreen' button when the player is not in full screen
``` Swift
.hideFullScreenButton()
```

Hide the 'minimise' button when the player is in full screen
``` Swift
.hideMinimiseButton()
```

Specify the image to use for the skip forwards button
``` Swift
.skipForwardImage(_ image: String)
```

Specify the image to use for the skip backward button
``` Swift
.skipBackwardImage(_ image: String)
```

Set the time, in milliseconds, of skip forward / backward controls
``` Swift
.setSkipTime(_ time: Int)
```

Set the time, in milliseconds, of skip forward control
``` Swift
.setSkipForwardTime(_ time: Int)
```

Set the time, in milliseconds, of skip backward control
``` Swift
.setSkipBackwardTime(_ time: Int)
```

Set the colour of the scrub bar 'tracked' time to a hex formatted RGB colour (eg "#AA00D3")
``` Swift
.scrubBarColour(colour: String)
```

Set the colour of the live scrub bar 'tracked' time to a hex formatted RGB colour (eg "#AA00D3")
``` Swift
.scrubBarLiveColour(colour: String)
```

Set the colour of the VOD scrub bar 'tracked' time to a hex formatted RGB colour (eg "#AA00D3")
``` Swift
.scrubBarVODColour(colour: String)
```

## Media overlays

AMG Play Kit supports the overlaying of an 'is live' badge and a logo as overlays to any media playing.

To specify the badges, use the following functions:
From a resource file
``` Swift
playKit.setIsLiveImage(named: "customislive", atWidth: 100)
```

and

``` Swift
playKit.setLogoImage(named: "customlogo", atWidth: 100)
```
'atWidth' is an optional parameter, and defaults to 70 pixels - height is calculated automatically

From a URL
``` Swift
playKit.setIsLiveImage(url: (valid URL of the image), atWidth: 100)
```
and

``` Swift
playKit.setLogoImage(url: (valid URL of the image), atWidth: 100)
```
'atWidth' is an optional parameter, and defaults to 70 pixels - height is calculated automatically


To show and hide these overlays, use these functions:

``` Swift
playKit.setiSliveImageShowing(true) // playKit.setiSliveImageShowing(false)
```

and

``` Swift
playKit.setlogoImageShowing(true) // playKit.setlogoImageShowing(false)
```

## Custom Media Controls

You can also provide your own media controls either as an overlay on the player, or as a separate component.

An example class is provided here (all components are instantiated in a xib file, but could also be added programmatically):

``` Swift
import UIKit
import AMGPlayKit

class ControlsView: UIView {

    var player: AMGPlayerDelegate? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit(){
        fromNib()
    }

    enum PlaybackState {
        case idle, playing, paused, ended
    }

    var periodicObserverUUID: UUID?

    var state: PlaybackState = .idle {
        didSet {
            switch state {
            case .idle:
                playPauseButton.setTitle("Play", for: .normal)
            case .paused:
                playPauseButton.setTitle("Play", for: .normal)
            case .playing:
                playPauseButton.setTitle("Pause", for: .normal)
            case .ended:
                playPauseButton.setTitle("Replay", for: .normal)
            }
        }
    }

    func setPlay() {
        state = .playing
    }

    func setPause(){
        state = .paused
    }

    func setSlider(position: TimeInterval) {
        slider.value = Float(position)
    }

    func setDuration(position: TimeInterval) {
        slider.maximumValue = Float(position)
    }

    @IBOutlet weak var playPauseButton: UIButton!
    @IBAction func playPauseButtonTapped(_ sender: Any) {
        switch state {
        case .playing:
            player?.pause()
        case .idle:
            player?.play()
        case .paused:
            player?.play()
        case .ended:
            player?.scrub(position: 0)
            player?.play()
        }
    }

    @IBOutlet weak var slider: UISlider!

    @IBAction func sliderChanged(_ sender: Any) {
        if state == .ended && slider.value < slider.maximumValue {
            state = .paused
        }
        player?.scrub(position: TimeInterval(slider.value))//currentTime = TimeInterval(slider.value)
    }
}
```

You should accept a delegate, of type 'AMGPlayerDelegate' this should be the player object itself:

``` Swift
public protocol AMGPlayerDelegate {
    func play()
    func pause()
    func scrub(position: TimeInterval)
    func setControlDelegate(_ delegate: AMGControlDelegate)
    func cancelTimer()
    func startControlVisibilityTimer()
}
```

play, pause and scrub(position:) control the state of the player

skipForward / skipBackward moves the playhead forward or backward the specified number of milliseconds (default 5 seconds)

setControlDelegate(_ delegate:) will change the delegate of the control reciever to whichever class you specify (must conform to AMGControlDelegate).

cancelTimer and startControlVisibilityTimer are used when overlaying the player with your controls and determine the visibility of the controls

To use this control class, you should add it to your Play Kit set up code:

``` Swift
    let controlView = ControlsView(frame: _Your frame rect_)
    controlView.player = playKit
    playKit.setControlDelegate(self)
```

## Play Kit orientation

The AMG Play Kit can be displayed in portrait mode or full screen landscape mode.

The app itself must handle the change in view (either via Storyboard or programatically), as well as instructing the Play Kit on the desired orientation.

To infer orientation to the Play Kit, your View Controller should handle the overridable 'willAnimateRotation' on the UIViewController itself...

``` Swift
override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
    if UIDevice.current.orientation.isLandscape{
    playKit.fullScreen()
    } else if UIDevice.current.orientation.isPortrait {
    playKit.minimise()
    }
}
```

As well as (or instead of) changing via a physical orientation change, you can use the 'fullscreen' button on the Play Kit Standard Control UI - this appears, unless it is disabled, in the bottom right corner of the Play Kit view.

To disable this completely, use the '.hideFullScreenButton()' builder function when creating the Control UI configuration

A minimise button will be show in full screen mode, thiscan also be disabled using the '.hideMinimiseButton()' function.

If using a non standard Control UI, you can simply call the following functions to implement your own full screen button:

For fullscreen
``` Swift
playKit.fullScreen()
```
To minimise from full screen
``` Swift
playKit.minimise()
```

## Sending Media

The main function of PlayKit is to play and interact with media provided by Stream AMG and it's partners.

There are only 5 required elements when requesting media to be played:
* Partner ID
* Media URL
* Entry ID
* KS (where needed)
* Title (For Youbora analytics)

you can also pass a 'mediaType' element to force the player into 'live' mode if required - see below

Please note it is no longer required to pass the UIConfig parameter to PlayKit.

If you have provided the Partner ID to the PlayKit already, you do not need to pass this with each media request:

``` Swift
public func loadMedia(serverUrl: String, entryID: String, ks: String? = nil, mediaType: AMGMediaType = .VOD, title: String?)
```
for example:
``` Swift
playKit.loadMedia(serverUrl: "https://mymediaserver.com", entryId: "0_myEntryID", ks: "VALID_KS_PROVIDED_BY_STREAM_AMG", title: String?)
```

Or with a Partner ID
``` Swift
public func loadMedia(serverUrl: String, partnerID: Int, entryID: String, ks: String? = nil, mediaType: AMGMediaType = .VOD, title: String?)
```
for example:
``` Swift
playKit.loadMedia(serverUrl: "https://mymediaserver.com", partnerID: 111111111, entryId: "0_myEntryID", ks: "VALID_KS_PROVIDED_BY_STREAM_AMG", title: String?)
```

If the media does not require a KSession token, this should be left as null

### Forcing live mode

When sending media to the player, the mediaType defaults to VOD and will automatically attempt to determine if the media is live or VOD, this will affect the scrub bar colours (if they are different) and the layout of the scrub bar.

To force the player into 'live' mode, 'mediaType: .Live' should be passed to the player when sending media

``` Swift
playKit.loadMedia(serverUrl: "https://mymediaserver.com", partnerID: 111111111, entryId: "0_myEntryID", ks: "VALID_KS_PROVIDED_BY_STREAM_AMG", mediaType: .Live)
```

'AMGMediaType' is defined as:

``` Swift
public enum AMGMediaType {
    case Live, VOD, Audio, Live_Audio
}
```

Currently the player is either 'Live' or 'VOD'

### State Listener

To react to player events within your app, you can implement the AMGPlayKitListener delegate.

``` Swift
        playKit.setPlayKitListener(listener: self)

func playEventOccurred(state: AMGPlayKitState) {
    print("playEventOccurred - \(state.state)")
}

func stopEventOccurred(state: AMGPlayKitState) {
    print("stopEventOccurred - \(state.state)")
}

func loadChangeStateOccurred(state: AMGPlayKitState) {
    print("loadChangeStateOccurred - \(state.state)")
}

func durationChangeOccurred(state: AMGPlayKitState) {
    print("durationChangeOccurred - \(state.state) - \(state.duration)")
}

func errorOccurred(error: AMGPlayKitError) {
    print("errorOccurred - \(error.errorCode) - \(error.errorMessage)")
}
```

You must conform to using the above functions when creating your listener.

The following errors will be reported when you implement errorOccurred:

SOURCE_ERROR(7000) - The error occured loading data from MediaSource.
RENDERER_ERROR(7001) - The error occured in a renderer.
UNEXPECTED(7002) - If in runtime any unexpected error occurs.
SOURCE_SELECTION_FAILED(7003) - The error occured to get the source from SourceSelector.
FAILED_TO_INITIALIZE_PLAYER(7004) - The error occured when failed to initilize PlayerEngine.
DRM_ERROR(7005) - In case device does not support widevine modular or license is expired.
TRACK_SELECTION_FAILED(7006) - The error occured if track selection is not possible in TrackSelectionHelper.
LOAD_ERROR(7007) - In case, media is not loaded in any of the MediaSource.
OUT_OF_MEMORY(7008)
REMOTE_COMPONENT_ERROR(7009)
TIMEOUT(7010)

### Picture In Picture

PlayKit is able to provide PiP playback on devices that support it.

PiP is automatically enabled for your PlayKit implementation, to disable it, call the following function:

``` Swift
playKit.disablePictureInPicture()
```

If you want more control over PiP, you can also toggle PiP (within the app, for example), by calling the following function:

``` Swift
playKit.togglePictureInPicture()
```

You can also pass a delegate that conforms to AMGPictureInPictureDelegate to get callbacks when PiP is available, starts and ends:

``` Swift
public protocol AMGPictureInPictureDelegate {
    func pictureInPictureStatus(isPossible: Bool)
    func pictureInPictureWillStart()
    func pictureInPictureDidStop()
}
```

To set this delegate:

``` Swift
playKit.setPictureInPictureDelegate(self) //where 'self' conforms to 'AMGPictureInPictureDelegate'
```

You can also implement PiP in app, by accessing the required AVPlayerLayer:

``` Swift
playKit.playerLayer()
```

### Casting URL

To access the casting URL of the currently playing media use the following function:

``` Swift
playKit.castingURL(format: AMGMediaFormat = .HLS, completion: @escaping ((URL?) -> Void))
```
The completion returns a fully qualified casting URL (or nil on error)

for example:
``` Swift
playKit.castingURL(format: .HLS){ (mediaURL: URL?) in
    // Work with HLS URL here
}
```
Media format is either `.HLS` or `.MP4` - Defaults to HLS

You can also pass details of any valid media to playkit to return a valid casting URL without sending the media to the player to play:

``` Swift
playKit.castingURL(server: String, partnerID: Int, entryID: String, ks: String? = nil, format: AMGMediaFormat = .HLS, completion: @escaping ((URL?) -> Void))
```

### Serving Adverts

AMG PlayKit supports VAST URL adverts.

To serve an advert pre, during or post media, send the VAST URL to the following function

``` Swift
public func serveAdvert(adTagUrl: String)
```
for example:
``` Swift
playKit.serveAdvert("VAST_URL_FOR_REQUIRED_ADVERT")
```

### Spoiler Free

PlayKit has the ability to hide the scrub bar and timing lables, effectively making the video 'spoiler free'

To enable (or disable) spoiler free mode:

``` Swift
amgPlayKit?.setSpoilerFree(enabled: true) // true = spoiler free mode on, false = scrub bar on
```

# Change Log

All notable changes to this project will be documented in this section.

### 0.11
- Added Youbora parameters and builder methods
- Corrected issues with the standard UI
- Fixed a bug where adverts were not showing
- Fixed a bug where adverts would not allow interaction when using the standard UI
- Removed debug logging

### 0.10 - Minor changes for PlayKit2Go implementation

### 0.9
- Added Youbora analytics and the ability to choose analytics services
- Added ability to change scrub bar colours
- Automatically detect live streams
- Tidied Custom Control builder
- Small bug fixes

### 0.8.3 - Standard UI updates
- Change default visibility of start / end times to showing
- Address small offset for scrub bar when no track time showing
- Change behaviour of scrub bar to scrub to half a second before the end of the track if pulled all the way to the right

### 0.8.2 - Change CastingURL to avoid redirections
- Force casting URL to return a redirected URL if required (HLS only)
- Change call to require completion

### 0.8.1 - Casting URL update
- allowed selection of either MP4 or HLS format for the castiong URL

### 0.8 - Bug fixes and improvements
- Fixed a potential crash when exiting player
- Updated PIP to automatically run unless specifically disabled
- Improved orientation changes
- Added 'removePlayer() function to safely remove all listeners
- Fixed castingURL function
- Added Spoiler Free mode
- Updated load media to accept AMGMediaType

### 0.7 - Picture in Picture
- Added 'enablePictureInPicture' function
- Added protocol for picture in picture if required
- Expose Casting URL

### 0.6 - State listeners
- Added state listeners for PlayKit
- Removed Google ChromeCast

### 0.2 - Updated Controls UI
- Redesign for standard controls
- Added Control config for images
- Removed Slider height configuration and show curent time configuration

### 0.1 Initial build
