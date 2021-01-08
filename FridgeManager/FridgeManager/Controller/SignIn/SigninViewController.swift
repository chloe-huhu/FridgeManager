//
//  SigninViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/7.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit

class SigninViewController: UIViewController {
    
//    @IBOutlet weak var signInTestLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppleButton()
    }
//    func log(_ message: String) {
//        NSLog("Wayne, \(message)")
//    }
    
    
    func setupAppleButton() {
//        log("setupAppleButton()")
        let appleButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        view.addSubview(appleButton)
        appleButton.cornerRadius = 8
        appleButton.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        appleButton.widthAnchor.constraint(equalToConstant: 350).isActive = true
        appleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        appleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -180).isActive = true
    }
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    @available(iOS 13, *)
    @objc func startSignInWithAppleFlow() {
//        log("startSignInWithAppleFlow()")
        let nonce = randomNonceString()
//        log("nonce=\(nonce)")
        currentNonce = nonce
//        log("currentNonce=\(currentNonce)")
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
//        log("sha256()")
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
//        log("hashString=\(hashString)")
        
        return hashString
        
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        NSLog("randomNonceString")
        precondition(length > 0)
        let charset: Array <Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {

                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
}
@available(iOS 13.0, *)
extension SigninViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        log("authorizationController()")
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            log("if let")
            guard let nonce = currentNonce else {
//                log("Invalid state: A login callback was received, but no login request was sent.")
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
//                log("Unable to fetch identity token")
                NSLog("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//                log("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                NSLog("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            NSLog("credential")
            // 登入
            Auth.auth().signIn(with: credential) { (authResult, error) in
//                self.log("Auth.auth().signIn")
                if error != nil {
//                    self.log("error=\(error?.localizedDescription as Any as? String)")
                    NSLog(error?.localizedDescription as Any as? String ?? "錯誤")
                    return
                } else {
//                    self.log("success")
                    guard let user = authResult?.user else { return }

                    NSLog("新建使用者")
                    
                    UserDefaults.standard.setValue(user.uid, forKey: "userUid")
                    
                    let email = user.email ?? ""
                    let displayName = user.displayName ?? "點左上角更換名稱"
                    
                    guard let uid =  Auth.auth().currentUser?.uid else { return }
                    
                    let doc = Firestore.firestore().collection("users")
                    
                    doc.document(uid).setData([
                        "uid": uid,
                        "photo": "",
                        "displayName": displayName,
                        "email": email,
                        "myFridges": [],
                        "myInvites": []
                        
                    ]) { err in
                        if let err = err {
                            NSLog("Error writing document: \(err)")
                        } else {
                            
                            let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewFriendViewController")
                            
                            viewController.modalPresentationStyle = .fullScreen
                            
                            self.present(viewController, animated: true, completion: nil)
                            
                        }
                        
                    }
                    
                }
                
            }
            NSLog("the user has sign up or is logged in")
        } else {
//            log("if let else")
        }
    }
}

func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    NSLog("Sign in with Apple errored: \(error)")
}


extension SigninViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
