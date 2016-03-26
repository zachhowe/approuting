//
//  RouterTests.swift
//  AppRouting
//
//  Created by Zach Howe on 3/25/16.
//  Copyright © 2016 Zach Howe. All rights reserved.
//

import XCTest
@testable import AppRouting

class RouterTests: XCTestCase {

  var httpURL: NSURL!
  var httpsURL: NSURL!
  var customSchemeURL: NSURL!

  override func setUp() {
    super.setUp()
    httpURL = NSURL(string: "http://github.com/zachhowe/approuting")
    httpsURL = NSURL(string: "https://github.com/zachhowe/approuting")
    customSchemeURL = NSURL(string: "approuting://github.com/zachhowe/approuting")
  }

  override func tearDown() {
    httpURL = nil
    httpsURL = nil
    customSchemeURL = nil
    super.tearDown()
  }
  
  func test_noCallbackWhenNoMatchRoute() {
    let router = Router(schemes: ["http", "https"])
    let a = MockAction()
    router.match(route: MockRoute(), action: a)
    router.openURL(httpsURL)
    XCTAssertFalse(a.didCallPerform)
    XCTAssertNil(a.performCallSentParameters)
  }

  func test_noCallbackWhenNoMatchScheme() {
    let router = Router(schemes: ["http", "https"])
    let a = MockAction()
    router.match(route: MockRoute(matchesOnURL: true), action: a)
    router.openURL(customSchemeURL)
    XCTAssertFalse(a.didCallPerform)
    XCTAssertNil(a.performCallSentParameters)
  }

  func test_callbackIsMade() {
    let router = Router(schemes: ["http", "https"])
    let a = MockAction()
    router.match(route: MockRoute(matchesOnURL: true), action: a)
    router.openURL(httpsURL)
    XCTAssertTrue(a.didCallPerform)
    XCTAssertNotNil(a.performCallSentParameters)
  }
  
  func test_throwsWhenProvidedInvalidRoutePattern() {
    func attemptRouteCreationWithBrokenPattern_One() throws {
      let router = Router()
      let invalidPattern = ":/burrito/:burrito_id/_id:/fds/cheese_name:/adaaald:::"
      let action = MockAction()
      try router.match(pattern: invalidPattern, action: action)
    }
    func attemptRouteCreationWithBrokenPattern_Two() throws {
      let router = Router()
      let invalidPattern = ":/burrito/:burrito_id/_id:/fds/cheese_name:/adaaald:::"
      try router.match(pattern: invalidPattern, action: { _ in })
    }
    XCTAssertThrowsError(try attemptRouteCreationWithBrokenPattern_One())
    XCTAssertThrowsError(try attemptRouteCreationWithBrokenPattern_Two())
  }
  
}
