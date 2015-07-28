//
//  AppRouter.swift
//
//  Created by Zach Howe on 7/24/15.
//  Copyright © 2015 Zach Howe. All rights reserved.
//

import Foundation

public class AppRouter {
    private struct RouteMapping {
        let route: AppRoute
        let action: AppAction
    }
    private var routeMappings = [RouteMapping]()
    
    public func openURL(URL: NSURL) -> Bool {
        for routeMapping in routeMappings {
            let route = routeMapping.route
            let action = routeMapping.action
            
            if route.matchesOnURL(URL) {
                action.perform(route.paramsForURL(URL))
                return true
            }
        }
        return false
    }
    
    public func matchOn(route: AppRoute, action: AppAction) {
        routeMappings.append(RouteMapping(route: route, action: action))
    }
}
