import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case badStatus(Int)
    case decoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The request URL was invalid."
        case .badStatus(let code): return "The server responded with status \(code)."
        case .decoding: return "The server response could not be read."
        case .transport(let error): return error.localizedDescription
        }
    }
}

/// Thin async wrapper around URLSession. Part of the Model layer in MVC.
final class APIClient {
    static let shared = APIClient()

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        let data = try await rawData(from: url)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    func rawData(from url: URL) async throws -> Data {
        do {
            let (data, response) = try await session.data(from: url)
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                throw APIError.badStatus(http.statusCode)
            }
            return data
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.transport(error)
        }
    }
}
