//
//  AppRouter.swift
//
//  Created by Zach Howe on 7/24/15.
//  Copyright © 2015 Zach Howe. All rights reserved.
//

import Foundation

public class AppRouter {
    private enum RouteMap {
        case Map(AppRoute, AppAction)
    }
    private var routes: [RouteMap]
    
    public init() {
        routes = [RouteMap]()
    }
    
    public func openURL(URL: NSURL) -> Bool {
        for route in routes {
            switch route {
            case let .Map(route, action):
                if route.matchesOnURL(URL) {
                    action.perform(route.paramsForURL(URL))
                    return true
                }
            }
        }
        return false
    }
    
    public func matchOn(route: AppRoute, action: AppAction) {
        routes.append(RouteMap.Map(route, action))
    }
}
