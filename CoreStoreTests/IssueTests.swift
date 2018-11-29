//
//  IssueTests
//  CoreStore
//
//  Created by Eugene Kalinin on 27/11/2018.
//  Copyright © 2018 John Rommel Estropia. All rights reserved.
//


import XCTest

@testable
import CoreStore

class Account: NSManagedObject {
    @NSManaged var accountType: String?
    @NSManaged var name: String?
    @NSManaged var friends: Int32
}

class AccountDO : CoreStoreObject
{
    let name = Value.Required<String>("name", initial: "")
}

// https://github.com/JohnEstropia/CoreStore/issues/290
final class IssueTests: BaseTestCase {
    
    
    @objc
    dynamic func test_issue290_isFixed() {
        let dataStack = DataStack(xcodeModelName: "Model",
                                 bundle: Bundle(for: type(of: self)))
        try! dataStack.addStorageAndWait(
            SQLiteStore(
                fileName: "storage.sqlite",
                configuration: "AccountConf",
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        )
        
        _ = try! dataStack.perform(synchronous: { (transaction) -> Bool in
            let account = transaction.create(Into<Account>())
            account.name = "Eugene"
            account.friends = 1
            
            let account1 = transaction.create(Into<Account>())
            account1.name = "Eugene 2"
            account1.friends = 2
            return transaction.hasChanges
        })
        
        XCTAssertNotNil(dataStack)
        
        let accounts = dataStack.fetchAll(From<Account>("AccountConf").where(\.friends == 1))!
        XCTAssertFalse(accounts.isEmpty)
        XCTAssertEqual(accounts.count, 1)
    }
    
    
    @objc
    dynamic func test_default_or_nil_configuration_sample() {

        //*
        // [nil] vs ["Default"] ??
        
        let dataStack = prepareStack("Model", configurations: [nil], { stack in
            return stack
        })
        // */
        /*
        let dataStack = DataStack(xcodeModelName: "DefaultOnly",
                                  bundle: Bundle(for: type(of: self)))
 
        try! dataStack.addStorageAndWait(
            SQLiteStore(
                fileName: "storage1.sqlite",
                configuration: "Default",
                //configuration: nil,   // must be nil if has only one configuration??
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        )
        // */
        
        _ = try! dataStack.perform(synchronous: { (transaction) -> Bool in
            let accounts = dataStack.fetchAll(From<OtherAccount>()) // NOTE: Account is from another db
            XCTAssertNotNil(accounts)
            XCTAssertTrue(accounts!.isEmpty)
            return transaction.hasChanges
        })
       
    }
    
}
