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
                    self?.showError(error: self?.viewModel.error, retryable: true, completion: {
                        self?.viewModel.fetchScooters()
                    })
                    
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
                    self?.isWaitingForClosest = false
                    self?.loadingView.hideLoading()
                    self?.showAnnotationInfo(
                        annotation: self?.viewModel.closestVehicle,
                        distance: self?.viewModel.calculateClosestDisance())
                }
            })
            .store(in: &bindings)
        
        viewModel.$closestVehicleFindingError
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                if self?.isWaitingForClosest ?? false {
                    self?.isWaitingForClosest = false
                    self?.loadingView.hideLoading()
                    self?.showError(error: self?.viewModel.closestVehicleFindingError)
                }
            })
            .store(in: &bindings)
        
    }
    
    
    // MARK: - Actions
    @objc func showClosestVehicleInformation() {
        if viewModel.annotations.count == 0 || isWaitingForClosest {
            return
        }
        
        if viewModel.closestVehicle != nil {
            showAnnotationInfo(
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
    
    private func showError(
        error: GeneralError?,
        retryable: Bool = false,
        completion: (() -> Void)? = nil) {
        
            let title = StringConstatns.generalErrorTitle
            let massage = error?.localizedDescription ?? StringConstatns.generalError
            let buttonTitle = retryable ? StringConstatns.retry : StringConstatns.okay
            
            showError(
                title: title,
                message: massage,
                buttonTitle: buttonTitle,
                completion: completion)
        }
    
    private func showError(
        title: String?,
        message: String,
        buttonTitle: String,
        completion: (() -> Void)? ) {
            
            let alertController = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert)
            
            let alertAction = UIAlertAction(
                title: buttonTitle,
                style: .default) {  _ in
                    completion?()
                }
            
            alertController.addAction(alertAction)
            
            present(alertController, animated: true, completion: nil)
        }
    
    
    private func showAnnotationInfo(annotation: VehicleAnnotation?, distance: Double? = nil) {
        guard let annotation = annotation else {
            return
        }

        let info = viewModel.getAlertInfo(annotation: annotation, distance: distance)
        
        if info.0.count == 0 {
            return
        }
                    
        let alert = UIAlertController(
            title: info.0,
            message: info.1,
            preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: StringConstatns.okay, style: .cancel)
        alert.addAction(cancel)
        
        
        let openInMaps = UIAlertAction(title: StringConstatns.openInMaps, style: .default) { action in
            let launchOptions = [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
            annotation.mapItem?.openInMaps(launchOptions: launchOptions)
        }
        alert.addAction(openInMaps)

        present(alert, animated: true)
    }
    
}


extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let vehicleAnnotation = view.annotation as? VehicleAnnotation else {
            return
        }
        
        showAnnotationInfo(annotation: vehicleAnnotation)
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


