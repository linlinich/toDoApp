//
//  LoadingView.swift
//  ToDoListProject
//
//  Created by Ангелина Решетникова on 11.07.2023.
//

import Foundation
import UIKit

class LoadingView: UIView {

    private var loadingActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.color = UIColor(asset: Asset.Colors.separator)
        indicator.startAnimating()
        indicator.autoresizingMask = [
            .flexibleLeftMargin, .flexibleRightMargin,
            .flexibleTopMargin, .flexibleBottomMargin
        ]
        return indicator
    }()

    private let backgroungView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(asset: Asset.Colors.backPrimary)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func setupSubviews() {
        addSubview(backgroungView)
        backgroungView.addSubview(loadingActivityIndicator)

        loadingActivityIndicator.center = CGPoint(
            x: backgroungView.bounds.midX,
            y: backgroungView.bounds.midY
        )
        
        
        NSLayoutConstraint.activate([
            backgroungView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroungView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroungView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroungView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
    }
}
