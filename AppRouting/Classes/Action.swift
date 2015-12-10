//
//  Action.swift
//
//  Created by Zach Howe on 7/24/15.
//  Copyright © 2015 Zach Howe. All rights reserved.
//

public protocol ActionProtocol {
  func perform(parameters: RouteParameters)
}

public class Action: ActionProtocol {
  private let action: (RouteParameters) -> Void
  
  public init(action: (RouteParameters) -> Void) {
    self.action = action
  }
  
  public func perform(parameters: RouteParameters) {
    self.action(parameters)
  }
}
