//
//  ProfileViewController.swift
//  MyiOSMesserger
//
//  Created by Md. Asiuzzaman on 29/1/23.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class ProfileViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    let data = ["Log out"]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
}
extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let actionSheet = UIAlertController(title: "" , message: "", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "LogOut", style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            FBSDKLoginKit.LoginManager().logOut()
            strongSelf.signOutAction()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet,animated: true)
    }
    
    func signOutAction() {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav,animated: true)
        }
        catch{
            print("Failed to log out")
        }
    }
    
    
}
