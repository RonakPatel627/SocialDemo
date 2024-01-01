//
//  ProfileViewModel.swift
//  SocialDemo
//
//  Created by STL on 01/01/24.
//

import Foundation

class ProfileViewModel {
    var user: User?

    init(userEmail: String?, userName: String?) {
        user = User(email: userEmail, name: userName)
    }
}
