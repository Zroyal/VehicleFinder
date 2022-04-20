//
//  ViewController.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import UIKit
import Combine
import MapKit

class MapVC: UIViewController {

    private let viewModel: MapViewModel
    private var bindings = Set<AnyCancellable>()

    lazy private var mapView = MKMapView(frame: .zero)
    lazy private var closestButton = UIButton(frame: .zero)

    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
    }
    
    private func configView() {
        view.backgroundColor = .white
        
        self.view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(closestButton)
        closestButton.translatesAutoresizingMaskIntoConstraints = false

        setUpConstraints()
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        closestButton.backgroundColor = .systemBlue
        closestButton.setTitle(StringConstatns.showClosestVehicle, for: .normal)
        closestButton.setTitleColor(.white, for: .normal)
    }

    private func setUpConstraints() {
        
        NSLayoutConstraint.activate([
            closestButton.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor,
                constant: 0),
            
            closestButton.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor,
                constant: 0),

            closestButton.bottomAnchor.constraint(
                equalTo: self.view.bottomAnchor,
                constant: 0),

            closestButton.heightAnchor.constraint(
                equalToConstant: 44.0 + UIApplication.getBottomSafeArea()),

            closestButton.topAnchor.constraint(
                equalTo: self.mapView.bottomAnchor,
                constant: 0),

            mapView.topAnchor.constraint(
                equalTo: self.view.topAnchor,
                constant: 0),
            
            mapView.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor,
                constant: 0),
            
            mapView.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor,
                constant: 0),
            
        ])
    }
    

}

