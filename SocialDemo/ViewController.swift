//
//  ViewController.swift
//  SocialDemo
//
//  Created by STL on 29/12/23.
//

import UIKit
import GoogleSignIn

class ViewController: UIViewController {
    
    
    @IBOutlet weak var btnGoogleSignIn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateUIBasedOnSignInStatus()
        
    }
    
    func updateUIBasedOnSignInStatus() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            updateUIForSignedInState()
        } else {
            print("Nothing")
        }
    }
    
    @IBAction func btnGoogleSingInDidTap(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            self.handleSignInResult(signInResult, error: error)
        }
    }
    
    @IBAction func btnGoogleSignOutDidTap(_ sender: Any) {
        GIDSignIn.sharedInstance.signOut()
        
    }
}

extension ViewController {
    func handleSignInResult(_ signInResult: GIDSignInResult?, error: Error?) {
        guard error == nil else {
            print("Google Sign-In error: \(error!.localizedDescription)")
            return
        }
        
        // If sign-in succeeded, update UI and handle user details
        guard let signInResult = signInResult else { return }
        let user = signInResult.user
        
        let emailAddress = user.profile?.email
        let fullName = user.profile?.name
        let familyName = user.profile?.familyName
        let profilePicUrl = user.profile?.imageURL(withDimension: 320)
        
        print("user details>>>>>>", "Hi \(fullName ?? "")")
        
        // Update UI for signed-in state
        updateUIForSignedInState()
    }
    
//    func updateUIForSignedInState() {
//        
//        let VC = self.storyboard!.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
//        if let user = GIDSignIn.sharedInstance.currentUser {
//               VC.userEmail = user.profile?.email
//               VC.userName = user.profile?.name
//           }
//        self.navigationController?.pushViewController(VC, animated: true)
//    }
    
    func updateUIForSignedInState() {
           if let user = GIDSignIn.sharedInstance.currentUser {
               let homeViewModel = HomeViewModel()
               homeViewModel.user = User(email: user.profile?.email, name: user.profile?.name)

               let VC = self.storyboard!.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
               VC.homeViewModel = homeViewModel

               self.navigationController?.pushViewController(VC, animated: true)
           }
       }
    
}


