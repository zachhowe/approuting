//
//  AppRouteTests.swift
//
//  Created by Zach Howe on 7/24/15.
//  Copyright © 2015 Zach Howe. All rights reserved.
//

import XCTest
@testable import AppRouting

class AppRouteTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRouteWithValidRoutePattern() {
        let url1 = NSURL(string: "x-app:///burrito/1234")!
        let url2 = NSURL(string: "x-app:///burrito/1234/cheese/cheddar/addToCart")!
        
        let route1 = AppRouterRoute(routePattern: "/burrito/:burrito_id:")
        XCTAssert(route1.error == nil)
        XCTAssertEqual(route1.paramKeys!, ["burrito_id"])
        XCTAssertEqual(route1.regex!.pattern, "/burrito/([^/]*)$")
        XCTAssertTrue(route1.matchesOnURL(url1))
        XCTAssertFalse(route1.matchesOnURL(url2))
//        XCTAssertEqual(route1.paramsForURL(url1), ["burrito_id" : AppRoutingParamType.Number(1234)])
        
        let route2 = AppRouterRoute(routePattern: "/burrito/:burrito_id:/cheese/:cheese_name:/addToCart")
        XCTAssert(route2.error == nil)
        XCTAssertEqual(route2.paramKeys!, ["burrito_id", "cheese_name"])
        XCTAssertEqual(route2.regex!.pattern, "/burrito/([^/]*)/cheese/([^/]*)/addToCart$")
        XCTAssertFalse(route2.matchesOnURL(url1))
        XCTAssertTrue(route2.matchesOnURL(url2))
//        XCTAssertEqual(route2.paramsForURL(url2), ["burrito_id" : AppRoutingParamType.Number(1234), "cheese_name" : AppRoutingParamType.Text("cheddar")])
    }
    
    func testRouteWithInvalidRoutePattern() {
        let route1 = AppRouterRoute(routePattern: ":/burrito/:burrito_id/_id:/fds/cheese_name:/adaaald:::")
        XCTAssert(route1.error != nil)
        let url1 = NSURL(string: "x-app:///burrito/1234/cheese/cheddar/addToCart")!
        XCTAssertFalse(route1.matchesOnURL(url1))
    }
}
