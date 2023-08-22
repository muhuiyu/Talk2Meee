//
//  StickerInputView.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/19/23.
//

import UIKit

protocol StickerInputViewDelegate: AnyObject {
    func stickerInputView(_ view: StickerInputView, didSelect stickerID: StickerID, from packID: StickerPackID)
    func stickerInputViewDidTapAddStickerPackButton(_ view: StickerInputView)
}

class StickerInputView: UIInputView {
    private let addStickerPackButton = UIButton(type: .contactAdd)
    private lazy var headerCollectionView = UICollectionView(
           frame: .zero,
           collectionViewLayout: GridCompositionalLayout.generateHeaderLayout()
    )
    private lazy var collectionView = UICollectionView(
           frame: .zero,
           collectionViewLayout: GridCompositionalLayout.generateLayout()
    )
       
    var stickerPacks: [StickerPack] = [] {
        didSet {
            selectedPackIndex = 0
        }
    }
    
    private var selectedPackIndex = 0 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.headerCollectionView.reloadData()
                self?.collectionView.reloadData()
            }
        }
    }
    
    weak var delegate: StickerInputViewDelegate?
    
    override init(frame: CGRect, inputViewStyle: UIInputView.Style) {
        super.init(frame: .zero, inputViewStyle: .default)
        configureViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Handlers
extension StickerInputView {
    @objc
    private func didTapAddStickerPackButton() {
        delegate?.stickerInputViewDidTapAddStickerPackButton(self)
    }
}

// MARK: - View Config
extension StickerInputView {
    private func configureViews() {
        backgroundColor = .white
        
        // Button
        addStickerPackButton.addTarget(self, action: #selector(didTapAddStickerPackButton), for: .touchUpInside)
        addSubview(addStickerPackButton)
        
        // Header
        headerCollectionView.tag = Section.headerTag
        headerCollectionView.dataSource = self
        headerCollectionView.delegate = self
        headerCollectionView.translatesAutoresizingMaskIntoConstraints = false
        headerCollectionView.register(StickerInputViewHeaderCell.self, forCellWithReuseIdentifier: StickerInputViewHeaderCell.reuseID)
        addSubview(headerCollectionView)
        
        // Content
        collectionView.tag = Section.contentTag
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(StickerInputViewContentCell.self, forCellWithReuseIdentifier: StickerInputViewContentCell.reuseID)
        addSubview(collectionView)
    }
    private func configureConstraints() {
        addStickerPackButton.snp.remakeConstraints { make in
            make.leading.equalToSuperview().inset(Constants.Spacing.trivial)
            make.size.equalTo(32)
            make.centerY.equalTo(headerCollectionView)
        }
        headerCollectionView.snp.remakeConstraints { make in
            make.leading.equalTo(addStickerPackButton.snp.trailing)
            make.top.trailing.equalToSuperview()
            make.height.equalTo(48)
        }
        collectionView.snp.remakeConstraints { make in
            make.top.equalTo(headerCollectionView.snp.bottom).offset(Constants.Spacing.trivial)
            make.leading.trailing.bottom.equalToSuperview()
        }
        let screenWidth = UIScreen.main.bounds.width
        snp.remakeConstraints { make in
            make.width.equalTo(screenWidth)
            make.height.equalTo(400)
        }
    }
}

extension StickerInputView: UICollectionViewDataSource, UICollectionViewDelegate {
    struct Section {
        static let headerTag = 1
        static let contentTag = 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case Section.headerTag:
            return stickerPacks.count
        case Section.contentTag:
            if stickerPacks.isEmpty { return 0 }
            return stickerPacks[selectedPackIndex].getStickers().count
        default:
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case Section.headerTag:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerInputViewHeaderCell.reuseID, for: indexPath) as? StickerInputViewHeaderCell else { return UICollectionViewCell() }
            cell.urlString = stickerPacks[indexPath.item].getCoverImageURL()
            return cell
        case Section.contentTag:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerInputViewContentCell.reuseID, for: indexPath) as? StickerInputViewContentCell else { return UICollectionViewCell() }
            cell.urlString = stickerPacks[selectedPackIndex].getStickers()[indexPath.item].getImageURL()
            cell.backgroundColor = .yellow
            cell.layer.cornerRadius = 5
            cell.layer.masksToBounds = true
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case Section.headerTag:
            selectedPackIndex = indexPath.item
            return
        case Section.contentTag:
            let pack = stickerPacks[selectedPackIndex]
            let stickerID = pack.getStickers()[indexPath.item].stickerID
            delegate?.stickerInputView(self, didSelect: stickerID, from: pack.id)
            return
        default:
            return
        }
    }
}

// MARK: - GridCompositionalLayout
enum GridCompositionalLayout {
    static func generateLayout() -> UICollectionViewCompositionalLayout {
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        return UICollectionViewCompositionalLayout(
            sectionProvider: { section, _ in
                return makeSection()
            },
            configuration: config
        )
    }
    
    private static func makeItem() -> NSCollectionLayoutItem {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(0.25),
                heightDimension: .fractionalWidth(0.25)
            )
        )
        item.contentInsets = .init(top: 0, leading: 2, bottom: 2, trailing: 2)
        return item
    }
    
    private static func makeGroup() -> NSCollectionLayoutGroup {
        let group =  NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1/3)
            ),
            subitems: [makeItem()]
        )
        return group
    }
    
    private static func makeSection() -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: makeGroup())
        return section
    }
}

extension GridCompositionalLayout {
    static func generateHeaderLayout() -> UICollectionViewCompositionalLayout {
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        return UICollectionViewCompositionalLayout(
            sectionProvider: { section, _ in
                return makeHeaderSection()
            },
            configuration: config
        )
    }
    
    private static func makeHeaderItem() -> NSCollectionLayoutItem {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
//        item.contentInsets = .init(top: 3, leading: 3, bottom: 3, trailing: 3)
        return item
    }
    
    private static func makeHeaderGroup() -> NSCollectionLayoutGroup {
        let group =  NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1/8),
                heightDimension: .fractionalHeight(1)
            ),
            subitems: [makeHeaderItem()]
        )
        return group
    }
    
    private static func makeHeaderSection() -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: makeHeaderGroup())
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
    
}
