//
//  UIStoryBoardExtension.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/22.
//

import UIKit
private struct StoryboardCategory {
    static let main = "Main"
    static let auth = "Auth"
}
extension UIStoryboard {
    static var main: UIStoryboard { return sfStoryboard(name: StoryboardCategory.main) }
    static var auth: UIStoryboard { return sfStoryboard(name: StoryboardCategory.auth) }
    private static func sfStoryboard(name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: nil)
    }
}

