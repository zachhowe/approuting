//
//  MockAction.swift
//  AppRouting
//
//  Created by Zach Howe on 3/25/16.
//  Copyright © 2016 Zach Howe. All rights reserved.
//

import Foundation
@testable import AppRouting

class MockAction {
  var didCallPerform: Bool = false
  var performCallSentParameters: [RouteParameter]?
}

extension MockAction: ActionProtocol {
  func perform(parameters: [RouteParameter]) {
    didCallPerform = true
    performCallSentParameters = parameters
  }
}
