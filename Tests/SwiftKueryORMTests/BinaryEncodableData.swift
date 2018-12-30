import Foundation
import SwiftKuery
import SwiftKueryORM

// Wrapper around Data that implements BinaryEncodableSQLType to allow testing of binary parameters.
// Many applications will simply implement BinaryEncodableSQLType on Data itself, but in this case it would shadow testing of the legacy functionality that stores Data as a base64-encoded string.
struct BinaryEncodableData: BinaryEncodableSQLType, Equatable {
    let wrapped: Data

    public func asSQLBinary() -> Data {
        return wrapped
    }

    public init(SQLBinary: Data) {
        wrapped = SQLBinary
    }

    public init() {
        wrapped = Data()
    }

    public static func create(queryBuilder: SwiftKuery.QueryBuilder) -> String {
        return "bin"
    }
}

func ==(lhs: BinaryEncodableData, rhs: BinaryEncodableData) -> Bool {
    return lhs.wrapped == rhs.wrapped
}
