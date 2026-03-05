//
//  SceneDelegate.swift
//  QuietJournal
//
//  Created by Higor  Lo Castro on 05/03/26.
//
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}
