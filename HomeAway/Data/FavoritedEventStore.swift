//
//  FavoritedEventStore.swift
//  HomeAway
//
//  Created by YIN CHAO LIAO on 12/29/18.
//  Copyright © 2018 CHAO LIAO. All rights reserved.
//

import Foundation

protocol KeyValueStoreProtocol {
    func array(forKey key: String) -> [Any]?
    func set(_ value: Any?, forKey key: String)
}

extension UserDefaults: KeyValueStoreProtocol {}

class FavoritedEventStore {
    
    static let shared = FavoritedEventStore()
    
    let storeKey = "favoritedEventIds"
    let store: KeyValueStoreProtocol
    
    // This initializer should only be used for testing. If it's not test, use the .shared singleton instead.
    init(backingStore: KeyValueStoreProtocol = UserDefaults.standard) {
        store = backingStore
    }
    
    func favoritedEventIds() -> [Int] {
        guard let favoritedIds = store.array(forKey: storeKey) as? [Int] else {
            return []
        }
        return favoritedIds
    }
    
    func favoriteEvent(for id: Int) {
        if var favoritedIds = store.array(forKey: storeKey) as? [Int] {
            favoritedIds.append(id)
            store.set(favoritedIds, forKey: storeKey)
        } else {
            store.set([id], forKey: storeKey)
        }
    }
    
    func unfavoriteEvent(for id: Int) {
        guard var favoritedIds = store.array(forKey: storeKey) as? [Int], let index = favoritedIds.firstIndex(of: id) else {
            return
        }
        favoritedIds.remove(at: index)
        store.set(favoritedIds, forKey: storeKey)
    }
}
