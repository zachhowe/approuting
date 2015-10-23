//
//  AppAction.swift
//
//  Created by Zach Howe on 7/24/15.
//  Copyright © 2015 Zach Howe. All rights reserved.
//

import Foundation

public protocol AppActionProtocol {
    func perform(parameters: AppRoutingParameters)
}

public class AppAction: AppActionProtocol {
    private let action: (AppRoutingParameters) -> Void
    
    public init(action: (AppRoutingParameters) -> Void) {
        self.action = action
    }
    
    public func perform(parameters: AppRoutingParameters) {
        self.action(parameters)
    }
}
