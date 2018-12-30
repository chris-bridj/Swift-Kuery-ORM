import XCTest

@testable import SwiftKueryORM
import Foundation
import KituraContracts

class TestSaveWithBinaryColumn: XCTestCase {
    static var allTests: [(String, (TestSaveWithBinaryColumn) -> () throws -> Void)] {
        return [
            ("testSave", testSave),
            ("testSave", testSaveWithId),
        ]
    }

    struct PersonWithBinaryColumn: Model {
        static var tableName = "PeopleWithBinaryColumn"
        var name: String
        var binary: BinaryEncodableData
    }
    /**
      Testing that the correct SQL Query is created to save a Model
    */
    func testSave() {
        let connection: TestConnection = createConnection()
        Database.default = Database(single: connection)
        performTest(asyncTasks: { expectation in
            let person = PersonWithBinaryColumn(name: "Joe", binary: BinaryEncodableData(SQLBinary: Data(count: 64)))
            person.save { p, error in
                XCTAssertNil(error, "Save Failed: \(String(describing: error))")
                XCTAssertNotNil(connection.query, "Save Failed: Query is nil")
                if let query = connection.query {
                  let expectedPrefix = "INSERT INTO \"PeopleWithBinaryColumn\""
                  let expectedSQLStatement = "VALUES"
                  let expectedDictionary = ["\"name\"": "?1,?2", "\"binary\"": "?1,?2"]

                  let resultQuery = connection.descriptionOf(query: query)
                  XCTAssertTrue(resultQuery.hasPrefix(expectedPrefix))
                  XCTAssertTrue(resultQuery.contains(expectedSQLStatement))
                  verifyColumnsAndValues(resultQuery: resultQuery, expectedDictionary: expectedDictionary)
                }
                XCTAssertNotNil(p, "Save Failed: No model returned")
                if let p = p {
                    XCTAssertEqual(p.name, person.name, "Save Failed: \(String(describing: p.name)) is not equal to \(String(describing: person.name))")
                    XCTAssertEqual(p.binary.wrapped, person.binary.wrapped, "Save Failed: \(String(describing: p.binary.wrapped)) is not equal to \(String(describing: person.binary.wrapped))")
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
            let person = PersonWithBinaryColumn(name: "Joe", binary: BinaryEncodableData(SQLBinary: Data(count: 32)))
            person.save { (id: Int?, p: PersonWithBinaryColumn?, error: RequestError?) in
                XCTAssertNil(error, "Save Failed: \(String(describing: error))")
                XCTAssertNotNil(connection.query, "Save Failed: Query is nil")
                if let query = connection.query {
                  let expectedPrefix = "INSERT INTO \"PeopleWithBinaryColumn\""
                  let expectedSQLStatement = "VALUES"
                  let expectedDictionary = ["\"name\"": "?1,?2", "\"binary\"": "?1,?2"]

                  let resultQuery = connection.descriptionOf(query: query)
                  XCTAssertTrue(resultQuery.hasPrefix(expectedPrefix))
                  XCTAssertTrue(resultQuery.contains(expectedSQLStatement))
                  verifyColumnsAndValues(resultQuery: resultQuery, expectedDictionary: expectedDictionary)
                }
                XCTAssertNotNil(p, "Save Failed: No model returned")
                XCTAssertEqual(id, 1, "Save Failed: \(String(describing: id)) is not equal to 1)")
                if let p = p {
                    XCTAssertEqual(p.name, person.name, "Save Failed: \(String(describing: p.name)) is not equal to \(String(describing: person.name))")
                    XCTAssertEqual(p.binary.wrapped, person.binary.wrapped, "Save Failed: \(String(describing: p.binary.wrapped)) is not equal to \(String(describing: person.binary.wrapped))")
                }
                expectation.fulfill()
            }
        })
    }
}
