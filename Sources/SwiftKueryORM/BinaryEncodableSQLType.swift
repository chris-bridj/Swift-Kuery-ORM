import Foundation
import SwiftKuery

// MARK: BinarySQLEncodableType

/// Types conforming to this interface will be passed to the database as binary, assuming the database adaptor supports binary parameters.
public protocol BinaryEncodableSQLType : SQLDataType, Codable {
    /// Encode this object to binary data for the database
    func asSQLBinary() -> Data

    /// Build this object from binary data fetched from the database
    init(SQLBinary: Data)

    /// Build a dummy or blank version of this type to assist TypeDecoder
    init()
}

public extension BinaryEncodableSQLType {
    // These functions are only used by TypeDecoder when it constructs a "dummy" object in order to sense type.
    public func encode(to: Encoder) { }
    public init(from decoder: Decoder) throws {
        self.init()
    }
}
