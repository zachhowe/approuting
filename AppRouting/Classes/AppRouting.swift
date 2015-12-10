//
//  AppRouting.swift
//
//  Created by Zach Howe on 7/24/15.
//  Copyright © 2015 Zach Howe. All rights reserved.
//

public enum RouteParameter {
  case Number(Int)
  case Text(String)
}

public typealias RouteParameters = [String: RouteParameter]
