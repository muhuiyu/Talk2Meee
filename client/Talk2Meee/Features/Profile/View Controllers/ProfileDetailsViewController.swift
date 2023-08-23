//
//  ProfileDetailsViewController.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/22/23.
//

import UIKit
import JGProgressHUD

class ProfileDetailsViewController: BaseViewController {
    private let spinner = JGProgressHUD(style: .dark)
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private var selectedImage: UIImage?
    
    private let sectionHeader: [String?] = [nil, "Name", "Email"]
    private let photoCell = ProfileDetailsPhotoCell()
    private let nameCell = ProfileDetailsTextFieldCell()
    private let emailCell = ProfileDetailsTextFieldCell()
    private lazy var cells: [[UITableViewCell]] = [ [photoCell], [nameCell], [emailCell] ]
    

    private let viewModel: ProfileDetailsViewModel
    
    override init(appCoordinator: AppCoordinator? = nil) {
        self.viewModel = ProfileDetailsViewModel(appCoordinator: appCoordinator)
        super.init(appCoordinator: appCoordinator)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCells()
        configureViews()
        configureConstraints()
    }
}

// MARK: - View Config
extension ProfileDetailsViewController {
    @objc
    private func didTapInView() {
        dismissKeyboard()
    }
    private func configureViews() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: UIAction(handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .save, primaryAction: UIAction(handler: { [weak self] _ in
            self?.updateData()
            self?.navigationController?.popViewController(animated: true)
        }))
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.register(ProfileDetailsPhotoCell.self, forCellReuseIdentifier: ProfileDetailsPhotoCell.reuseID)
        tableView.register(ProfileDetailsTextFieldCell.self, forCellReuseIdentifier: ProfileDetailsTextFieldCell.reuseID)
        view.addSubview(tableView)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapInView))
        view.addGestureRecognizer(tapRecognizer)
    }
    private func configureConstraints() {
        tableView.snp.remakeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    private func configureCells() {
        guard let user = UserManager.shared.getChatUser() else { return }
        photoCell.photoURL = user.photoURL
        photoCell.tapAvatarHandler = { [weak self] in
            // push bigger image
        }
        photoCell.tapEditButtonHandler = { [weak self] in
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            // Camera
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            })
            actionSheet.addAction(cameraAction)
            // PhotoLibrary
            let photoLibraryAction = UIAlertAction(title: "Photo & Video Library", style: .default, handler: { [weak self] _ in
                self?.presentImagePicker(sourceType: .photoLibrary)
            })
            actionSheet.addAction(photoLibraryAction)
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self?.present(actionSheet, animated: true)
        }
        nameCell.text = user.name
        emailCell.text = user.email
        emailCell.allowEditing = false
    }
    private func updateData() {
        guard let user = UserManager.shared.getChatUser() else { return }
        Task {
            spinner.show(in: view)
            let newUser = ChatUser(id: user.id, name: nameCell.text ?? user.name, email: user.email, photoURL: user.photoURL, stickerPacks: user.stickerPacks)
            await DatabaseManager.shared.updateCurrentUserData(to: newUser, imageData: selectedImage?.pngData())
            spinner.dismiss()
        }
    }
}
// MARK: - TableView DataSource and Delegate
extension ProfileDetailsViewController: UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return cells.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeader[section]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.section][indexPath.row]
    }
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = image
            DispatchQueue.main.async { [weak self] in
                // reload header
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
        }
    }
}
