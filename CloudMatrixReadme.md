
StreamSDK CloudMatrix Module
=====================
The CloudMatrix API, and in extension, the CloudMatrix SDK provides a feed for on demand video clips and other media. The CloudMatrix API is extensive and, potentially, complex for in depth searches, the CloudMatrix SDK aims to reduce complexity whilst handling API returns for all types of calls to the API with a single model.

In general, there are 2 main ways of accessing the API, and an extra 2 endpoints for more specific requests, the SDK handles all 4 request types.

The request types are:

FEED – bringing a static (pre-defined) set of data back, generally a stock list of videos or news feeds, with little to no customisation

SEARCH – searching the entire repository of videos and news feeds for specific items and returning only those

TERMS – checking how often a word or phrase is used in a given string array (Tags, for example)

ENTITLEMENTS – Right now, I just don’t know……

The SDK handles the returning API data in a single model, as well as offering methods for automatically handling paging data.

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
pod 'StreamAMGSDK/CloudMatrix'
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

##Setting up CloudMatrix

You should instantiate CloudMatrix to use it.

```
var cloudMatrix = CloudMatrix()
```

As many of these objects can be created as is required

##Creating a CloudMatrix set up object.
To access a predefined static URL, you can simply pass the url to a request object, but to perform searches and more advanced feed calls, you will need a set up object created.

The set up object is passed to an individual request via dot notation or through the builder templates

A simple set up object contains, at the very least, a valid user id, key and url
```
var cloudMatrixSetUp: CloudMatrixSetupModel = CloudMatrixSetupModel(userID: "(valid ID)", key: "(valid Key)", url: "(valid URL)")
```

You can, however, refine it as required
```
var cloudMatrixSetUp: CloudMatrixSetupModel = CloudMatrixSetupModel(userID: "(valid ID)", key: "(valid Key)", url: "(valid URL)", debugURL:"(debug URL)", version: "v2", language: "fr")
```

Multiple set up objects can be created, and different objects can be passed to different requests using the same CloudMatrix object if required, but it is seen as better practice to use a single set up object for each CloudMatrix object

##Making API Requests
The module has two ways of programmatically making requests to the API, as a standard Object, instantiating the request and adding to it through standard dot notation, or as an Object Builder.

Using the Object Builder is the preferred method, but both will work, and are documented below

Once a request has been made and delivered, the SDK will return a valid response model (or an error object) to a callback specified. The responses and errors are discussed later in this document.

There are, generally, 2 parts to sending requests, creating the request itself, and sending the request through the StreamSDK-Core networking system. Occasionally this can be reduced to a single call, but with a little ‘heavy lifting’ beforehand. Where this is possible, it will be noted in the documentation.

In each instance there is an optional callback which allows the user to process any returned data. Although the callback is, technically, optional, it is not seen that there are many advantages of not providing one.

```
let request: CloudMatrixRequest = CloudMatrixRequest //(See below)

cloudMatrix.callAPI(request: request){ (result: Result<CloudMatrixResponse, StreamAMGError>) in
switch result {
case .success(let cmData):
        // Process the valid cmData object (CloudMatrixResponse) here
case .failure(let cmError):
        // Process the valid cmError object (StreamAMGError) here
}
}
```
##Accessing Static Feeds
Using pre-defined complete URLs
Many requests made to the APIs are simple injections of pre-defined URLs that are made available either whilst in development, or at runtime through access to a separate API feed (a config, for example)

These URLs come fully formed and can be sent to CloudMatrix without any intervention from this SDK, there are, however, several advantages to using the SDK to process these requests:

-	Networking is handled
-	Errors are handled
-	A standard model is used for the response
-	Paging, if necessary, is handled

To utilise the CloudMatrix module for this, is as simple as making a basic request.

Using the Builder:
```
let feed = CloudMatrixRequest
        .FeedBuilder()
        .url("(Fully formed API request URL)")
        .build()
```
Using standard initialisation:
```
let feed = let fd = CloudMatrixRequest(apiFunction: .FEED, event: nil, params: [], url: "(Fully formed API request URL)")
```
or:

```
let feed = CloudMatrixRequest(url = "(Fully formed API request URL)")
```

and then sending it to CloudMatrix using the ‘callAPI’ method:

```
cloudMatrix.callAPI(request:feed, completion: completion)
```
Or:
```
cloudMatrix.callAPI(request: feed) { (result: Result<CloudMatrixResponse, StreamAMGError>) in
switch result {
case .success(let cmData):
        // Process the valid cmData object (CloudMatrixResponse) here
case .failure(let cmError):
        // Process the valid cmError object (StreamAMGError) here
}
}
```
##Using a specific event
If you have only the event details, and wish to make a call to the API using that, it is just as simple.

Please note, the CloudMatrix module must have been initialised before this call is made

Using the Builder:
```
let feed = CloudMatrixRequest
        .FeedBuilder()
        .cmTarget(cloudMatrixSetUp)
        .event("(Valid event ID")
        .build()
```

Using standard initialisation:
```
let feed = CloudMatrixRequest(CloudMatrixFunction.FEED, "(Valid event ID)", ArrayList(), null, 0)
```
or:
```
val feed = CloudMatrixRequest(apiFunction: .FEED, event: "(Valid event ID)")
feed.cmSetup = cloudMatrixSetUp // Must be passed using dot notation before the call to the API is made
```

and then sending it to CloudMatrix using the ‘callAPI’ method:

```
cloudMatrix.callAPI(request:feed, completion: completion)
```
Or:
```
cloudMatrix.callAPI(request: feed) { (result: Result<CloudMatrixResponse, StreamAMGError>) in
switch result {
case .success(let cmData):
        // Process the valid cmData object (CloudMatrixResponse) here
case .failure(let cmError):
        // Process the valid cmError object (StreamAMGError) here
}
}
```

##Using the StreamSDK-CloudMatrix Search Capabilities
There is a vast array of search and filter capabilities available in CloudMatrix, and compex searches can be constructed in the SDK using the Builder.
```
let search = CloudMatrixRequest
        .SearchBuilder()
        .cmTarget(cloudMatrixSetUp)
        .isEqualTo(target: .TITLETEXT, query: "Football")
        .isLessThan(target: .VIDEODURATION, query: 120)
        .contains(target: “homeTeam”, query: “West Ham”)
        .build()
```

There is no limit to the amount of parameters that can be included, or to the types of searches that can be mixed.

Currently there is only ‘AND’ searches, but ‘OR’ is being worked on.


The build components are flexible:
```
isEqualTo(target: CloudMatrixQueryType, query: String)

isEqualTo(target: String, query: String)

isEqualTo(target: CloudMatrixQueryType, query: NSNumber)

isEqualTo(target: String, query: NSNumber)
```
The ‘target’ is the field in the database being referenced, the ‘query’ is the item being searched for

For all of the following search types, a target can be either one of a pre-defined number of Query Types, or can be a String value, where a query is required, this can be either a String or any Number type. For simplicity, only (target: CloudMatrixQueryType, query: String) examples are shown:

Exact match of word or numbers
```
.isEqualTo(target: CloudMatrixQueryType, query: String)
```

Value is greater than (or equal to) the query. This can be passed as a String or Number
```
.isGreaterThan(target: CloudMatrixQueryType, query: String)
.isGreaterThanOrEqualTo(target: CloudMatrixQueryType, query: String)
```

Value is less than (or equal to) the query. This can be passed as a String or Number
```
.isLessThan(target: CloudMatrixQueryType, query: String)
.isLessThanOrEqualTo(target: CloudMatrixQueryType, query: String)
```

Fuzzy search – “foot” will match ‘right-footed’, ‘football’ and ‘foot’, etc
```
.isLike(target: CloudMatrixQueryType, query: String)
```

Starting character search – “foot” will match ‘football’ and ‘foot’, but not ‘right-footed’
```
.startsWith(target: CloudMatrixQueryType, query: String)
```

String array contains specified item
```
.contains(target: CloudMatrixQueryType, query: String)
```

The following searches require no ‘query’

Return only records that have a specified field
```
.exists(target: CloudMatrixQueryType)
```

Boolean searches on a field
```
.isTrue(target: CloudMatrixQueryType)
.isFalse(target: CloudMatrixQueryType)
```

##Batch processing

In a normal call to the server, you will likely want the response to be immediately delivered back to the callback so the app can respond accordingly. There may be occasions, however, where it would be preferable for multiple jobs to complete before processing.

In these situations, the StreamSDKBatchJob service can collate any number of jobs, from either a single module or a mixture of any modules, make a request from the API and hold the responses until all jobs have been completed.

Once all jobs are complete, the service will then fire all callbacks.
```
        let search1 = CloudMatrixRequest
                .FeedBuilder()
                .url(staticURL1)
                .build()

        let search2 = CloudMatrixRequest
                .FeedBuilder()
                .url(staticurl2)
                .build()

let queue = StreamSDKBatchJob()
        queue.add(request: CloudMatrixJob(request: search1, completion: cmCompletion))
        queue.add(request: CloudMatrixJob(request: search2, completion: cmCompletion))
        ....
        queue.fireBatch()
```

The batch job can be fired as many times as required once created, but will not allow a restart until any running batch has completed

##The CloudMatrix Response Model

Accessing retrieved data
When a successful call to the API has been returned, the sdk makes available a data model of type ‘CloudMatrixResponse?’. This model contains the following information:

CloudMatrixResponse  root
-	metadata: CloudMatrixFeedMetaDataModel – All responses
    o	id: String?
    o	name: String?
    o	itle: String?
    o	description: String?
    o	target: String?
-	sections: ArrayList<CloudMatrixSectionModel>? – Feed responses only
    o	id: String?,
    o	name: String?,
    o	itemData: ArrayList<CloudMatrixItemDataModel>? (see ItemDataModel below)
    o	pagingData: CloudMatrixPagingDataModel (see PagingDataModel below)
-	itemData: ArrayList<CloudMatrixItemDataModel>? – Search responses only (see ItemDataModel below)
-	pagingData: CloudMatrixPagingDataModel? – Search responses only (see ItemDataModel below)

CloudMatrixResponse  PagingDataModel
Any response is guaranteed to have paging data included, with direct URLs and Feed responses, this data is contained in the ‘sections’ array, for search responses, this is contained in the root of the response.
The SDK can automatically provide paging, but if it is preferred that it should be handled manually, the correct paging data can be retrieved from the root of CloudMatrixResponse by calling the ‘fetchPagingData(section:Int?)’

val pagingData = response.fetchPagingData() (selects the ‘current’ section if Feed response, or all data if a search

val pagingData = response.fetchPagingData(section = 3) (selects the section 3 if Feed response, ignores ‘section’ if a search

The PagingDataModel has the following structure:
-	totalCount: Int
-	itemCount: Int
-	pageCount: Int
-	pageSize: Int
-	pageIndex: Int

CloudMatrixResponse  ItemDataModel
Similar to PagingData, ItemData can either be stored in a section with direct URLs and Feed responses, or in the root of the response for searches.
The SDK can also automatically provide this data, but if it is preferred that it should be handled manually, the correct item data can be retrieved from the root of CloudMatrixResponse by calling the ‘fetchResult(section:Int?)’ or the ‘fetchResults()’ methods/

val itemData = response.fetchResults() (selects all results returned by the API, even if split in sections)

val itemData = response. fetchResults(section = 3) (selects the section 3 if Feed response, ignores ‘section’ if a search)

The ItemDataModel has the following structure:
-	id: String?
-	mediaData: CloudMatrixMediaDataModel?
    o	       mediaType: String?,
    o	       entryId: String?,
    o	       entryStatus: String?,
    o	       thumbnailUrl: String?
-	metaData: CloudMatrixMetaDataModel? – See ‘MetaDataModel’ below
-   sortData: ArrayList<CloudMatrixSortDataModel>
    o	       feedId: String?,
    o	       sectionId: String?,
    o	       order: Int?
-	publicationData: CloudMatrixPublicationDataModel?
    o	       createdAt: String?,
    o	       updatedAt: String?,
    o	       released: Boolean?,
    o	       releaseFrom: String?,
    o	       releaseTo: String?

CloudMatrixResponse  MetaDataModel
The MetaDataModel does not follow a standard ‘model’ as the keys in the structure are customisable per-partner. Instead of a concrete data model, the object is purely a key / value HashMap (HashMap<String, Any>)
Although there is no defined structure to this object, some keys are guaranteed to exist, although there is no guarantee these will not be null, the list below contains these items and a convenience method (called on the ItemData, not the MetaData) to retrieve them.
-	title: String? – itemData.getTitle() – also: itemData.metaData.title
-	body: String? – itemData.getBody() – also: itemData.metaData.body
-	duration: Double? – itemData.getDuration() – also: itemData.metaData.duration
-	tags: Array<String>? – itemData.getTags() – also: itemData.metaData.tags

To access custom data, convenience methods to retrieve Strings, Integers and Arrays from the meta data are provided:

-	itemData.metaData.getString(key: String): String?
-	itemData.metaData.getInt(key: String): Int?
-	itemData.metaData.getLong(key: String): Long?
-	itemData.metaData.getDouble(key: String): Double?
-	itemData.metaData.getBool(key: String): Bool?
-	itemData.metaData.getArray(key: String): Array<Any>?
-	itemData.metaData.getStringArray (key: String)): Array<String>?

##Callbacks in CloudMatrix
To access the data returned by the SDK, a callback is required for each request. This callback can either be added in line to an individual request, or a defined callback can be added.

The callback is required in the form:
((Result<CloudMatrixResponse, StreamAMGError>) -> Void)?

It can be added inline:
```
cloudMatrix.callAPI(request: request){ (result: Result<CloudMatrixResponse, StreamAMGError>) in
switch result {
case .success(let cmData):
        // Process the valid cmData object (CloudMatrixResponse) here
case .failure(let cmError):
        // Process the valid cmError object (StreamAMGError) here
}
}
```

Or as a reusable parameter:
```
val cloudMatrixCallback: ((Result<CloudMatrixResponse, StreamAMGError>) -> Void) = { (result: Result<CloudMatrixResponse, StreamAMGError>) in
switch result {
case .success(let cmData):
        // Process the valid cmData object (CloudMatrixResponse) here
case .failure(let cmError):
        // Process the valid cmError object (StreamAMGError) here
}
}

cloudMatrix.callAPI(request:feed, completion: completion)
```


Paging in StreamSDK-CloudMatrix
The CloudMatrix module handles paging for any responses received. By default the API will return 200 records by page, but this can be configured in any request by either passing a Builder option or during initialisation

Using Builder:
```
.paginateBy(paginateBy: Int)
```


Using standard initialisation
```
val feed = CloudMatrixRequest(paginateBy = (items per page as Int))
```

Paging data can be called via the response model to enable / disable paging buttons / pull to refresh, etc
The current request can be paginated using the following methods:
Previous page
```
cloudMatrix.loadPreviousPage()
```

Next page
```
cloudMatrix.loadNextPage()
```


##Currently available data
The accepted valid fields for StreamPlay are as follows:
```
enum CloudMatrixQueryType{
ID
MEDIATYPE
ENTRYID
ENTRYSTATUS
THUMBNAILURL
BODYTEXT
VIDEODURATION
TITLETEXT
TAGS
CREATEDDATE
UPDATEDDATE
RELEASED
RELEASEFROM
RELEASETO
}

```

Change Log:
===========

All notable changes to this project will be documented in this section.

### 0.2 -> 0.10 - No changes to CloudMatrix

### 0.1 - Initial build
