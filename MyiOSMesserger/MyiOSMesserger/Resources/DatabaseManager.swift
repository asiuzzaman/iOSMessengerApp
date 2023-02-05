//
//  DatabaseManager.swift
//  MyiOSMesserger
//
//  Created by Md. Asiuzzaman on 5/2/23.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
}

extension DatabaseManager {
    
    public func insertDatabase (with user: ChatAppUser) {
        database.child(user.safeEmail).setValue([
            "FirstName": user.firstName,
            "LastName" : user.lastName
        ])
        
    }
    
    public func userExists(with email: String, completion: @escaping ((Bool)-> Void )) {
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
}

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
