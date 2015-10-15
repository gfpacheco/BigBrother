//
//  BigBrotherTests.swift
//  BigBrother
//
//  Created by Marcelo Fabri on 02/01/15.
//  Copyright (c) 2015 Marcelo Fabri. All rights reserved.
//

import UIKit
import XCTest
import BigBrother

class BigBrotherTests: XCTestCase {

    let mockApplication: NetworkActivityIndicatorOwner = MockApplication()
    
    override func setUp() {
        super.setUp()
        
        BigBrotherURLProtocol.manager = BigBrotherManager(application: mockApplication)
    }
    
    override func tearDown() {
        BigBrotherURLProtocol.manager = BigBrotherManager()
        
        super.tearDown()
    }
    
    func testThatNetworkActivityIndicationTurnsOffWithURL(URL: NSURL) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        BigBrother.addToSessionConfiguration(configuration)
        
        let session = NSURLSession(configuration: configuration)
        
        let expectation = expectationWithDescription("GET \(URL)")
        
        let task = session.dataTaskWithURL(URL) { _ in
            delay(0.2) {
                expectation.fulfill()
                XCTAssertFalse(self.mockApplication.networkActivityIndicatorVisible)
            }
        }
        
        task.resume()
        
        let invisibilityDelayExpectation = expectationWithDescription("TurnOnInvisibilityDelayExpectation")
        delay(0.2) {
            invisibilityDelayExpectation.fulfill()
            XCTAssertTrue(self.mockApplication.networkActivityIndicatorVisible)
        }
        
        waitForExpectationsWithTimeout(task.originalRequest!.timeoutInterval + 1) { _ in
            task.cancel()
        }
    }

    func testThatNetworkActivityIndicatorTurnsOffIndicatorWhenRequestSucceeds() {
        let URL =  NSURL(string: "http://httpbin.org/delay/1")!
        testThatNetworkActivityIndicationTurnsOffWithURL(URL)
    }
    
    func testThatNetworkActivityIndicatorTurnsOffIndicatorWhenRequestFails() {
        let URL =  NSURL(string: "http://httpbin.org/status/500")!
        testThatNetworkActivityIndicationTurnsOffWithURL(URL)
    }
}

private class MockApplication: NetworkActivityIndicatorOwner {
    var networkActivityIndicatorVisible = false
}

private func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}
