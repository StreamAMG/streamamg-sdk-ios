
StreamSDK StreamPlay Module
=====================
The StreamPlay SDK provides data and information concerning video and other media available to partners (and internally) by harnessing the power of the StreamPlay API in a simple, easier to consume form.

Although not as extensive as the CloudMatrix API, StreamPlay is simpler to use and returns a consistent guaranteed response that requires little to no additional set up to use.

The following requests can be made using the StreamPlay SDK:

FEED – which returns a pre-defined data set back for immediate consumption

SEARCH – which allows filtering and searching of all available data for the partner

A single model (StreamPlayResponseModel) is returned after a successful transaction, otherwise a StreamAMGError is returned explaining any issues encountered.

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
pod 'StreamAMGSDK/StreamPlay'
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

##Setting up StreamPlay
You should instantiate StreamPlay to use it.

```
let streamPlay: StreamPlay = StreamPlay()
```

As many of these objects can be created as is required

The API will use either the production or staging URL depending on the StreamSDK Environment

##Making API Requests
A StreamPlay request can be created as either a standard object which can be updated for the request, or, as is preferred, a builder can be used.

Once a request has been made and delivered, the SDK will return a valid response model, or an error object to a callback specified. The responses and errors are discussed later in this document.

Requests are created separately from the StreamPlay object and then passed to the Core Module via the StreamPlay object.

A completion block is, technically, optional, but currently there is no other way of accessing the response.

##Sending a request to Core
All StreamPlay SDK requests are handled by the Core module. This is managed in 2 steps, the request construction and the request delivery.
```
let request = .... (StreamPlayRequestModel) – see below for details on constructing the request

streamPlay.callAPI(request: request){ (result: Result<StreamPlayResponse, StreamAMGError>) in
switch result {
case .success(let spData):
        // Process the valid spData object (StreamPlayResponse) here
case .failure(let spError):
        // Process the valid spError object (StreamAMGError) here
}
}
```

If a request is successful, a StreamPlayResponseModel will be delivered (via the completion), otherwise an error will be returned.

##Accessing Static Feeds
Using pre-defined complete URLs
If an app receives a config file with given static StreamPlay URLs (or if these URLs are known to be static and can be included as hard coded strings), then the StreamPlay SDK can handle these URLs and provide a standard response model for consumption.

To re-iterate the advantages of using the SDK for even this most simple of tasks:
-	Networking is handled
-	Errors are handled
-	A standard model is used for the response
-	Paging, if necessary, is handled

Because these feeds should already contain all necessary data in them (including the partner ID, sport and fixture IDs, etc) then only a very simple request is needed:
```
val request = StreamPlayRequest
.FeedBuilder()
.url("(Valid StreamPlay URL)")
.build()
```

Or
```
val request = StreamPlayRequest(url = "(Valid StreamPlay URL)")
```

In this instance, the builder is less of a boon to use, it’s usefulness is far more evident in most of the other requests.

##Building a feed manually
In certain instances, it may be required to manually create a feed, this, similarly, can be done either using a builder or standard object methods.
As an object:

```
let request = StreamPlayRequest(sport: [.FOOTBALL], fixtureID: “Fixture ID”, partnerID: ”Partner ID”)

```

)


Using a builder:
```
var request = StreamPlayRequest
        .FeedBuilder()
        .fixture("Fixture ID")
        .partner("Partner ID")
        .sports([.FOOTBALL, .BASKETBALL])   // For multiple sports
        .sport(.FOOTBALL)                   // For a single sport
        .fixture("Fixture ID")
        .build()
```



Extra detail
Additional details can be added to this request if required:
```
request.paginateBy = 15
```


##Using the StreamSDK-StreamPlay Search Capabilities
The search capabilities for StreamPlay vary slightly from CloudMatrix, but the range of search types is still vast.
```
val search = StreamPlayRequest
.SearchBuilder()
        .sport(.FOOTBALL)
        .partner("Partner ID")
        .isLike(target: .FIXTURE_NAME, query: "West")
        .build()
```


There is no limit to the amount of parameters that can be included, or to the types of searches that can be mixed.

Currently there is only ‘AND’ searches, but ‘OR’ is being worked on.

The build components are flexible:
```
isEqualTo(target: StreamPlayQueryField, query: String)

isEqualTo(target: StreamPlayQueryField, query: NSNumber)
```

The ‘target’ is the field in the database being referenced, the ‘query’ is the item being searched for

The following query types are available:

Exact match of word or numbers
```
.isEqualTo(target: StreamPlayQueryField, query: String)
```


Value is greater than (or equal to) the query. This can be passed as a String or Number
```
.isGreaterThan(target: StreamPlayQueryField, query: String)
.isGreaterThanOrEqualTo(target: StreamPlayQueryField, query: String)
```


Value is less than (or equal to) the query. This can be passed as a String or Number
```
.isLessThan(target: StreamPlayQueryField, query: String)
.isLessThanOrEqualTo(target: StreamPlayQueryField, query: String)
```


Fuzzy search – “foot” will match ‘right-footed’, ‘football’ and ‘foot’, etc
```
.isLike(target: StreamPlayQueryField, query: String)
```


Starting character search – “foot” will match ‘football’ and ‘foot’, but not ‘right-footed’
```
.startsWith(target: StreamPlayQueryField, query: String)
```


The following searches require no ‘query’

Boolean searches on a field
```
.isTrue(target: StreamPlayQueryField)
.isFalse(target: StreamPlayQueryField)
```


Sort order by field
```
.sortByAscending(target: StreamPlayQueryField)
.sortByDescending(target: StreamPlayQueryField)
```


Set date range of query (Date format is “YYYY-MM-DD”
```
.dateFrom(date: String)
.dateTo(date: String)
```


Set whether the Start date or End date of the fixture is used in the range query
```
.endDateEffective() (Default)
.startDateEffective()
```

##Batch processing

In a normal call to the server, you will likely want the response to be immediately delivered back to the callback so the app can respond accordingly. There may be occasions, however, where it would be preferable for multiple jobs to complete before processing.

In these situations, the StreamSDKBatchJob service can collate any number of jobs, from either a single module or a mixture of any modules, make a request from the API and hold the responses until all jobs have been completed.

Once all jobs are complete, the service will then fire all callbacks.
```
    let search1 = StreamPlayRequest
                .FeedBuilder()
                .url(staticURL1)
                .build()

    let search2 = StreamPlayRequest
                .FeedBuilder()
                .url(staticurl2)
                .build()

    let queue = StreamSDKBatchJob()
            queue.add(request: StreamPlayJob(request: search1, completion: spCompletion))
            queue.add(request: StreamPlayJob(request: search2, completion: spCompletion))
        ....
        queue.fireBatch()
```

The batch job can be fired as many times as required once created, but will not allow a restart until any running batch has completed

##The StreamPlay Response Model
Accessing retrieved data
When a successful call to the API has been returned, the sdk makes available a data model of type ‘StreamPlayResponse?’. This model contains the following information:

StreamPlayResponse root:
-	fixtures: ArrayList<FixturesModel>
-	total: Int
-	limit: Int
-	offset: Int

StreamPlayResponse FixturesModel:
Any response is guaranteed to have a FixturesModel array, although this may be empty if no results are retrieved. This model is fixed and should be extended.
-	       id: Int?
-	       type: String?
-	       partnerId: Int?
-	       featured: Boolean?
-	       name: String?
-	       description: String?
-	       startDate: String?
-	       endDate: String?
-	       createdAt: String?
-	       updatedAt: String?
-	       videoDuration: Int?
-	       externalIds: ExternalIDModel?
o	optaFixtureId: Int?
o	paFixtureId: Int?
o	sportsradarFixtureId: Int?      
-	       season: FixtureDetailModel? – See ‘FixtureDetailModel’ below
-	       competition: FixtureDetailModel?
-	       homeTeam: FixtureDetailModel?
-	       awayTeam: FixtureDetailModel?
-	       stadium: FixtureDetailModel?
-	       mediaData: ArrayList<ScheduleMediaDataModel> = ArrayList()
o	   mediaType: String?
o	   entryId: String?
o	   isLiveUrl: String?
o	   isLiveTime: Long?
o	   thumbnailUrl: String?
o	   drm: Boolean?
-	       thumbnail: String?,
-	       thumbnailFlavors: FixtureThumbnailFlavorsModel
o	      logo250: String?
o	      logo640: String?
o	      logo1024: String?
o	      logo1920: String?,
o	      source: String?

StreamPlayResponse FixtureDetailModel:
-	      id: Int?
-	      name: String?
-	      logo: String?
-	      logoFlavours: FixtureDetailLogoFlavorsModel?
o	      logo50: String?
o	      logo100: String?
o	      logo200: String?
o	      logo300: String?,
o	      source: String?


##Callbacks in StreamPlay
To access the data returned by the SDK, a callback is required for each request. This callback can either be added in line to an individual request, or a defined callback can be added.

The callback is required in the form:
```
((Result<StreamPlayResponse, StreamAMGError>) -> Void)?
```


It can be added inline:

```
streamPlay.callAPI(request: request){ (result: Result<StreamPlayResponse, StreamAMGError>) in
switch result {
case .success(let spData):
        // Process the valid spData object (StreamPlayResponse) here
case .failure(let spError):
        // Process the valid spError object (StreamAMGError) here
}
}
```


Or as a reusable parameter:
```
let spCompletion: ((Result<StreamPlayResponse, StreamAMGError>) -> Void) = { (result: Result<StreamPlayResponse, StreamAMGError>) in
switch result {
case .success(let spData):
        // Process the valid spData object (StreamPlayResponse) here
case .failure(let spError):
        // Process the valid spError object (StreamAMGError) here
}
}

streamPlay.callAPI(request: request, completion: spCompletion)
```

##IsLive checking
The StreamPlay module can also be used to check any 'isLive' URLs (URLs provided by the StreamPlay API used to determine if an event is currently live streaming)

The service is automatic, simple to set up and use and can handle multiple URLs at any one time.

To add a URL to the isLive checking service, you make a call with either a delegate that conforms to StreamPlayIsLiveDelegate or with a completion block that conforms to ((Result<StreamPlayIsLiveModel, StreamPlayIsLiveErrorModel>) -> Void)
Delegate:
```
StreamPlayIsLiveService.addIsLiveCall(id: "(Specific ID number)", url: "(Valid is live URL)", delegate: self) // For use with the StreamPlayIsLiveDelegate pattern
```
or Completion
```
StreamPlayIsLiveService.addIsLiveCall(id: "(Specific ID number)", url: "(Valid is live URL)"){ (result: Result<StreamPlayIsLiveModel, StreamPlayIsLiveErrorModel>) in
switch result {
case .success(let spIsLiveData):
        // Process the valid spIsLiveData object (StreamPlayIsLiveModel) here
case .failure(let spIsLiveError):
        // Process the valid spError object (StreamPlayIsLiveErrorModel) here
}
}
```

Both methods can also be used without an ID, this will return a String ID to help handle any returning calls

The service will, by default, reject any object that uses the same ID or URL as a previous isLive call, although you can choose to accept duplicate URLs on a per-call basis by adding 'allowDuplicates: true' to the call:

```
StreamPlayIsLiveService.addIsLiveCall(id: "(Specific ID number)", url: "(Valid is live URL)", delegate: self, allowDuplicates: true)
```

By default, the service will continue calling the isLive URLs and either running the delegate methods or the completion until the service is stopped. To send an isLive call only once, add 'shouldRepeat: false' to the call:
```
StreamPlayIsLiveService.addIsLiveCall(id: "(Specific ID number)", url: "(Valid is live URL)", delegate: self, shouldRepeat: false)
```

##StreamPlayIsLiveService

The service will automatically start processing as soon as a URL is passed to it and will only stop if instructed to or if there are no urls left to check

To stop (or pause) the service:
```
StreamPlayIsLiveService.pauseService()
```

To resume a paused service:
```
StreamPlayIsLiveService.resumeService()
```

The service checks if a URL needs to be clled every 30 seconds (Each individual URL will have it's own actual timing set by the API on a valid response)

To change the duration between checks:
```
StreamPlayIsLiveService.setServicePulse(pulse: TimeInterval)
```

You can also remove a check if required:
```
StreamPlayIsLiveService.removeCheck(id: String)
```
If the last check is removed, the service will stop automatically

##StreamPlayIsLiveDelegate

To conform to the StreamPlayIsLiveDelegate, you must include the following methods in the delegate class:

```
func isLiveResponseRecieved(model: StreamPlayIsLiveModel)

func isLiveErrorRecieved(model: StreamPlayIsLiveErrorModel)
```

##StreamPlayIsLiveService models

Both the StreamPlayIsLiveModel and the StreamPlayIsLiveErrorModel contain the id either passed to or generated by the Service at set up
```
model.liveStreamID
```

The StreamPlayIsLiveModel contains a boolean value
```
model.isLive
```
which contains the state of the live stream

The StreamPlayIsLiveErrorModel contains a failure code and any server generated messages:
```
model.getErrorCode() -> Int
model.getErrorMessages() -> [String]
model.getErrorMessagesAsString() -> String
```

##Paging in StreamSDK-StreamPlay
The StreamPlay module handles paging for any responses received. By default the API will return 20 records by page, but this can be configured in any request by either passing a Builder option or during initialisation

Using Builder:
```
.paginateBy(paginateBy: Int)
```


Using standard initialisation
```
let request = StreamPlayRequest(paginateBy = (items per page as Int))
```


Paging data can be called via the response model to enable / disable paging buttons / pull to refresh, etc.
The current request can be paginated using the following methods:
```
streamPlay.loadPreviousPage()
```
```
streamPlay.loadNextPage()
```

Currently available data
The accepted valid fields for StreamPlay are as follows:
Available sports:
enum StreamPlaySport {
FOOTBALL
BASKETBALL
RUGBY_LEAGUE
SNOOKER
POOL
DARTS
BOXING
GYMNASTICS
FISHING
NETBALL
TEN_PIN_BOWLING
PING_PONG
GOLF
}

Available query fields:
enum StreamPlayQueryField{
ID
MEDIA_TYPE
MEDIA_ENTRYID
MEDIA_DRM
FIXTURE_TYPE
FIXTURE_NAME
FIXTURE_DESCRIPTION
FIXTURE_OPTA_ID
FIXTURE_SPORTS_RADAR_ID
FIXTURE_PA_ID
SEASON_ID
SEASON_NAME
COMPETITION_ID
COMPETITION_NAME
HOME_TEAM_ID
HOME_TEAM_NAME
AWAY_TEAM_ID
AWAY_TEAM_NAME
STADIUM_ID
STADIUM_NAME
LOCATION_ID
LOCATION_NAME
EVENT_TYPE
}



##Jazzy documentation
To run Jazzy documentation on this module, ensure Jazzy is installed, details [here](https://github.com/realm/jazzy)

From a terminal prompt, navigate to the StreamSDKStreamPlay folder and enter the command:
```
jazzy --podspec ../StreamPlayJazzy.podspec
```

Change Log:
===========

All notable changes to this project will be documented in this section.

### 0.2 - No changes to Core

### 0.1 - Initial build
