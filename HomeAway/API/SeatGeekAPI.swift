//
//  SeatGeekAPI.swift
//  HomeAway
//
//  Created by YIN CHAO LIAO on 12/21/18.
//  Copyright © 2018 CHAO LIAO. All rights reserved.
//

import Foundation

protocol NetworkSessionDataTask {
    func cancel()
}

protocol NetworkSession {
    func loadData(from url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkSessionDataTask
}

extension URLSession: NetworkSession {
    func loadData(from url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkSessionDataTask {
        let task = dataTask(with: url) { (data, response, error) in
            completionHandler(data, response, error)
        }
        task.resume()
        return task
    }
}

extension URLSessionDataTask: NetworkSessionDataTask {}

class SeatGeekAPI {
    
    enum SearchRequestError: Error {
        case invalidQuery(String)
        case unsuccessfulResponse(Int?)
        case invalidDataReturned
    }
    
    private let networkSession: NetworkSession
    private var networkSessionDataTask: NetworkSessionDataTask?
    
    private let clientId = "MTQ1MzA0OTl8MTU0NTQyNzI2OC41NQ"
    
    init(networkSession: NetworkSession = URLSession.shared) {
        self.networkSession = networkSession
    }
    
    func search(with searchKey: String, favoritedEventIds: [Int] = [], completion: @escaping (_ error: Error?, _ events: [Event]) -> Void) {
        networkSessionDataTask?.cancel()
        
        guard let url = searchUrl(with: searchKey) else {
            completion(SearchRequestError.invalidQuery(searchKey), [])
            return
        }
        
        networkSessionDataTask = networkSession.loadData(from: url) { [weak self] (data, response, error) in
            defer { self?.networkSessionDataTask = nil }
            if let error = error {
                completion(error, [])
                return
            }
            
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                completion(SearchRequestError.unsuccessfulResponse(statusCode), [])
                return
            }
            
            guard let data = data else {
                completion(SearchRequestError.invalidDataReturned, [])
                return
            }
            
            do {
                var newEvents = try JSONDecoder().decode(EventContainer.self, from: data).events
                let favoritedEventIds = Set(favoritedEventIds)
                for index in 0..<newEvents.count {
                    if favoritedEventIds.contains(newEvents[index].id) {
                        newEvents[index].isFavorited = true
                    }
                }
                completion(nil, newEvents)
            } catch let error {
                completion(error, [])
            }
        }
    }
    
    private func searchUrl(with searchKey: String) -> URL? {
        let searchKey = searchKey.replacingOccurrences(of: " ", with: "+")
        if let url = URL(string: "https://api.seatgeek.com/2/events?client_id=\(clientId)&q=\(searchKey)") {
            return url
        }
        return nil
    }
}
