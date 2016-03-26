//
//  RouteTests.swift
//
//  Created by Zach Howe on 7/24/15.
//  Copyright © 2015 Zach Howe. All rights reserved.
//

import XCTest
@testable import AppRouting

class RouteTests: XCTestCase {

  func test_routeWithValidRoutePattern() {
    let url1 = NSURL(string: "x-app:///burrito/1234")!
    let url2 = NSURL(string: "x-app:///burrito/1234/cheese/cheddar/addToCart")!
    
    let route1 = try? Route(pattern: "/burrito/:burrito_id:")
    XCTAssertNotNil(route1)
    
    XCTAssertEqual(route1!.paramKeys, ["burrito_id"])
    XCTAssertEqual(route1!.regex.pattern, "/burrito/([^/]*)/?$")
    XCTAssertTrue(route1!.matchesOnURL(url1))
    XCTAssertFalse(route1!.matchesOnURL(url2))
    XCTAssertEqual(route1!.paramsForURL(url1), [RouteParameter(name: "burrito_id", value: "1234")])
    XCTAssertEqual(route1!.paramsForURL(url2), [])
  }
  
  func test_routeWithValidRoutePattern_emptyUrlPath() {
    let url1 = NSURL(string: "x-app:")!
    let url2 = NSURL(string: "x-app:///hello")!
    
    let route1 = try? Route(pattern: "/hello")
    XCTAssertNotNil(route1)
    
    XCTAssertFalse(route1!.matchesOnURL(url1))
    XCTAssertEqual(route1!.paramsForURL(url1), [])
    
    XCTAssertTrue(route1!.matchesOnURL(url2))
    XCTAssertEqual(route1!.paramsForURL(url2), [])
  }
  
  func test_routeWithInvalidRoutePattern() {
    XCTAssertThrowsError(try Route(pattern: ":/burrito/:burrito_id/_id:/fds/cheese_name:/adaaald:::"))
  }

}
