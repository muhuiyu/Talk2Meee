//
//  ChatViewController+Attachment.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/19/23.
//

import UIKit
import MessageKit
import MapKit
import CoreLocation
import PhotosUI

// MARK: - UINavigationControllerDelegate
extension ChatViewController: UINavigationControllerDelegate {
    internal func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // Camera
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            self?.presentImagePicker(sourceType: .camera)
        })
        cameraAction.setValue(UIImage(systemName: Icons.camera), forKey: "image")
        actionSheet.addAction(cameraAction)
        // PhotoLibrary
        let photoLibraryAction = UIAlertAction(title: "Photo & Video Library", style: .default, handler: { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        })
        photoLibraryAction.setValue(UIImage(systemName: Icons.photo), forKey: "image")
        actionSheet.addAction(photoLibraryAction)
        // Document
        let documentAction = UIAlertAction(title: "Document", style: .default, handler: { [weak self] _ in
            // TODO: -
        })
        documentAction.setValue(UIImage(systemName: Icons.doc), forKey: "image")
        actionSheet.addAction(documentAction)
        // Location
        let locationAction = UIAlertAction(title: "Location", style: .default, handler: { [weak self] _ in
            self?.presentLocationPicker()
        })
        locationAction.setValue(UIImage(systemName: Icons.mappinAndEllipse), forKey: "image")
        actionSheet.addAction(locationAction)
        // Contact
        let contactAction = UIAlertAction(title: "Contact", style: .default, handler: { [weak self] _ in
            // TODO: -
        })
        contactAction.setValue(UIImage(systemName: Icons.personCropCircle), forKey: "image")
        actionSheet.addAction(contactAction)
        // Cancel
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        switch sourceType {
        case .camera:
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = false
            self.present(picker, animated: true)
        case .photoLibrary:
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 5
            configuration.filter = .images
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true)
        default:
            return
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let imageData = image.pngData() else { return }
        viewModel.sendImageMessage(image, imageData)
    }
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        defer {
            picker.dismiss(animated: true)
        }
        for result in results {
            guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else { continue }
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                if let image = image as? UIImage, let imageData = image.pngData() {
                    self?.viewModel.sendImageMessage(image, imageData)
                }
            }
        }
    }
}

// MARK: - Location
extension ChatViewController: LocationPickerViewControllerDelegate {
    private func presentLocationPicker() {
        let viewController = LocationPickerViewController(appCoordinator: self.appCoordinator)
        viewController.navigationItem.largeTitleDisplayMode = .never
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    func locationPickerViewControllerDidSelectLocation(_ viewController: LocationPickerViewController, location: CLLocationCoordinate2D) {
        viewModel.sendMessage(for: ChatMessageLocationContent(longtitude: location.longitude, latitdue: location.latitude), as: .location)
    }
//    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
//        {
//            view in
//            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
//            UIView.animate(
//              withDuration: 0.6,
//              delay: 0,
//              usingSpringWithDamping: 0.9,
//              initialSpringVelocity: 0,
//              options: [],
//              animations: {
//                view.layer.transform = CATransform3DIdentity
//              },
//              completion: nil)
//        }
//    }
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }
}
