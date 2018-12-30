//
//  EventDetailViewController.swift
//  HomeAway
//
//  Created by YIN CHAO LIAO on 12/23/18.
//  Copyright © 2018 CHAO LIAO. All rights reserved.
//

import UIKit

let iconTransparencyAlph: CGFloat = 0.3

protocol EventDetailViewControllerDelegate: class {
    func eventDetailViewController(_ viewController: EventDetailViewController, didToggleFavoriteWithEventId evnetId: Int)
}

class EventDetailViewController: UIViewController {
    
    private let eventTitle: UILabel = {
        let label = UILabel()
        label.font = Styling.largeTitleFont
        label.numberOfLines = 0
        return label
    }()
    
    private let favIcon: UIImageView = {
        let view = UIImageView(image: UIImage(named: "icon-heart-48"))
        view.contentMode = UIView.ContentMode.scaleAspectFit
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let titleView = UIView()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let imageView: UIImageView = {
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
    
    private let dateTime: UILabel = {
        let label = UILabel()
        label.font = Styling.titleFont
        return label
    }()
    
    private let location: UILabel = {
        let label = UILabel()
        label.textColor = Styling.textColor
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = UIColor.lightGray
        return view
    }()
    
    private let viewModel: EventCellViewModel
    
    weak var delegate: EventDetailViewControllerDelegate?
    
    init(viewModel: EventCellViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        self.eventTitle.text = viewModel.title
        self.dateTime.text = viewModel.dateTime
        self.location.text = viewModel.location
        self.favIcon.alpha = viewModel.isFavorited ? 1 : iconTransparencyAlph
        
        /*
           The previous view in the nav stack (search view) has the search bar inside the nav bar,
           which expands the nav bar to be taller than the nav bar on the detail view.
           Whem pushing on the detail view, the detail view is smaller than the search view and
           that difference creates a gap between the nav and the view.
         */
        extendedLayoutIncludesOpaqueBars = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        titleView.addSubview(eventTitle)
        titleView.addSubview(favIcon)
        view.addSubview(titleView)
        view.addSubview(divider)
        view.addSubview(imageView)
        view.addSubview(imageLoadingIndicator)
        view.addSubview(dateTime)
        view.addSubview(location)
        installConstraints()
        
        viewModel.loadImage() { [weak self] (image) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
                self.imageLoadingIndicator.stopAnimating()
            }
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleIconTap(_:)))
        favIcon.addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func installConstraints() {
        Layout.disableAutoresizingMaskConstrains(views: [
            titleView, eventTitle, favIcon, divider, imageView, imageLoadingIndicator, dateTime, location
        ])
        
        let views = [
            "titleView": titleView,
            "imageView": imageView,
            "divider": divider,
            "eventTitle": eventTitle,
            "location": location,
            "dateTime": dateTime,
            "favIcon": favIcon
        ]
        
        let metrics = [
            "topMargin": UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.height)!,
            "spacing": 20,
            "dividerHeight": 0.8,
            "iconDimension": 30
        ]
        
        let constraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-spacing-[titleView]-spacing-|", options: [], metrics: metrics, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[eventTitle]->=spacing-[favIcon(iconDimension)]|", options: [], metrics: metrics, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-spacing-[divider]-spacing-|", options: [], metrics: metrics, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-spacing-[dateTime]-spacing-|", options: [], metrics: metrics, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-spacing-[location]-spacing-|", options: [], metrics: metrics, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[eventTitle]|", options: [], metrics: metrics, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[favIcon(iconDimension)]", options: [], metrics: metrics, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-topMargin-[titleView]-spacing-[divider(dividerHeight)]-spacing-[imageView]-spacing-[dateTime]-spacing-[location]", options: [], metrics: metrics, views: views),
            [imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)],
            [imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)],
            [imageLoadingIndicator.widthAnchor.constraint(equalToConstant: 100)],
            [imageLoadingIndicator.heightAnchor.constraint(equalToConstant: 100)],
            [imageLoadingIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor)],
            [imageLoadingIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)]
        ].flatMap { $0 }
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func handleIconTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        if view.alpha == 1 {
            view.alpha = iconTransparencyAlph
        } else {
            view.alpha = 1
        }
        delegate?.eventDetailViewController(self, didToggleFavoriteWithEventId: viewModel.id)
    }
}
