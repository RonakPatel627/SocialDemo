//
//  ProfileViewController.swift
//  SocialDemo
//
//  Created by STL on 01/01/24.
//

import UIKit
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var btnGoogleSignOut: UIButton!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    var profileViewModel: ProfileViewModel!
    var userEmail: String?
    var userName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        if var email = userEmail, var name = userName {
        //            print("User details in ProfileViewController: Email: \(email), Name: \(name)")
        //
        //            lblEmail.text = email
        //            lblUsername.text = userName
        //
        //        }
        if let user = profileViewModel?.user {
            if let email = user.email {
                lblEmail.text = email
            }
            if let name = user.name {
                lblUsername.text = name
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnGoogleSignOutDidTap(_ sender: Any) {
        GIDSignIn.sharedInstance.signOut()
        if let viewController = navigationController?.viewControllers.first(where: { $0 is ViewController }) {
            navigationController?.popToViewController(viewController, animated: true)
        }
        
    }
    
    @IBAction func btnBackDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
