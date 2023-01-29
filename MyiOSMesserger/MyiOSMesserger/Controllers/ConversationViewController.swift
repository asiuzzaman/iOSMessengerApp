//
//  ViewController.swift
//  MyiOSMesserger
//
//  Created by Md. Asiuzzaman on 29/1/23.
//

import UIKit

class ConversationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")
        if !isLoggedIn {
            let loginViewController = LoginViewController()
            let navigationViewController = UINavigationController(rootViewController: loginViewController)
            navigationViewController.modalPresentationStyle = .fullScreen
            present(navigationViewController,animated: false)
        }
    }

}

