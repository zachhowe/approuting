//
//  AppRoutingCommon.swift
//
//  Created by Zach Howe on 7/24/15.
//  Copyright © 2015 Zach Howe. All rights reserved.
//

import Foundation

public enum AppParameterType {
    case Number(Int)
    case Text(String)
}

public typealias AppRoutingParameters = [String: AppParameterType]
