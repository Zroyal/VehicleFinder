//
//  LoadingView.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import UIKit

class LoadingView: UIView {
    private var stackView: UIStackView?
    private var activityIndicator: UIActivityIndicatorView?
    private var label: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    private func setupView() {
        isHidden = true
        backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        layer.cornerRadius = 16.0
        layer.masksToBounds = true
        
        stackView = UIStackView()
        stackView?.axis = NSLayoutConstraint.Axis.vertical
        stackView?.distribution = UIStackView.Distribution.equalSpacing
        stackView?.alignment = UIStackView.Alignment.center
        stackView?.spacing = 16.0

        activityIndicator = UIActivityIndicatorView(style: .large)
        stackView?.addArrangedSubview(activityIndicator!)
        
        label = UILabel(frame: .zero)
        label?.text = StringConstatns.fetchingData
        label?.numberOfLines = 0
        label?.textColor = .darkGray
        label?.textAlignment = .center
        label?.font = UIFont.systemFont(ofSize: 14.0)
        stackView?.addArrangedSubview(label!)


        stackView?.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView!)

        stackView?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    
    func showLoading() {
        isHidden = false
        activityIndicator?.startAnimating()
    }
    
    func hideLoading() {
        isHidden = true
        activityIndicator?.stopAnimating()
    }
}
