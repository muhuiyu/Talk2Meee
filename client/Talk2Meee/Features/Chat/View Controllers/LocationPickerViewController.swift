//
//  LocationPickerViewController.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/20/23.
//

import UIKit
import CoreLocation
import MapKit

protocol LocationPickerViewControllerDelegate: AnyObject {
    func locationPickerViewControllerDidSelectLocation(_ viewController: LocationPickerViewController, location: CLLocationCoordinate2D)
}

class LocationPickerViewController: BaseViewController {
    
    private let mapView = MKMapView()
    private var coordinates: CLLocationCoordinate2D?
    private let isEditable: Bool
    
    weak var delegate: LocationPickerViewControllerDelegate?
    
    init(appCoordinator: AppCoordinator? = nil, coordinates: CLLocationCoordinate2D? = nil, isEditable: Bool = true) {
        self.coordinates = coordinates
        self.isEditable = isEditable
        super.init(appCoordinator: appCoordinator)
        
        if let coordinates = coordinates {
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            mapView.addAnnotation(pin)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
    }
}

// MARK: - Handlers
extension LocationPickerViewController {
    @objc
    private func didTapSend() {
        guard let coordinates = coordinates else { return }
        delegate?.locationPickerViewControllerDidSelectLocation(self, location: coordinates)
        navigationController?.popViewController(animated: true)
    }
    @objc
    private func didTapMap(_ sender: UITapGestureRecognizer) {
        if !isEditable { return }
        
        let locationInView = sender.location(in: mapView)
        let coordinates = mapView.convert(locationInView, toCoordinateFrom: mapView)
        self.coordinates = coordinates
        
        // remove previous annotation
        mapView.annotations.forEach({ mapView.removeAnnotation($0) })
        
        // drop a pin on that location
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
    }
}

// MARK: - View Config
extension LocationPickerViewController {
    private func configureViews() {
        title = isEditable ? "Pick Location" : "Location"
        if isEditable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(didTapSend))
        }
        mapView.isUserInteractionEnabled = true
        view.addSubview(mapView)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMap(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
    private func configureConstraints() {
        mapView.snp.remakeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

