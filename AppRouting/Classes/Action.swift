//
//  Action.swift
//
//  Created by Zach Howe on 7/24/15.
//  Copyright © 2015 Zach Howe. All rights reserved.
//

public protocol ActionProtocol {
  func perform(parameters: [RouteParameter])
}

class Action: ActionProtocol {
  let action: ([RouteParameter]) -> Void
  
  init(action: ([RouteParameter]) -> Void) {
    self.action = action
  }
  
  func perform(parameters: [RouteParameter]) {
    action(parameters)
  }
}
