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
        
        // XCTAssertEqual(route1.paramsForURL(url1), ["burrito_id" : AppRoutingParamType.Number(1234)])
        //
        // Workaround:
        let paramSet1 = route1.paramsForURL(url1)
        XCTAssert(paramSet1.count == 1)
        if let paramSet1_pos0_index = paramSet1.indexForKey("burrito_id") {
            let param0 = paramSet1[paramSet1_pos0_index]
            
            switch param0.1 {
            case let .Number(n):
                XCTAssertEqual(n, 1234)
            default:
                XCTFail("Could not match param 0")
            }
        } else {
            XCTFail("No params matched for url1 of url1 on route1")
        }
        
        let route2 = AppRouterRoute(routePattern: "/burrito/:burrito_id:/cheese/:cheese_name:/addToCart")
        XCTAssert(route2.error == nil)
        XCTAssertEqual(route2.paramKeys!, ["burrito_id", "cheese_name"])
        XCTAssertEqual(route2.regex!.pattern, "/burrito/([^/]*)/cheese/([^/]*)/addToCart$")
        XCTAssertFalse(route2.matchesOnURL(url1))
        XCTAssertTrue(route2.matchesOnURL(url2))
        
        // XCTAssertEqual(route2.paramsForURL(url2), ["burrito_id" : AppRoutingParamType.Number(1234), "cheese_name" : AppRoutingParamType.Text("cheddar")])
        //
        // Workaround:
        let paramSet2 = route2.paramsForURL(url2)
        XCTAssert(paramSet2.count == 2)
        if let paramSet2_pos0_index = paramSet2.indexForKey("burrito_id"),
            let paramSet2_pos1_index = paramSet2.indexForKey("cheese_name") {
                
                let param0 = paramSet2[paramSet2_pos0_index]
                let param1 = paramSet2[paramSet2_pos1_index]
                
                switch param0.1 {
                case let .Number(n):
                    XCTAssertEqual(n, 1234)
                default:
                    XCTFail("Could not match param 0 of url2 on route2")
                }
                
                switch param1.1 {
                case let .Text(t):
                    XCTAssertEqual(t, "cheddar")
                default:
                    XCTFail("Could not match param 1 of url2 on route2")
                }
        } else {
            XCTFail("No params matched for url2 on route2")
        }
    }
    
    func testRouteWithInvalidRoutePattern() {
        let route1 = AppRouterRoute(routePattern: ":/burrito/:burrito_id/_id:/fds/cheese_name:/adaaald:::")
        XCTAssert(route1.error != nil)
        let url1 = NSURL(string: "x-app:///burrito/1234/cheese/cheddar/addToCart")!
        XCTAssertFalse(route1.matchesOnURL(url1))
    }
}
