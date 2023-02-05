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
    
    public func test () {
        database.child("Foo").setValue(["Something": true])
        
    }
}
