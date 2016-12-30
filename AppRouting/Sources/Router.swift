//
//  Router.swift
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015-2016 Zachary Howe
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
  
  @discardableResult
  public func openURL(_ url: URL) -> Bool {
    if !canOpenURL(url) { return false }
    for routeMapping in routeMappings {
      let route = routeMapping.route
      let action = routeMapping.action
      
      if route.matches(url: url) {
        action.perform(route.parameters(url: url))
        return true
      }
    }
    return false
  }
  
  public func canOpenURL(_ url: URL) -> Bool {
    if validSchemes.isEmpty || validSchemes.contains(url.scheme!) {
      return true
    }
    return false
  }
  
  public func match(route: RouteProtocol, action: ActionProtocol) {
    routeMappings.append(RouteMapping(route: route, action: action))
  }
  
  public func match(pattern: String, action: @escaping (RouteParameters) -> Void) throws {
    match(route: try Route(pattern: pattern), action: Action(action: action))
  }

  public func match(pattern: String, action: ActionProtocol) throws {
    match(route: try Route(pattern: pattern), action: action)
  }
}
