//
//  AMGPlayKitListener.swift
//  StreamAMG
//
//  Created by Mike Hall on 30/06/2021.
//

import Foundation
import PlayKit

public protocol AMGPlayKitListener: AnyObject {
    func playEventOccurred(state: AMGPlayKitState)
    func stopEventOccurred(state: AMGPlayKitState)
    func loadChangeStateOccurred(state: AMGPlayKitState)
    func durationChangeOccurred(state: AMGPlayKitState)
    func errorOccurred(error: AMGPlayKitError)
    func bitrateChangeOccurred(list: [FlavorAsset]?)
    func tracksAvailable(tracks: PKTracks)
}
