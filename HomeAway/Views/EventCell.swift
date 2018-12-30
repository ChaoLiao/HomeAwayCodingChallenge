//
//  EventCell.swift
//  HomeAway
//
//  Created by YIN CHAO LIAO on 12/22/18.
//  Copyright © 2018 CHAO LIAO. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
    static let cellId = "eventCell"
    
    let eventImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = Styling.borderRadius
        view.clipsToBounds = true
        return view
    }()
    
    let imageLoadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .lightGray
        view.startAnimating()
        return view
    }()
    
    let favIcon: UIImageView = {
        let view = UIImageView(image: UIImage(named: "icon-heart-48"))
        view.contentMode = UIView.ContentMode.scaleAspectFit
        view.isHidden = true
        return view
    }()
    
    let title: UILabel = {
        let label = UILabel()
        label.font = Styling.titleFont
        return label
    }()
    
    let location: UILabel = {
        let label = UILabel()
        label.font = Styling.regularFont
        label.textColor = Styling.textColor
        return label
    }()
    
    let dateTime: UILabel = {
        let label = UILabel()
        label.font = Styling.regularFont
        label.textColor = Styling.textColor
        return label
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(eventImageView)
        contentView.addSubview(imageLoadingIndicator)
        contentView.addSubview(favIcon)
        contentView.addSubview(title)
        contentView.addSubview(location)
        contentView.addSubview(dateTime)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        Layout.disableAutoresizingMaskConstrains(views: [
            eventImageView, imageLoadingIndicator, favIcon, title, location, dateTime
        ])
        
        let views = [
            "eventImageView": eventImageView,
            "favIcon": favIcon,
            "title": title,
            "location": location,
            "dateTime": dateTime
        ]

        let metrics = [
            "imageDimension": 70,
            "imageTopSpacing": 18,
            "spacing": 16
        ]

        let constraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-spacing-[eventImageView(imageDimension)]-spacing-[title]-spacing-|", options: [], metrics: metrics, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "H:[eventImageView(imageDimension)]-spacing-[location]-spacing-|", options: [], metrics: metrics, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "H:[eventImageView(imageDimension)]-spacing-[dateTime]-spacing-|", options: [], metrics: metrics, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-imageTopSpacing-[eventImageView(imageDimension)]->=spacing@999-|", options: [], metrics: metrics, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-spacing-[title]-[location]-[dateTime]->=spacing@999-|", options: [], metrics: metrics, views: views),
            [favIcon.leftAnchor.constraint(equalTo: eventImageView.leftAnchor, constant: -12)],
            [favIcon.topAnchor.constraint(equalTo: eventImageView.topAnchor, constant: -12)],
            [favIcon.widthAnchor.constraint(equalToConstant: 30)],
            [favIcon.heightAnchor.constraint(equalToConstant: 30)],
            [imageLoadingIndicator.widthAnchor.constraint(equalTo: eventImageView.widthAnchor)],
            [imageLoadingIndicator.heightAnchor.constraint(equalTo: eventImageView.heightAnchor)],
            [imageLoadingIndicator.centerXAnchor.constraint(equalTo: eventImageView.centerXAnchor)],
            [imageLoadingIndicator.centerYAnchor.constraint(equalTo: eventImageView.centerYAnchor)]
        ].flatMap { $0 }
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(with viewModel: EventCellViewModel) {
        self.title.text = viewModel.title
        self.location.text = viewModel.location
        self.dateTime.text = viewModel.dateTime
        self.favIcon.isHidden = !viewModel.isFavorited
        viewModel.loadImage() { [weak self] (image) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.eventImageView.image = image
                self.imageLoadingIndicator.stopAnimating()
            }
        }
        self.layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadingIndicator.startAnimating()
        eventImageView.image = nil
    }
}
