//
//  Router.swift
//
//  Created by Zach Howe on 7/24/15.
//  Copyright © 2015 Zach Howe. All rights reserved.
//

import Foundation

public class Router {
  private struct RouteMapping {
    let route: RouteProtocol
    let action: ActionProtocol
  }
  private var routeMappings = [RouteMapping]()
  private let validSchemes: [String]
  private let validHosts: [String]
  
  public init(schemes: [String] = [], hosts: [String] = []) {
    validSchemes = schemes
    validHosts = hosts
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
  
  public func matchOn(route: RouteProtocol, action: ActionProtocol) {
    routeMappings.append(RouteMapping(route: route, action: action))
  }
  
  public func matchOn(pattern: String, action: (RouteParameters) -> Void) throws {
    matchOn(try Route(pattern: pattern), action: Action(action: action))
  }
}
