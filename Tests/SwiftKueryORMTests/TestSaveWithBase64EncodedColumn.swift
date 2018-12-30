import XCTest

@testable import SwiftKueryORM
import Foundation
import KituraContracts

fileprivate let dataBlob1 = "1234567890".data(using: .ascii)!
fileprivate let dataBlob2 = "0987654321".data(using: .ascii)!
fileprivate let dataBlob3 = "nhkqn\0eofejoijflqkjfoidsflsk".data(using: .ascii)!

class TestSaveWithBase64EncodedColumn: XCTestCase {
    static var allTests: [(String, (TestSaveWithBase64EncodedColumn) -> () throws -> Void)] {
        return [
            ("testSave", testSave),
            ("testSave", testSaveWithId),
        ]
    }

    struct PersonWithBase64EncodedColumn: Model {
        static var tableName = "PeopleWithBase64EncodedColumn"
        var name: String
        var encodable: Data
    }
    /**
      Testing that the correct SQL Query is created to save a Model
    */
    func testSave() {
        let connection: TestConnection = createConnection()
        Database.default = Database(single: connection)
        performTest(asyncTasks: { expectation in
            let person = PersonWithBase64EncodedColumn(name: "Joe", encodable: dataBlob1)
            person.save { p, error in
                XCTAssertNil(error, "Save Failed: \(String(describing: error))")
                XCTAssertNotNil(connection.query, "Save Failed: Query is nil")
                if let query = connection.query {
                  let expectedPrefix = "INSERT INTO \"PeopleWithBase64EncodedColumn\""
                  let expectedSQLStatement = "VALUES"
                  let expectedDictionary = ["\"name\"": "?1,?2", "\"encodable\"": "?1,?2"]

                  let resultQuery = connection.descriptionOf(query: query)
                  XCTAssertTrue(resultQuery.hasPrefix(expectedPrefix))
                  XCTAssertTrue(resultQuery.contains(expectedSQLStatement))
                  verifyColumnsAndValues(resultQuery: resultQuery, expectedDictionary: expectedDictionary)

                  XCTAssertNotNil(connection.parameters)
                  let params = connection.parameters!
                  XCTAssertTrue(params.contains(where: { $0 as? String? == "Joe"}))
                  XCTAssertTrue(params.contains(where: { $0 as? String? == dataBlob1.base64EncodedString() }))
                }
                XCTAssertNotNil(p, "Save Failed: No model returned")
                if let p = p {
                    XCTAssertEqual(p.name, person.name, "Save Failed: \(String(describing: p.name)) is not equal to \(String(describing: person.name))")
                    XCTAssertEqual(p.encodable, person.encodable, "Save Failed: \(String(describing: p.encodable)) is not equal to \(String(describing: person.encodable))")
                }
                expectation.fulfill()
            }
        })
    }

    /**
      Testing that the correct SQL Query is created to save a Model
      Testing that an id is correcly returned
    */
    func testSaveWithId() {
        let connection: TestConnection = createConnection(.returnOneRow)
        Database.default = Database(single: connection)
        performTest(asyncTasks: { expectation in
            let person = PersonWithBase64EncodedColumn(name: "Joe", encodable: dataBlob2)
            person.save { (id: Int?, p: PersonWithBase64EncodedColumn?, error: RequestError?) in
                XCTAssertNil(error, "Save Failed: \(String(describing: error))")
                XCTAssertNotNil(connection.query, "Save Failed: Query is nil")
                if let query = connection.query {
                  let expectedPrefix = "INSERT INTO \"PeopleWithBase64EncodedColumn\""
                  let expectedSQLStatement = "VALUES"
                  let expectedDictionary = ["\"name\"": "?1,?2", "\"encodable\"": "?1,?2"]

                  let resultQuery = connection.descriptionOf(query: query)
                  XCTAssertTrue(resultQuery.hasPrefix(expectedPrefix))
                  XCTAssertTrue(resultQuery.contains(expectedSQLStatement))
                  verifyColumnsAndValues(resultQuery: resultQuery, expectedDictionary: expectedDictionary)

                  XCTAssertNotNil(connection.parameters)
                  let params = connection.parameters!
                    XCTAssertTrue(params.contains(where: { $0 as? String? == "Joe"}))
                    XCTAssertTrue(params.contains(where: { $0 as? String? == dataBlob2.base64EncodedString() }))
                }
                XCTAssertNotNil(p, "Save Failed: No model returned")
                XCTAssertEqual(id, 1, "Save Failed: \(String(describing: id)) is not equal to 1)")
                if let p = p {
                    XCTAssertEqual(p.name, person.name, "Save Failed: \(String(describing: p.name)) is not equal to \(String(describing: person.name))")
                    XCTAssertEqual(p.encodable, person.encodable, "Save Failed: \(String(describing: p.encodable)) is not equal to \(String(describing: person.encodable))")
                }
                expectation.fulfill()
            }
        })
    }

}
