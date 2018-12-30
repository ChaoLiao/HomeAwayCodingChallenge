//
//  CellViewModelTests.swift
//  HomeAwayTests
//
//  Created by YIN CHAO LIAO on 12/27/18.
//  Copyright © 2018 CHAO LIAO. All rights reserved.
//

import XCTest
@testable import HomeAway

class CellViewModelTests: XCTestCase {

    func testViewModelFromDataModel() {
        let expectedEventId = 30
        let expectedImageUrl = "testImageUrl"
        let expectedTitle = "test title"
        let expectedLocation = "Boston, MA"
        
        let isoDateString = "2012-03-09T19:00:00"
        let expectedDateTime: String = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let date = dateFormatter.date(from: isoDateString)!
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:MM a"
            return dateFormatter.string(from: date)
        }()
        
        let venue = Venue(id: 10, name: "td garden", city: "Boston", state: "MA")
        let performer = Performer(id: 20, type: "Rapper", name: "Eminem", image: expectedImageUrl, images: [:])
        let event = Event(id: expectedEventId, title: expectedTitle, isoDateLocal: isoDateString, venue: venue, performers: [performer], isFavorited: true)
        
        let eventCellViewModel = EventCellViewModel(eventModel: event)
        XCTAssertEqual(eventCellViewModel.id, expectedEventId)
        XCTAssertEqual(eventCellViewModel.title, expectedTitle)
        XCTAssertEqual(eventCellViewModel.imageUrl, URL(string: expectedImageUrl))
        XCTAssertEqual(eventCellViewModel.dateTime, expectedDateTime)
        XCTAssertEqual(eventCellViewModel.location, expectedLocation)
        XCTAssertTrue(eventCellViewModel.isFavorited)
    }
    
    func testLoadImageWithoutImageUrl() {
        let venue = Venue(id: 10, name: "td garden", city: "Boston", state: "MA")
        let performer = Performer(id: 20, type: "Rapper", name: "Eminem", image: nil, images: [:])
        let event = Event(id: 1, title: "test concert", isoDateLocal: "yyyy-MM-dd'T'HH:mm:ss", venue: venue, performers: [performer], isFavorited: true)
        let viewModel = EventCellViewModel(eventModel: event)
        let networkSessionMock = NetworkSessionMock()
        var completionHandlerCalled = false
        
        viewModel.loadImage(networkSession: networkSessionMock) { (image) in
            completionHandlerCalled = true
            XCTAssertNil(image)
            XCTAssertFalse(networkSessionMock.didLoadData)
        }
        XCTAssertTrue(completionHandlerCalled)
    }
    
    func testLoadImageWhenImageAlreadyLoaded() {
        let venue = Venue(id: 10, name: "td garden", city: "Boston", state: "MA")
        let performer = Performer(id: 20, type: "Rapper", name: "Eminem", image: "imageUrl", images: [:])
        let event = Event(id: 1, title: "test concert", isoDateLocal: "yyyy-MM-dd'T'HH:mm:ss", venue: venue, performers: [performer], isFavorited: true)
        let viewModel = EventCellViewModel(eventModel: event)
        viewModel.image = UIImage()
        let networkSessionMock = NetworkSessionMock()
        var completionHandlerCalled = false
        
        viewModel.loadImage(networkSession: networkSessionMock) { (image) in
            completionHandlerCalled = true
            XCTAssertNotNil(image)
            XCTAssertFalse(networkSessionMock.didLoadData)
        }
        XCTAssertTrue(completionHandlerCalled)
    }
    
    func testLoadImageFromUrl() {
        let venue = Venue(id: 10, name: "td garden", city: "Boston", state: "MA")
        let performer = Performer(id: 20, type: "Rapper", name: "Eminem", image: "imageUrl", images: [:])
        let event = Event(id: 1, title: "test concert", isoDateLocal: "yyyy-MM-dd'T'HH:mm:ss", venue: venue, performers: [performer], isFavorited: true)
        let viewModel = EventCellViewModel(eventModel: event)
        
        let response = HTTPURLResponse(url: URL(string: "imageUrl")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = UIImage(named: "icon-heart-48")!.pngData()
        let networkSessionMock = NetworkSessionMock(data: data, response: response, error: nil)
        var completionHandlerCalled = false
        
        viewModel.loadImage(networkSession: networkSessionMock) { (image) in
            completionHandlerCalled = true
            XCTAssertNotNil(image)
            XCTAssertTrue(networkSessionMock.didLoadData)
        }
        XCTAssertTrue(completionHandlerCalled)
    }
}
