//
//  MockRoute.swift
//  AppRouting
//
//  Created by Zach Howe on 3/25/16.
//  Copyright © 2016 Zach Howe. All rights reserved.
//

import Foundation
@testable import AppRouting

class MockRoute {
  var matchesOnURL: Bool
  var paramsForURL: [RouteParameter]

  init(matchesOnURL: Bool = false, paramsForURL: [RouteParameter] = []) {
    self.matchesOnURL = matchesOnURL
    self.paramsForURL = paramsForURL
  }
}

extension MockRoute: RouteProtocol {
  func matchesOnURL(URL: NSURL) -> Bool {
    return matchesOnURL
  }
  
  func paramsForURL(URL: NSURL) -> [RouteParameter] {
    return paramsForURL
  }
}
