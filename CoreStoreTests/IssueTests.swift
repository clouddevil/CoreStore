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

// https://github.com/JohnEstropia/CoreStore/issues/281
final class IssueTests: BaseTestCase {
    
    func makeStack() -> DataStack {
        return prepareStack(configurations: ["AccountConf"], { stack in
            return stack
        })
    }
    
    @objc
    dynamic func test_issue281_isFixed() {
        
        let _ = {
            let stack = makeStack()
            _ = try! stack.perform(synchronous: { (transaction) -> Bool in
                let account = transaction.create(Into<Account>())
                account.name = "Eugene"
                account.friends = 1
                return transaction.hasChanges
            })
        }()
        
        let dataStack = makeStack()
        XCTAssertNotNil(dataStack)
        
        let accounts = dataStack.fetchAll(From<Account>())!
        print(accounts)
        XCTAssertFalse(accounts.isEmpty)  // ???
        
        let _ = try? dataStack.perform(
            synchronous: { (transaction) in
                
                // Can't fetch dynamic objects
                // How test it?
                //let accounts = transaction.fetchAll(From<AccountDO>())
                //XCTAssertTrue(accounts?.count == 1)
                
                let s = transaction.fetchAll(From<Account>())!
                print(s)
                
                XCTAssertFalse(s.isEmpty)  // ???
            }
        )
    }
    
}
