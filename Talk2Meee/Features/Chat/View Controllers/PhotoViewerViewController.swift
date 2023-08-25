//
//  PhotoViewerViewController.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit
import Kingfisher

class PhotoViewerViewController: BaseViewController {

    private let imageView = UIImageView()
    private let url: URL
    
    init(appCoordinator: AppCoordinator? = nil, url: URL) {
        self.url = url
        super.init(appCoordinator: appCoordinator)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureBindings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
    
}

// MARK: - View Config
extension PhotoViewerViewController {
    private func configureViews() {
        let placeholder = UIImage(systemName: Icons.photo)
        imageView.contentMode = .scaleAspectFit
        imageView.kf.setImage(with: url, placeholder: placeholder)
        view.addSubview(imageView)
        
        title = "Photo"
        view.backgroundColor = .black
    }
    private func configureConstraints() {
        
    }
    private func configureBindings() {
        
    }
}

