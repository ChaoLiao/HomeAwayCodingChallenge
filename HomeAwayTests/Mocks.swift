//
//  Mocks.swift
//  HomeAwayTests
//
//  Created by YIN CHAO LIAO on 12/28/18.
//  Copyright © 2018 CHAO LIAO. All rights reserved.
//

import Foundation
@testable import HomeAway

class NetworkSessionMock: NetworkSession {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    private(set) var didLoadData = false
    
    init(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        self.data = data
        self.response = response
        self.error = error
    }
    
    func loadData(from url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkSessionDataTask {
        didLoadData = true
        completionHandler(data, response, error)
        return NetworkSessionDataTaskMock()
    }
}

class NetworkSessionDataTaskMock: NetworkSessionDataTask {
    func cancel() {}
}

class KeyValueStoreMock: KeyValueStoreProtocol {
    var store = [String: Any]()
    
    func set(_ value: Any?, forKey key: String) {
        store[key] = value
    }
    
    func array(forKey key: String) -> [Any]? {
        if let value = store[key] as? [Any] {
            return value
        }
        return nil
    }
}
