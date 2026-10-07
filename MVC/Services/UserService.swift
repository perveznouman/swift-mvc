import Foundation

final class UserService {
    static let shared = UserService()

    private let client: APIClient
    private let url = URL(string: "https://jsonplaceholder.typicode.com/users")!

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchUsers() async throws -> [User] {
        try await client.get([User].self, from: url)
    }
}
