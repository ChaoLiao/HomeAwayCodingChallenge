//
//  FavoritedEventStoreTests.swift
//  HomeAwayTests
//
//  Created by YIN CHAO LIAO on 12/29/18.
//  Copyright © 2018 CHAO LIAO. All rights reserved.
//

import XCTest
@testable import HomeAway

class FavoritedEventStoreTests: XCTestCase {
    
    func testEmptyStore() {
        let store = FavoritedEventStore(backingStore: KeyValueStoreMock())
        let ids = store.favoritedEventIds()
        XCTAssertTrue(ids.isEmpty)
    }
    
    func testFavoriteEvent() {
        let store = FavoritedEventStore(backingStore: KeyValueStoreMock())
        let expectedIds = [1, 2, 3]
        for id in expectedIds {
            store.favoriteEvent(for: id)
        }
        XCTAssertEqual(store.favoritedEventIds(), expectedIds)
    }
    
    func testUnfavoriteEvent() {
        let store = FavoritedEventStore(backingStore: KeyValueStoreMock())
        let nonexistentId = 1
        store.unfavoriteEvent(for: nonexistentId)
        
        let favoritedEventIds = [2, 3, 4]
        let unfavoritedEventIds = favoritedEventIds[0...1]
        for id in favoritedEventIds {
            store.favoriteEvent(for: id)
        }
        
        for id in unfavoritedEventIds {
            store.unfavoriteEvent(for: id)
        }
        
        let remainingFavoritedEventIds = store.favoritedEventIds()
        XCTAssertEqual(remainingFavoritedEventIds, [favoritedEventIds[2]])
    }

}
