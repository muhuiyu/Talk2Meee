//
//  ManageThemeViewController.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/23/23.
//

import UIKit
import RxSwift
import RxRelay
import JGProgressHUD

class ManageThemeViewController: Base.MVVMViewController<ManageThemeViewModel> {
    
    // MARK: - Views
    private let spinner = JGProgressHUD(style: .dark)
    private let layout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private let emptyLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureBindings()
        
        Task {
            self.spinner.show(in: self.view)
            await self.viewModel.fetchAppThemes()
            self.spinner.dismiss()
        }
    }
}

// MARK: - View Config
extension ManageThemeViewController {
    private func configureViews() {
        title = "Theme"
        
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 100, height: 150)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ManageThemeCell.self, forCellWithReuseIdentifier: ManageThemeCell.reuseID)
        view.addSubview(collectionView)
        
        emptyLabel.font = .small
        emptyLabel.textColor = UserManager.shared.getAppTheme().colorSkin.secondaryLabelColor
        emptyLabel.textAlignment = .center
        emptyLabel.text = "No themes"
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)
        
        view.backgroundColor = UserManager.shared.getAppTheme().colorSkin.backgroundColor
    }
    private func configureConstraints() {
        collectionView.snp.remakeConstraints { make in
            make.edges.equalTo(view.layoutMarginsGuide)
        }
        emptyLabel.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    private func configureBindings() {
        viewModel.themes
            .asObservable()
            .subscribe { _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if self.viewModel.themes.value.isEmpty {
                        self.collectionView.isHidden = true
                        self.emptyLabel.isHidden = false
                    } else {
                        self.collectionView.reloadData()
                        self.collectionView.isHidden = false
                        self.emptyLabel.isHidden = true
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - DataSource and Delegate
extension ManageThemeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.themes.value.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ManageThemeCell.reuseID, for: indexPath) as? ManageThemeCell else { return UICollectionViewCell() }
        cell.theme = viewModel.themes.value[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.applyAppTheme(at: indexPath)
    }
}
