//
//  Entry.swift
//  CloudKitJournal
//
//  Created by DevMountain on 9/17/18.
//  Copyright © 2018 trevorAdcock. All rights reserved.
//

import Foundation
import CloudKit

fileprivate struct Constants{
    
    static let recordKey = "Entry"
    static let titleKey = "Title"
    static let bodyKey = "Body"
}

class Entry{
    
    var title: String
    var body: String
    var ckRecordID: CKRecord.ID
    
    init(title: String, body: String, ckRecordID: CKRecord.ID){
        self.title = title
        self.body = body
        self.ckRecordID = ckRecordID
    }
    
    convenience init?(ckRecord: CKRecord){
        
        guard let title = ckRecord[Constants.titleKey] as? String,
            let body = ckRecord[Constants.bodyKey] as? String else {return nil}
        
        self.init(title: title, body: body, ckRecordID: ckRecord.recordID)
    
    }
    
}

extension CKRecord{
    
    convenience init(entry: Entry){
        
        self.init(recordType: Constants.recordKey, recordID: entry.ckRecordID)
        
        self.setValue(entry.title, forKey: Constants.titleKey)
        self.setValue(entry.body, forKey: Constants.bodyKey)
        
    }
}
