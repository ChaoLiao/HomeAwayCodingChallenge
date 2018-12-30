//
//  SeatGeekAPITests.swift
//  HomeAwayTests
//
//  Created by YIN CHAO LIAO on 12/25/18.
//  Copyright © 2018 CHAO LIAO. All rights reserved.
//

import XCTest
@testable import HomeAway

class SeatGeekAPITests: XCTestCase {

    func testSearchWithError() {
        struct TestError: Error {}
        let networkSession = NetworkSessionMock(error: TestError())
        let seatGeekAPI = SeatGeekAPI(networkSession: networkSession)
        var completionHandlerCalled = false
        
        seatGeekAPI.search(with: "test.com/test") { (error, events) in
            completionHandlerCalled = true
            XCTAssertNotNil(error)
            XCTAssertTrue(error is TestError)
            XCTAssertTrue(events.isEmpty)
        }
        
        XCTAssertTrue(completionHandlerCalled)
    }
    
    func testSearchWithUnsuccessfulResponse() {
        let urlString = "test"
        let expectedStatusCode = 400
        let url = URL(string: urlString)!
        let response = HTTPURLResponse(url: url, statusCode: expectedStatusCode, httpVersion: nil, headerFields: nil)
        let networkSession = NetworkSessionMock(response: response)
        let seatGeekAPI = SeatGeekAPI(networkSession: networkSession)
        var completionHandlerCalled = false
        
        seatGeekAPI.search(with: urlString) { (error, events) in
            completionHandlerCalled = true
            XCTAssertNotNil(error)
            
            XCTAssertTrue(error is SeatGeekAPI.SearchRequestError)
            
            let error = error as! SeatGeekAPI.SearchRequestError
            if case .unsuccessfulResponse(let statusCode) = error {
                XCTAssertNotNil(statusCode)
                XCTAssertEqual(statusCode, expectedStatusCode)
            } else {
                XCTAssertTrue(false, "Incorrect error is thrown by the search request")
            }
            
            XCTAssertTrue(events.isEmpty)
        }
        XCTAssertTrue(completionHandlerCalled)
    }
    
    func testSearchWithoutData() {
        let urlString = "test"
        let response = HTTPURLResponse(url: URL(string: urlString)!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let networkSession = NetworkSessionMock(data: nil, response: response, error: nil)
        let seatGeekAPI = SeatGeekAPI(networkSession: networkSession)
        var completionHandlerCalled = false
        
        seatGeekAPI.search(with: urlString) { (error, events) in
            completionHandlerCalled = true
            XCTAssertNotNil(error)
            XCTAssertTrue(error is SeatGeekAPI.SearchRequestError)
            
            let error = error as! SeatGeekAPI.SearchRequestError
            if case .invalidDataReturned = error {}
            else {
                XCTAssertTrue(false, "Incorrect error is thrown by the search request")
            }
            XCTAssertTrue(events.isEmpty)
        }
        XCTAssertTrue(completionHandlerCalled)
    }
    
    func testSearchSuccess() {
        let urlString = "test"
        let response = HTTPURLResponse(url: URL(string: urlString)!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let json: [String: Any] = [
            "events": [
                [
                    "id": 1,
                    "title": "test title",
                    "datetime_local": "2012-03-12T18:45:00",
                    "venue": [
                        "id": 10,
                        "name": "TD Garden",
                        "city": "Boston",
                        "state": "MA",
                    ],
                    "performers": [[
                        "id": 100,
                        "type": "rapper",
                        "name": "Eminem",
                        "image": "imageUrl",
                        "images": [
                            "huge": "testimageurl"
                        ]
                    ]]
                ],
                [
                    "id": 2,
                    "title": "test title 2",
                    "datetime_local": "2012-03-13T18:45:00",
                    "venue": [
                        "id": 20,
                        "name": "Oracle Arena",
                        "city": "San Francisco",
                        "state": "CA",
                    ],
                    "performers": [[
                        "id": 200,
                        "type": "Comic",
                        "name": "Chris Rock",
                        "image": "imageUrl2",
                        "images": [
                            "huge": "testimageurl2"
                        ]
                    ]]
                ]
                
            ]
        ]
        let data: Data?
        do {
            data = try JSONSerialization.data(withJSONObject: json)
        } catch {
            XCTAssert(false, "invalid json data")
            return
        }
        let networkSession = NetworkSessionMock(data: data, response: response)
        
        let seatGeekAPI = SeatGeekAPI(networkSession: networkSession)
        
        var completionHandlerCalled = false
        seatGeekAPI.search(with: urlString, favoritedEventIds: [1]) { (error, events) in
            completionHandlerCalled = true
            XCTAssertNil(error)
            XCTAssertFalse(events.isEmpty)
            XCTAssertTrue(events[0].isFavorited)
            XCTAssertFalse(events[1].isFavorited)
        }
        
        XCTAssertTrue(completionHandlerCalled)
    }

}
