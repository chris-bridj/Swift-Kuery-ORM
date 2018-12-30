import XCTest

@testable import SwiftKueryORM
import Foundation
import KituraContracts

class TestTableWithBinaryColumn: XCTestCase {
    static var allTests: [(String, (TestTableWithBinaryColumn) -> () throws -> Void)] {
        return [
            ("testCreateTable", testCreateTable),
            ("testDropTable", testDropTable),
            ("testCreateTableWithFieldAsId", testCreateTableWithFieldAsId),
            ("testCreateTableWithCustomIdNameAndType", testCreateTableWithCustomIdNameAndType),
        ]
    }

    struct UserWithBinaryColumn: Model {
        static let tableName = "UsersWithBinaryColumn"
        var username: String
        var binary: Data
    }

    /**
      Testing that the correct SQL Query is created to create a table
    */
    func testCreateTable() {
        let connection: TestConnection = createConnection(.returnEmpty)
        Database.default = Database(single: connection)
        performTest(asyncTasks: { expectation in
            UserWithBinaryColumn.createTable { result, error in
                XCTAssertNil(error, "Table Creation Failed: \(String(describing: error))")
                XCTAssertNotNil(connection.raw, "Table Creation Failed: Query is nil")
                if let raw = connection.raw {
                  let expectedQuery = "CREATE TABLE \"UsersWithBinaryColumn\" (\"username\" type NOT NULL, \"binary\" type NOT NULL, \"id\" type AUTO_INCREMENT PRIMARY KEY)"
                  XCTAssertEqual(raw, expectedQuery, "Table Creation Failed: Invalid query")
                }
                expectation.fulfill()
            }
        })
    }

    /**
      Testing that the correct SQL Query is created to drop a table
    */
    func testDropTable() {
        let connection: TestConnection = createConnection(.returnEmpty)
        Database.default = Database(single: connection)
        performTest(asyncTasks: { expectation in
            UserWithBinaryColumn.dropTable { result, error in
                XCTAssertNil(error, "Table Drop Failed: \(String(describing: error))")
                XCTAssertNotNil(connection.query, "Table Drop Failed: Query is nil")
                if let query = connection.query {
                  let expectedQuery = "DROP TABLE \"UsersWithBinaryColumn\""
                  let resultQuery = connection.descriptionOf(query: query)
                  XCTAssertEqual(resultQuery, expectedQuery, "Table Drop Failed: Invalid query")
                }
                expectation.fulfill()
            }
        })
    }

    struct MealWithBinaryColumn: Model {
        static let tableName = "MealsWithBinaryColumn"
        static var idColumnName = "name"
        var name: String
        var binary: Data
    }

    /**
      Testing that the correct SQL Query is created to create a table with the field as the PRIMARY KEY of the table
    */
    func testCreateTableWithFieldAsId() {
        let connection: TestConnection = createConnection(.returnEmpty)
        Database.default = Database(single: connection)
        performTest(asyncTasks: { expectation in
            MealWithBinaryColumn.createTable { result, error in
                XCTAssertNil(error, "Table Creation Failed: \(String(describing: error))")
                XCTAssertNotNil(connection.raw, "Table Creation Failed: Query is nil")
                if let raw = connection.raw {
                  let expectedQuery = "CREATE TABLE \"MealsWithBinaryColumn\" (\"name\" type PRIMARY KEY NOT NULL, \"binary\" type NOT NULL)"
                  XCTAssertEqual(raw, expectedQuery, "Table Creation Failed: Invalid query")
                }
                expectation.fulfill()
            }
        })
    }

    struct GradeWithBinaryColumn: Model {
        static let tableName = "GradesWithBinaryColumn"
        static var idColumnName = "MyId"
        static var idColumnType: SQLDataType.Type = Int64.self
        var grade: Double
        var binary: Data
    }

    /**
      Testing that the correct SQL Query is created to create a table with the PRIMARY KEY having a specific name and type
    */
    func testCreateTableWithCustomIdNameAndType() {
        let connection: TestConnection = createConnection(.returnEmpty)
        Database.default = Database(single: connection)
        performTest(asyncTasks: { expectation in
            GradeWithBinaryColumn.createTable { result, error in
                XCTAssertNil(error, "Table Creation Failed: \(String(describing: error))")
                XCTAssertNotNil(connection.raw, "Table Creation Failed: Query is nil")
                if let raw = connection.raw {
                  let expectedQuery = "CREATE TABLE \"GradesWithBinaryColumn\" (\"grade\" type NOT NULL, \"binary\" type NOT NULL, \"MyId\" type AUTO_INCREMENT PRIMARY KEY)"
                  XCTAssertEqual(raw, expectedQuery, "Table Creation Failed: Invalid query")
                }
                expectation.fulfill()
            }
        })
    }
}
