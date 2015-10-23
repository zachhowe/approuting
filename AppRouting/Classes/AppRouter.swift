//
//  AppRouter.swift
//
//  Created by Zach Howe on 7/24/15.
//  Copyright © 2015 Zach Howe. All rights reserved.
//

import Foundation

public class AppRouter {
    private struct RouteMapping {
        let route: AppRouteProtocol
        let action: AppActionProtocol
    }
    private var routeMappings = [RouteMapping]()
    private let validSchemes: [String]
    
    public init(schemes: [String] = []) {
        validSchemes = schemes
    }
    
    public func openURL(URL: NSURL) -> Bool {
        if !validateURL(URL) { return false }
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
    
    private func validateURL(URL: NSURL) -> Bool {
        return validSchemes.isEmpty || validSchemes.contains(URL.scheme)
    }
    
    public func matchOn(route: AppRouteProtocol, action: AppActionProtocol) {
        routeMappings.append(RouteMapping(route: route, action: action))
    }
    
    public func matchOn(route: String, action: (AppRoutingParameters) -> Void) throws {
        self.matchOn(try AppRoute(routePattern: route), action: AppAction(action: action))
    }
}
