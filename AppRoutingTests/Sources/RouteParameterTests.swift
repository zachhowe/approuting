//
//  RouteParameterTests.swift
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

class RouteParameterTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func test_routeParameterEquality() {
    let parameter = RouteParameter(name: "projectName", value: "AppRouting")
    
    XCTAssertEqual(parameter, RouteParameter(name: "projectName", value: "AppRouting"))
    XCTAssertNotEqual(parameter, RouteParameter(name: "projectName", value: "AppRouter"))
  }
  
  func test_routeParameterAsInt() {
    let parameter1 = RouteParameter(name: "version", value: "12")
    let parameter2 = RouteParameter(name: "version", value: "a10")
    let parameter3 = RouteParameter(name: "version", value: "12.2")
    XCTAssertEqual(parameter1.integerValue, 12)
    XCTAssertNil(parameter2.integerValue)
    XCTAssertNil(parameter3.integerValue)
  }
  
  func test_routeParameterAsDouble() {
    let parameter1 = RouteParameter(name: "version", value: "47")
    let parameter2 = RouteParameter(name: "version", value: "47.2.asddd")
    let parameter3 = RouteParameter(name: "version", value: "47.8")
    XCTAssertEqual(parameter1.doubleValue, 47)
    XCTAssertNil(parameter2.doubleValue)
    XCTAssertEqual(parameter3.doubleValue, 47.8)
  }
  
}
