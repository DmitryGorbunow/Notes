//
//  SceneDelegate.swift
//  Notes
//
//  Created by Dmitry Gorbunow on 12/23/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let notesViewController = ListNotesViewController()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            guard let windowScene = (scene as? UIWindowScene) else { return }
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UINavigationController(rootViewController: notesViewController)
            window.makeKeyAndVisible()
            self.window = window
     
        }

}

