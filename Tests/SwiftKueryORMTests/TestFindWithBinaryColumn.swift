import XCTest

@testable import SwiftKueryORM
import Foundation
import KituraContracts

class TestFindWithBinaryColumn: XCTestCase {
    static var allTests: [(String, (TestFindWithBinaryColumn) -> () throws -> Void)] {
        return [
            ("testFind", testFind),
            ("testFindAll", testFindAll),
            ("testFindAllMatching", testFindAllMatching),
        ]
    }

    struct PersonWithBinaryColumn: Model {
        static var tableName = "PeopleWithBinaryColumn"
        var name: String
        var binary: BinaryEncodableData
    }

    /**
      Testing that the correct SQL Query is created to retrieve a specific model.
      Testing that the model can be retrieved
    */
    func testFind() {
        let connection: TestConnection = createConnection(.returnOneRow, resultFetcherKlass: TestResultFetcherWithBinaryColumn.self)
        Database.default = Database(single: connection)
        performTest(asyncTasks: { expectation in
            PersonWithBinaryColumn.find(id: 1) { p, error in
                XCTAssertNil(error, "Find Failed: \(String(describing: error))")
                XCTAssertNotNil(connection.query, "Find Failed: Query is nil")
                if let query = connection.query {
                  let expectedQuery = "SELECT * FROM \"PeopleWithBinaryColumn\" WHERE \"PeopleWithBinaryColumn\".\"id\" = ?1"
                  let resultQuery = connection.descriptionOf(query: query)
                  XCTAssertEqual(resultQuery, expectedQuery, "Find Failed: Invalid query")
                }
                XCTAssertNotNil(p, "Find Failed: No model returned")
                if let p = p {
                    XCTAssertEqual(p.name, "Joe", "Find Failed: \(String(describing: p.name)) is not equal to Joe")
                    XCTAssertEqual(p.binary.wrapped, Data(count: 38), "Find Failed: \(String(describing: p.binary.wrapped)) is not equal to \(Data(count: 38))")
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
        let connection: TestConnection = createConnection(.returnThreeRows, resultFetcherKlass: TestResultFetcherWithBinaryColumn.self)
        Database.default = Database(single: connection)
        performTest(asyncTasks: { expectation in
            PersonWithBinaryColumn.findAll { array, error in
                XCTAssertNil(error, "Find Failed: \(String(describing: error))")
                XCTAssertNotNil(connection.query, "Find Failed: Query is nil")
                if let query = connection.query {
                  let expectedQuery = "SELECT * FROM \"PeopleWithBinaryColumn\""
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
        let connection: TestConnection = createConnection(.returnOneRow, resultFetcherKlass: TestResultFetcherWithBinaryColumn.self)
        Database.default = Database(single: connection)
        let filter = Filter(name: "Joe")
        performTest(asyncTasks: { expectation in
            PersonWithBinaryColumn.findAll(matching: filter) { array, error in
                XCTAssertNil(error, "Find Failed: \(String(describing: error))")
                XCTAssertNotNil(connection.query, "Find Failed: Query is nil")
                if let query = connection.query {
                  let expectedPrefix = "SELECT * FROM \"PeopleWithBinaryColumn\" WHERE"
                  let expectedClauses = [["\"PeopleWithBinaryColumn\".\"name\" = ?1", "\"People\".\"name\" = ?2"]]
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
                    print(">>> \(user) \(user.name) \(user.binary)")
                  XCTAssertEqual(user.name, "Joe")
                  XCTAssertEqual(user.binary.wrapped, Data(count: 38))
                }
                expectation.fulfill()
            }
        })
    }
}

class TestResultFetcherWithBinaryColumn: TestResultFetcher {
    func done() {
        return
    }

    let numberOfRows: Int
    let rows = [[1, "Joe", Data(count: 38)], [2, "Adam", Data(count: 28)], [3, "Chris", Data(count: 36)]]
    let titles = ["id", "name", "binary"]
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
