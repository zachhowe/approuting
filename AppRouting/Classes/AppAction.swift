//
//  AppAction.swift
//
//  Created by Zach Howe on 7/24/15.
//  Copyright © 2015 Zach Howe. All rights reserved.
//

import Foundation

public protocol AppAction {
    func perform(parameters: AppRoutingParameters)
}

internal class AppRouterAction: AppAction {
    private let action: (AppRoutingParameters) -> Void
    
    internal init(action: (AppRoutingParameters) -> Void) {
        self.action = action
    }
    
    internal func perform(parameters: AppRoutingParameters) {
        self.action(parameters)
    }
}
