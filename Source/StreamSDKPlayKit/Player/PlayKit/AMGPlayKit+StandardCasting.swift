//
//  AMGPlayKit+StandardCasting.swift
//  AMGPlayKit
//
//  Created by Mike Hall on 01/06/2021.
//

import Foundation
import GoogleCast
import MediaPlayer

extension AMGPlayKit {
    

    func setUpCasting(){
        sessionManager = GCKCastContext.sharedInstance().sessionManager
        sessionManager?.add(self)
        let airPlayBtn = MPVolumeView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        airPlayBtn.showsVolumeSlider = false
        addSubview(airPlayBtn)
        let frame = CGRect(x: 88, y: 0, width: 44, height: 44)
        castButton = GCKUICastButton(frame: frame)
        castButton.tintColor = UIColor.white
        addSubview(castButton)
    }
    
    // Chrome-Casting

    @objc func castDeviceDidChange(notification _: Notification) {
        if GCKCastContext.sharedInstance().castState != GCKCastState.noDevicesAvailable {
            // Display the instructions for how to use Google Cast on the first app use.
            GCKCastContext.sharedInstance().presentCastInstructionsViewControllerOnce(with: castButton)
        }
    }

    func playVideoRemotely() {
        GCKCastContext.sharedInstance().presentDefaultExpandedMediaControls()
        if let media = currentMedia, let url = media.contentURL {
            // TODO - Define media metadata.
            let metadata = GCKMediaMetadata()
            let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL: url)
            mediaInfoBuilder.streamType = GCKMediaStreamType.none
            mediaInfoBuilder.contentType = "video/mp4"
            //        mediaInfoBuilder.metadata = metadata
            mediaInformation = mediaInfoBuilder.build()

            let mediaLoadRequestDataBuilder = GCKMediaLoadRequestDataBuilder()
            mediaLoadRequestDataBuilder.mediaInformation = mediaInformation

            if let request = sessionManager?.currentSession?.remoteMediaClient?.loadMedia(with: mediaLoadRequestDataBuilder.build()) {
                request.delegate = self
            } else {
                print("Failed to load media on cast device")
            }
        }
    }


    public func sessionManager(_: GCKSessionManager,
                               didStart session: GCKSession) {
        print("sessionManager didStartSession: \(session)")
        sessionManager?.currentCastSession?.remoteMediaClient?.add(self)
        playVideoRemotely()
        session.remoteMediaClient?.add(self)
    }

    public func sessionManager(_: GCKSessionManager,
                               didResumeSession session: GCKSession) {
        print("sessionManager didResumeSession: \(session)")
        sessionManager?.currentCastSession?.remoteMediaClient?.add(self)

        //  showLoadVideoButton(showButton: true)
    }

    public func sessionManager(_: GCKSessionManager,
                               didEnd session: GCKSession,
                               withError error: Error?) {
        print("sessionManager didEndSession: \(session)")

        // Remove GCKRemoteMediaClientListener.
        sessionManager?.currentCastSession?.remoteMediaClient?.remove(self)

        if let error = error {
            showError(error)
        }

        // showLoadVideoButton(showButton: false)
    }

    public func sessionManager(_: GCKSessionManager,
                               didFailToStart session: GCKSession,
                               withError error: Error) {
        print("sessionManager didFailToStartSessionWithError: \(session) error: \(error)")

        // Remove GCKRemoteMediaClientListener.
        sessionManager?.currentCastSession?.remoteMediaClient?.remove(self)
    }

    // MARK: GCKRemoteMediaClientListener
    public func remoteMediaClient(_: GCKRemoteMediaClient,
                                  didUpdate mediaStatus: GCKMediaStatus?) {
        if let mediaStatus = mediaStatus {
            mediaInformation = mediaStatus.mediaInformation
        }
    }

    // MARK: - GCKRequestDelegate
    public func requestDidComplete(_ request: GCKRequest) {
        print("request \(Int(request.requestID)) completed")
    }

    public func request(_ request: GCKRequest,
                        didFailWithError error: GCKError) {
        print("request \(Int(request.requestID)) didFailWithError \(error)")
    }

    public func request(_ request: GCKRequest,
                        didAbortWith abortReason: GCKRequestAbortReason) {
        print("request \(Int(request.requestID)) didAbortWith reason \(abortReason)")
    }

    // MARK: Misc
    func showError(_ error: Error) {
        //      let alertController = UIAlertController(title: "Error",
        //                                              message: error.localizedDescription,
        //                                              preferredStyle: UIAlertController.Style.alert)
        //      let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        //      alertController.addAction(action)
        //
        //      present(alertController, animated: true, completion: nil)
        print ("ERROR!!!!! \(error.localizedDescription)")
    }
    
}
