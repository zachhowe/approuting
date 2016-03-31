//
//  RouterTests.swift
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
