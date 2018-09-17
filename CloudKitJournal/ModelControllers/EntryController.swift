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
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    func save(entry: Entry, completion: @escaping (Bool) -> ()){
        
        let entryRecord = CKRecord(entry: entry)
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
    
    func addEntryWith(title: String, body: String, completion: @escaping (Bool) -> Void){
        let entry = Entry(title: title, body: body)
        self.save(entry: entry) { (success) in
            if success{
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    func updateEntry(entry: Entry, title: String, body: String, completion: @escaping (Bool) -> Void){
        
        //Update the local entry
        entry.title = title
        entry.body = body
        
        //Update the entry's remote record from cloudKit
        privateDB.fetch(withRecordID: entry.ckRecordID) { (record, error) in
            if let error = error{
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(false)
                return
            }
            
            guard let record = record else {completion(false) ; return}
            
            record[Constants.titleKey] = title
            record[Constants.bodyKey] = body
            
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.queuePriority = .high
            operation.qualityOfService = .userInitiated
            operation.modifyRecordsCompletionBlock = { (records, reordIDs, error) in
                completion(true)
            }
            self.privateDB.add(operation)
        }
    }
    
    func deleteEntry(entry: Entry, completion: @escaping (Bool) -> ()){
        
        //Delete the entry locally
        guard let index = EntryController.shared.entries.index(of: entry) else {return}
        EntryController.shared.entries.remove(at: index)
        
        //Delete the entry from CloudKit
        privateDB.delete(withRecordID: entry.ckRecordID) { (_, error) in
            if let error = error{
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(false)
                return
            }else {
                print("Record Deleted from CloudKit")
                completion(true)
            }
        }
    }
    
    func fetchEntries(completion: @escaping (Bool) -> ()){
        let predicate = NSPredicate(value: true)
        let querry = CKQuery(recordType: Constants.recordKey, predicate: predicate)
        
        privateDB.perform(querry, inZoneWith: nil) { (records, error) in
            if let error = error{
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(false)
                return
            }
            
            guard let records = records else {completion(false) ; return}
            let entries = records.compactMap{ Entry(ckRecord: $0)}
            self.entries = entries
            completion(true)
        }
    }
    
    
}

