//
//  EntryController.swift
//  CloudKitJournal
//
//  Created by DevMountain on 9/17/18.
//  Copyright © 2018 trevorAdcock. All rights reserved.
//

import Foundation
import CloudKit

class EntryController{
    
    static let shared = EntryController()
    private init() {}
    
    var entries = [Entry]()
    
    func save(entry: Entry, completion: @escaping (Bool) -> ()){
        
        let entryRecord = CKRecord(entry: entry)
        CKContainer.default().privateCloudDatabase.save(<#T##record: CKRecord##CKRecord#>, completionHandler: <#T##(CKRecord?, Error?) -> Void#>)
        CKContainer.default().privateCloudDatabase.save(entryRecord) { (record, error) in
            
            if let error = error {
                print("💩  There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)  💩")
                completion(false)
                return
            }
            
            guard let record = record, let entry = Entry(ckRecord: record) else {completion(false) ; return}
            self.entries.append(entry)
            completion(true)
        }
        
    }
}

