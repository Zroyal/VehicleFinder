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
    
    private let viewModel: DefaultMapViewModel
    private var bindings = Set<AnyCancellable>()
    
    lazy private var mapView = MKMapView(frame: .zero)
    lazy private var closestButton = UIButton(frame: .zero)
    lazy private var loadingView = LoadingView(frame: .zero)
    private var isWaitingForClosest = false

    let initialLocation = CLLocation(latitude: 52.556577, longitude: 13.393951)
    
    init(viewModel: DefaultMapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
        setupBindings()
        
        mapView.centerToLocation(initialLocation)
        viewModel.fetchScooters()
    }
    
    private func configView() {
        view.backgroundColor = .white
        
        let subviews = [mapView, closestButton, loadingView]
        
        subviews.forEach {
            self.view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setUpConstraints()
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.delegate = self
        
        closestButton.backgroundColor = .systemBlue
        closestButton.setTitle(StringConstatns.showClosestVehicle, for: .normal)
        closestButton.setTitleColor(.white, for: .normal)
        closestButton.addTarget(self, action: #selector(showClosestVehicleInformation), for: .touchUpInside)
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
            
            loadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            loadingView.heightAnchor.constraint(equalToConstant: 170),
            loadingView.widthAnchor.constraint(equalToConstant: 170)
            
        ])
    }
    
    private func setupBindings() {
        
        viewModel.$status
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] status in
                
                if status == .fail {
                    self?.showError(error: self?.viewModel.error)
                    self?.loadingView.hideLoading()
                    
                } else if status == .fetching {
                    self?.loadingView.showLoading()
                }
                else if status == .success {
                    self?.loadingView.setLoadingMessage(StringConstatns.addingDataToMap)
                }
            })
            .store(in: &bindings)
        
        viewModel.$annotations
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] annotations in
                self?.loadData()
            })
            .store(in: &bindings)
        
        viewModel.$closestVehicle
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                if self?.isWaitingForClosest ?? false {
                    self?.loadingView.hideLoading()
                    self?.showClosestInfo(annotation: self?.viewModel.closestVehicle, distance: self?.viewModel.calculateClosestDisance())
                }
            })
            .store(in: &bindings)

        viewModel.$closestVehicleFindingError
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                if self?.isWaitingForClosest ?? false {
                    self?.loadingView.hideLoading()
                    self?.showError(error: self?.viewModel.closestVehicleFindingError)
                }
            })
            .store(in: &bindings)

    }
    
    
    // MARK: - Actions
    @objc func showClosestVehicleInformation() {
        if viewModel.annotations.count == 0 {
            return
        }
        
        if viewModel.closestVehicle != nil {
            showClosestInfo(
                annotation: viewModel.closestVehicle,
                distance: viewModel.calculateClosestDisance())

        } else {
            isWaitingForClosest = true
            loadingView.setLoadingMessage("Finding closest vehicle")
            loadingView.showLoading()
            viewModel.showClosestVehicle()
        }
    }
    
    
    // MARK: - Internal methods
    
    private func loadData() {
        guard viewModel.annotations.count > 0 else { return }
        mapView.addAnnotations(viewModel.annotations)
        loadingView.hideLoading()
    }
    
    private func showError(error: GeneralError?) {
        let alertController = UIAlertController(
            title: StringConstatns.generalErrorTitle,
            message: error?.localizedDescription ?? StringConstatns.generalError,
            preferredStyle: .alert)
        
        let alertAction = UIAlertAction(
            title: StringConstatns.okay,
            style: .default) {  _ in }
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    private func showVehicleInfo(annotation: VehicleAnnotation) {
        let message = "Type: \(annotation.model?.attributes?.vehicleType ?? "")\nHas Helment Box: \(annotation.model?.attributes?.hasHelmetBox ?? false)\nBattery Level: \(annotation.model?.attributes?.batteryLevel ?? 0)\nMax Speed: \(annotation.model?.attributes?.maxSpeed ?? 0)"
        
        let alert = UIAlertController(title: "\(StringConstatns.SelectedVehicleInformation)\n", message: message, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(cancel)
        
        let showInMap = UIAlertAction(title: "Show in Map", style: .default) { action in
            let launchOptions = [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
            annotation.mapItem?.openInMaps(launchOptions: launchOptions)
        }
        alert.addAction(showInMap)
        
        present(alert, animated: true)
    }
    
    private func showClosestInfo(annotation: VehicleAnnotation?, distance: Double?) {
        let message = "Type: \(annotation?.model?.attributes?.vehicleType ?? "")\nHas Helment Box: \(annotation?.model?.attributes?.hasHelmetBox ?? false)\nBattery Level: \(annotation?.model?.attributes?.batteryLevel ?? 0)\nMax Speed: \(annotation?.model?.attributes?.maxSpeed ?? 0)\nDistance: \(distance ?? 0)"
        
        let alert = UIAlertController(title: "Closest Vehicle Information\n", message: message, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(cancel)
                
        present(alert, animated: true)
    }

}


extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let vehicleAnnotation = view.annotation as? VehicleAnnotation else {
            return
        }
        
        showVehicleInfo(annotation: vehicleAnnotation)
    }
    
    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            if let item = annotation as? VehicleAnnotation {
                
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "VehicleAnnotation")
                ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "VehicleAnnotation")
                
                annotationView.annotation = item
                if item.model?.attributes?.hasHelmetBox ?? false {
                    annotationView.image = UIImage(named: "ScooterHelmetIcon")
                } else {
                    annotationView.image = UIImage(named: "ScooterIcon")
                }
                annotationView.clusteringIdentifier = "VehicleAnnotationClustered"
                
                return annotationView
                
            } else if let cluster = annotation as? MKClusterAnnotation {
                
                let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: "clusterView")
                ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "clusterView")
                
                clusterView.annotation = cluster
                clusterView.image = UIImage(named: "ScootersIcon")
                
                return clusterView
            } else {
                return nil
            }
        }
}


