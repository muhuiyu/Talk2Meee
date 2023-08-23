//
//  ManageThemeViewModel.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/23/23.
//

import UIKit
import RxSwift
import RxRelay

class ManageThemeViewModel: Base.ViewModel {
    let themes: BehaviorRelay<[AppTheme]> = BehaviorRelay(value: [])
}

extension ManageThemeViewModel {
    func fetchAppThemes() async {
        let themes = await DatabaseManager.shared.fetchAllAppThemes()
        self.themes.accept(themes)
    }
    func applyAppTheme(at indexPath: IndexPath) {
        Task {
            let theme = themes.value[indexPath.row]
            UserManager.shared.setAppTheme(theme)
        }
    }
}

