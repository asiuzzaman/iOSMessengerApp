//
//  ViewController.swift
//  MyiOSMesserger
//
//  Created by Md. Asiuzzaman on 29/1/23.
//

import UIKit
import Firebase

class ConversationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
   private func validateAuth() {
       if FirebaseAuth.Auth.auth().currentUser == nil {
           let vc = LoginViewController()
           let nav = UINavigationController(rootViewController: vc)
           nav.modalPresentationStyle = .fullScreen
           present(nav,animated: true)
       }
    }

}

