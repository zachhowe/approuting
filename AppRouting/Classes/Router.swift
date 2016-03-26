//
//  Router.swift
//
//  Created by Zach Howe on 7/24/15.
//  Copyright © 2015 Zach Howe. All rights reserved.
//

import Foundation

public final class Router {
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
    if !canOpenURL(URL) { return false }
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
  
  public func canOpenURL(URL: NSURL) -> Bool {
    if validSchemes.isEmpty || validSchemes.contains(URL.scheme) {
      return true
    }
    return false
  }
  
  public func match(route route: RouteProtocol, action: ActionProtocol) {
    routeMappings.append(RouteMapping(route: route, action: action))
  }
  
  public func match(pattern pattern: String, action: ([RouteParameter]) -> Void) throws {
    match(route: try Route(pattern: pattern), action: Action(action: action))
  }

  public func match(pattern pattern: String, action: ActionProtocol) throws {
    match(route: try Route(pattern: pattern), action: action)
  }
}
