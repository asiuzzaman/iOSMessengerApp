//
//  LoginViewController.swift
//  MyiOSMesserger
//
//  Created by Md. Asiuzzaman on 29/1/23.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import FirebaseCore

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    
    private let imageView : UIImageView  = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "newLogo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Enter Address..."
        field.backgroundColor = .white
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        return field
    }()
    
    private let passwordField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password"
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        return field
    }()
    
    private let loginButton : UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email", "public_profile"]
        return button
    }()
    
    private let googleLoginButton = GIDSignInButton()
    
    private var loginObserver: NSObjectProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        view.backgroundColor = .white
        
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            strongSelf.navigationController?.dismiss(animated: true)
        })
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        googleLoginButton.addTarget(self, action: #selector(googleLoginButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        facebookLoginButton.delegate = self
        
        // Add subview
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleLoginButton)
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        
        imageView.frame = CGRect(x: (scrollView.width - size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 10,
                                  width: scrollView.width - 60,
                                 height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                  y: emailField.bottom + 10,
                                  width: scrollView.width - 60,
                                 height: 52)
        loginButton.frame = CGRect(x: 30,
                                  y: passwordField.bottom + 10,
                                  width: scrollView.width - 60,
                                 height: 52)
        
        facebookLoginButton.frame = CGRect(x: 30,
                                  y: loginButton.bottom + 10,
                                  width: scrollView.width - 60,
                                 height: 52)
        
        googleLoginButton.frame = CGRect(x: 30,
                                  y: facebookLoginButton.bottom + 10,
                                  width: scrollView.width - 60,
                                 height: 52)
    }
     
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func loginButtonTapped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard
            let email = emailField.text,
            let password = passwordField.text,
            !email.isEmpty,
            !password.isEmpty,
            password.count >= 6
        else {
            print ("Email or password is empty")
            alertUserLoginError()
            return
        }
        
        // Firebase login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] result, error in
            
            guard let self else { return }
            guard let result = result, error == nil else {
                print("Unauthenticated User")
                self.showToast(message: "Check Email or Password", font: .systemFont(ofSize: 12))
                return
            }
            print("Success Login: \(String(describing: result.user.email))")
            self.navigationController?.dismiss(animated: true, completion: nil)
            
        })
    }
    
    @objc private func googleLoginButtonTapped() {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.configuration = config
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self]  user, error in

          if let error = error {
             print("Catch error while signin: \(error)")
            return
          }
            
            guard let email = user?.user.profile else {
                print("Can't fetch email for google signin")
                return
            }
            
            self.insertIntoDatabase(GIDProfile: email)
            
            guard
                let idToken = user?.user.idToken?.tokenString,
                let accessToken = user?.user.accessToken.tokenString else {
                print("Get idToken and access token")
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            authenticateWithFirebase(credential: credential)
            
            self.navigationController?.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    func authenticateWithFirebase(credential: AuthCredential) {
        
        Auth.auth().signIn(with: credential) { authResult, error in
//            if let error = error {
//                let authError = error as NSError
//              if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
//                // The user is a multi-factor user. Second factor challenge is required.
//                let resolver = authError
//                  .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
//                var displayNameString = ""
//                for tmpFactorInfo in resolver.hints {
//                  displayNameString += tmpFactorInfo.displayName ?? ""
//                  displayNameString += " "
//                }
////                self.showTextInputPrompt(
////                  withMessage: "Select factor to sign in\n\(displayNameString)",
////                  completionBlock: { userPressedOK, displayName in
////                    var selectedHint: PhoneMultiFactorInfo?
////                    for tmpFactorInfo in resolver.hints {
////                      if displayName == tmpFactorInfo.displayName {
////                        selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
////                      }
////                    }
////                    PhoneAuthProvider.provider()
////                      .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
////                                         multiFactorSession: resolver
////                                           .session) { verificationID, error in
////                        if error != nil {
////                          print(
////                            "Multi factor start sign in failed. Error: \(error.debugDescription)"
////                          )
////                        } else {
////                          self.showTextInputPrompt(
////                            withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
////                            completionBlock: { userPressedOK, verificationCode in
////                              let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
////                                .credential(withVerificationID: verificationID!,
////                                            verificationCode: verificationCode!)
////                              let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
////                                .assertion(with: credential!)
////                              resolver.resolveSignIn(with: assertion!) { authResult, error in
////                                if error != nil {
////                                  print(
////                                    "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
////                                  )
////                                } else {
////                                  self.navigationController?.popViewController(animated: true)
////                                }
////                              }
////                            }
////                          )
////                        }
////                      }
////                  }
////                )
//              } else {
//                self.showMessagePrompt(error.localizedDescription)
//                return
//              }
//              // ...
//              return
//            }
            // User is signed in
            // ...
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
                
                guard let _  = authResult, error == nil else {
                    if let error = error {
                        print("Error while signin into google : \(error)")
                    }
                    return
                }
                
                print("User finally signin with google with firebase")
                
                NotificationCenter.default.post(name: .didLogInNotification, object: nil)
            })
            print("User finally signin with google")
            
        }
        
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Woops", message: "Please enter all information Correctly", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

extension LoginViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginButtonTapped()
        }
        return true
    }
    
}
extension LoginViewController {
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
extension LoginViewController : LoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        
        guard let token = result?.token?.tokenString else {
            print("User failed to login with facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields" : "email, name"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start(completion: { [weak self]_, result, error in
            
           // guard let strongSelf = self else { return }
            
            guard let result = result as? [String: Any], error == nil else {
                print("Failed to make facebook login request")
                return
            }
            print( "The graph request result is: \(result)")
            
            guard
                let userName = result["name"] as? String,
                let userEmail = result["email"] as? String
            else {
                print("Failed to get email and username")
                return
            }
            
            let nameComponents = userName.components(separatedBy: " ")
            
            guard nameComponents.count == 2 else {
                print("Name is not dual")
                return
            }
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            DatabaseManager.shared.userExists(with: userEmail, completion: { exists in
                
                if !exists {
                    DatabaseManager
                        .shared
                        .insertDatabase(
                            with: ChatAppUser(
                            firstName: firstName,
                            lastName: lastName,
                            emailAddress: userEmail
                        ))
                }
            })
            
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                guard let self else { return }
                
                guard authResult != nil , error == nil else {
                    if (error != nil) {
                        print("Facebook credential failed, MFA needed so Error:  \(String(describing: error))")
                    }
                        return
                }
                
                print ("Successfully logged in user")
                self.navigationController?.dismiss(animated: true, completion: nil)
            } )
            
        })
        
        
    }
    
    
}

extension LoginViewController {
    func insertIntoDatabase(GIDProfile: GIDProfileData) {
        
        DatabaseManager.shared.userExists(with: GIDProfile.email, completion: { exists in
            
            guard
                let firstName = GIDProfile.givenName,
                let lastName = GIDProfile.familyName
            else {
                print("First or last name is nil")
                return
            }
            
            if !exists {
                DatabaseManager
                    .shared
                    .insertDatabase(
                        with: ChatAppUser(
                            firstName: firstName,
                            lastName: lastName,
                            emailAddress: GIDProfile.email
                    ))
            }
        })
    }
}
