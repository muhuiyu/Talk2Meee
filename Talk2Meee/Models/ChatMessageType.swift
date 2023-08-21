//
//  ChatMessageType.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

enum ChatMessageType: String {
    case text
    case image
    case sticker
    case location
    
    var hasBackground: Bool {
        switch self {
        case .text:
            return true
        case .image:
            return false
        case .sticker:
            return false
        case .location:
            return true
        }
    }
}
