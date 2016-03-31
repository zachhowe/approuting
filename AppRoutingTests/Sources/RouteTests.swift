//
//  RouteTests.swift
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
    XCTAssertEqual(route1!.parametersForURL(url1), [RouteParameter(name: "burrito_id", value: "1234")])
    XCTAssertTrue(route1!.parametersForURL(url2).isEmpty)
  }
  
  func test_routeWithValidRoutePattern_emptyUrlPath() {
    let url1 = NSURL(string: "x-app:")!
    let url2 = NSURL(string: "x-app:///hello")!
    
    let route1 = try? Route(pattern: "/hello")
    XCTAssertNotNil(route1)
    
    XCTAssertFalse(route1!.matchesOnURL(url1))
    XCTAssertTrue(route1!.parametersForURL(url1).isEmpty)
    
    XCTAssertTrue(route1!.matchesOnURL(url2))
    XCTAssertTrue(route1!.parametersForURL(url2).isEmpty)
  }
  
  func test_routeWithInvalidRoutePattern() {
    XCTAssertThrowsError(try Route(pattern: ":/burrito/:burrito_id/_id:/fds/cheese_name:/adaaald:::"))
  }

}
