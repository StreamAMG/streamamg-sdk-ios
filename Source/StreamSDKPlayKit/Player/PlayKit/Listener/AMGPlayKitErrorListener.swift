//
//  AMGPlayKitErrorListener.swift
//  StreamAMG
//
//  Created by Zachariah Tom on 09/01/2023.
//

import Foundation

public protocol AMGPlayKitErrorListener: AnyObject {
    func onError(error: PlaykitError?)
}
