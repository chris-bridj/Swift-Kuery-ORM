import XCTest

@testable import SwiftKueryORM
import Foundation
import KituraContracts

fileprivate let dataBlob1 = "1234567890".data(using: .ascii)!
fileprivate let dataBlob2 = "0987654321".data(using: .ascii)!
fileprivate let dataBlob3 = "nhkqn\0eofejoijflqkjfoidsflsk".data(using: .ascii)!

class TestFindWithBase64EncodedColumn: XCTestCase {
    static var allTests: [(String, (TestFindWithBase64EncodedColumn) -> () throws -> Void)] {
        return [
            ("testFind", testFind),
            ("testFindAll", testFindAll),
            ("testFindAllMatching", testFindAllMatching),
        ]
    }

    struct PersonWithBase64EncodedColumn: Model {
        static var tableName = "PeopleWithBase64EncodedColumn"
        var name: String
        var encodable: Data
    }

    /**
      Testing that the correct SQL Query is created to retrieve a specific model.
      Testing that the model can be retrieved
    */
    func testFind() {
        let connection: TestConnection = createConnection(.returnOneRow, resultFetcherKlass: TestResultFetcherWithBase64EncodedColumn.self)
        Database.default = Database(single: connection)
        performTest(asyncTasks: { expectation in
            PersonWithBase64EncodedColumn.find(id: 1) { p, error in
                XCTAssertNil(error, "Find Failed: \(String(describing: error))")
                XCTAssertNotNil(connection.query, "Find Failed: Query is nil")
                if let query = connection.query {
                  let expectedQuery = "SELECT * FROM \"PeopleWithBase64EncodedColumn\" WHERE \"PeopleWithBase64EncodedColumn\".\"id\" = ?1"
                  let resultQuery = connection.descriptionOf(query: query)
                  XCTAssertEqual(resultQuery, expectedQuery, "Find Failed: Invalid query")
                }
                XCTAssertNotNil(p, "Find Failed: No model returned")
                if let p = p {
                    XCTAssertEqual(p.name, "Joe", "Find Failed: \(String(describing: p.name)) is not equal to Joe")
                    XCTAssertEqual(p.encodable, dataBlob1, "Find Failed: \(String(describing: p.encodable)) is not equal to \(dataBlob1)")
                }
                expectation.fulfill()
            }
        })
    }

    /**
      Testing that the correct SQL Query is created to retrieve all the models.
      Testing that correct amount of models are retrieved
    */
    func testFindAll() {
        let connection: TestConnection = createConnection(.returnThreeRows, resultFetcherKlass: TestResultFetcherWithBase64EncodedColumn.self)
        Database.default = Database(single: connection)
        performTest(asyncTasks: { expectation in
            PersonWithBase64EncodedColumn.findAll { array, error in
                XCTAssertNil(error, "Find Failed: \(String(describing: error))")
                XCTAssertNotNil(connection.query, "Find Failed: Query is nil")
                if let query = connection.query {
                  let expectedQuery = "SELECT * FROM \"PeopleWithBase64EncodedColumn\""
                  let resultQuery = connection.descriptionOf(query: query)
                  XCTAssertEqual(resultQuery, expectedQuery, "Find Failed: Invalid query")
                }
                XCTAssertNotNil(array, "Find Failed: No array of models returned")
                if let array = array {
                  XCTAssertEqual(array.count, 3, "Find Failed: \(String(describing: array.count)) is not equal to 3")
                }
                expectation.fulfill()
            }
        })
    }

    struct Filter: QueryParams {
      let name: String
    }

    /**
      Testing that the correct SQL Query is created to retrieve all the models.
      Testing that correct amount of models are retrieved
    */
    func testFindAllMatching() {
        let connection: TestConnection = createConnection(.returnOneRow, resultFetcherKlass: TestResultFetcherWithBase64EncodedColumn.self)
        Database.default = Database(single: connection)
        let filter = Filter(name: "Joe")
        performTest(asyncTasks: { expectation in
            PersonWithBase64EncodedColumn.findAll(matching: filter) { array, error in
                XCTAssertNil(error, "Find Failed: \(String(describing: error))")
                XCTAssertNotNil(connection.query, "Find Failed: Query is nil")
                if let query = connection.query {
                  let expectedPrefix = "SELECT * FROM \"PeopleWithBase64EncodedColumn\" WHERE"
                  let expectedClauses = [["\"PeopleWithBase64EncodedColumn\".\"name\" = ?1"]]
                  let resultQuery = connection.descriptionOf(query: query)
                  XCTAssertTrue(resultQuery.hasPrefix(expectedPrefix))
                  for whereClauses in expectedClauses {
                    var success = false
                    for whereClause in whereClauses where resultQuery.contains(whereClause) {
                      success = true
                    }
                    XCTAssertTrue(success)
                  }
                }
                XCTAssertNotNil(array, "Find Failed: No array of models returned")
                if let array = array {
                  XCTAssertEqual(array.count, 1, "Find Failed: \(String(describing: array.count)) is not equal to 1")
                  let user = array[0]
                  XCTAssertEqual(user.name, "Joe")
                  XCTAssertEqual(user.encodable, dataBlob1)
                }
                expectation.fulfill()
            }
        })
    }
}

class TestResultFetcherWithBase64EncodedColumn: TestResultFetcher {
    func done() {
        return
    }

    let numberOfRows: Int
    let rows = [
      [1, "Joe", dataBlob1.base64EncodedString()],
      [2, "Adam", dataBlob2.base64EncodedString()],
      [3, "Chris", dataBlob3.base64EncodedString()]
    ]

    let titles = ["id", "name", "encodable"]
    var fetched = 0

    required init(numberOfRows: Int) {
        self.numberOfRows = numberOfRows
    }

    func fetchNext(callback: @escaping (([Any?]?, Error?)) -> ()) {
        DispatchQueue.global().async {
            if self.fetched < self.numberOfRows {
                self.fetched += 1
                return callback((self.rows[self.fetched - 1], nil))
            }
            return callback((nil, nil))
        }
    }

    func fetchTitles(callback: @escaping (([String]?, Error?)) -> ()) {
        callback((titles, nil))
    }
}
