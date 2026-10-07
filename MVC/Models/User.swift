import Foundation

// MODEL (MVC): plain data types. No UIKit, no networking, no persistence logic.

struct User: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let address: Address
    let phone: String
    let website: String
    let company: Company

    /// JSONPlaceholder has no profile pictures, so we derive one from the user id.
    var avatarURL: URL { URL(string: "https://i.pravatar.cc/300?img=\(id)")! }
}

struct Address: Codable, Equatable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: Geo

    var formatted: String { "\(suite), \(street), \(city) \(zipcode)" }
}

/// The API returns coordinates as strings, e.g. "-37.3159".
struct Geo: Codable, Equatable {
    let lat: String
    let lng: String

    var latitude: Double? { Double(lat) }
    var longitude: Double? { Double(lng) }
}

struct Company: Codable, Equatable {
    let name: String
    let catchPhrase: String
    let bs: String
}
