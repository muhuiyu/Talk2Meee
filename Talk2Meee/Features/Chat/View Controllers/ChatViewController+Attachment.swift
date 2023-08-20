//
//  ChatViewController+Attachment.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/19/23.
//

import UIKit

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, let imageData = image.pngData() else { return }
        
        // TODO: - upload image and send message
//        Task {
//            let result = await StorageManager.shared.uploadMessagePhoto(with: imageData, filename: "")
//            switch result {
//            case .success(let urlString):
//                // TODO: -
//
//            case .failure(let error):
//                print("message photo upload error: \(error)")
//            }
//        }
    }
    internal func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // Camera
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        })
        cameraAction.setValue(UIImage(systemName: Icons.camera), forKey: "image")
        actionSheet.addAction(cameraAction)
        // PhotoLibrary
        let photoLibraryAction = UIAlertAction(title: "Photo & Video Library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
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
            // TODO: -
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
