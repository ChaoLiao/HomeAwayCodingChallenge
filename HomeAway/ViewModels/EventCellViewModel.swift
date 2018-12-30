//
//  EventCellViewModel.swift
//  HomeAway
//
//  Created by YIN CHAO LIAO on 12/22/18.
//  Copyright © 2018 CHAO LIAO. All rights reserved.
//

import UIKit

class EventCellViewModel {
    
    let id: Int
    let imageUrl: URL?
    let title: String
    let location: String
    let dateTime: String
    
    private var imageDataTask: NetworkSessionDataTask?
    var image: UIImage?
    var isFavorited: Bool
    
    init(eventModel: Event) {
        self.id = eventModel.id
        self.imageUrl = URL(string: eventModel.performers[0].image ?? "")
        self.title = eventModel.title
        self.location = "\(eventModel.venue.city), \(eventModel.venue.state)"
        self.dateTime = EventCellViewModel.formatDate(isoString: eventModel.isoDateLocal)
        self.isFavorited = eventModel.isFavorited
    }
    
    static func formatDate(isoString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let date = dateFormatter.date(from: isoString) else {
            return ""
        }
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:MM a"
        return dateFormatter.string(from: date)
    }
    
    static func viewModelsFromDataModels(_ dataModels: [Event]) -> [EventCellViewModel] {
        var viewModels = [EventCellViewModel]()
        for dataModel in dataModels {
            let viewModel = EventCellViewModel(eventModel: dataModel)
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    func loadImage(networkSession: NetworkSession = URLSession.shared, completionHandler: @escaping (_ image: UIImage?) -> Void) {
        guard let imageUrl = imageUrl else {
            completionHandler(nil)
            return
        }
        if let image = image {
            completionHandler(image)
            return
        }
        imageDataTask?.cancel()
        imageDataTask = networkSession.loadData(from: imageUrl) { [weak self] (data, response, error) in
            guard let `self` = self else { return }
            if let error = error {
                print(error.localizedDescription)
                completionHandler(nil)
                return
            }
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                let data = data,
                let image = UIImage(data: data)
            else {
                completionHandler(nil)
                return
            }
            self.image = image
            completionHandler(image)
        }
    }
}
