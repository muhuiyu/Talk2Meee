//
//  ManageStickerPackViewModel.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/23/23.
//

import UIKit
import RxSwift
import RxRelay

class ManageStickerPackViewModel: Base.ViewModel {
    enum Tab: Int {
        case allPacks = 0
        case myPacks = 1
    }
    private let packs: BehaviorRelay<[StickerPack]> = BehaviorRelay(value: [])
    
    let displayedPacks: BehaviorRelay<[StickerPack]> = BehaviorRelay(value: [])
    
    var currentTab: BehaviorRelay<Tab> = BehaviorRelay(value: .allPacks)
    
    override init(appCoordinator: AppCoordinator? = nil) {
        super.init(appCoordinator: nil)
        configureBindings()
    }
}

extension ManageStickerPackViewModel {
    func fetchStickerPacks() async {
        let packs = await DatabaseManager.shared.fetchAllStickerPacks()
        self.packs.accept(packs)
    }
    func removeStickerPack(for id: StickerPackID) {
        Task {
            guard var user = UserManager.shared.getChatUser() else { return }
            user.stickerPacks.removeAll(where: { $0 == id })
            await DatabaseManager.shared.updateCurrentUserData(to: user)
            self.reconfigurePacks()
        }
    }
    func addStickerPack(for id: StickerPackID) {
        Task {
            guard var user = UserManager.shared.getChatUser() else { return }
            user.stickerPacks.append(id)
            await DatabaseManager.shared.updateCurrentUserData(to: user)
            self.currentTab.accept(.myPacks)
        }
    }
    private func reconfigurePacks() {
        switch currentTab.value {
        case .allPacks:
            displayedPacks.accept(packs.value)
        case .myPacks:
            guard let user = UserManager.shared.getChatUser() else {
                fatalError("Cannot find current user")
            }
            let myPacks = packs.value.filter({ user.stickerPacks.contains($0.id) })
            displayedPacks.accept(myPacks)
        }
    }
    private func configureBindings() {
        currentTab
            .asObservable()
            .subscribe { _ in
                self.reconfigurePacks()
            }
            .disposed(by: disposeBag)
        
        packs
            .asObservable()
            .subscribe { value in
                self.displayedPacks.accept(value)
            }
            .disposed(by: disposeBag)
    }
}
