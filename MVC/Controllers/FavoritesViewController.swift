import UIKit

/// SCREEN 2: favourites, read only from Core Data, so it works with no network at all.
final class FavoritesViewController: UITableViewController {
    private let favorites = FavoritesStore.shared
    private let stateView = StateView()
    private var users: [User] = []

    init() { super.init(style: .insetGrouped) }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favourites"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
        tableView.backgroundView = stateView
        NotificationCenter.default.addObserver(self, selector: #selector(reload),
                                               name: .favoritesDidChange, object: nil)
        reload()
    }

    @objc private func reload() {
        users = favorites.allFavorites()
        tableView.reloadData()
        if users.isEmpty {
            stateView.render(.message(symbol: "star", text: "No favourites yet.\nOpen a user and tap the star to save them for offline use.", actionTitle: nil))
        } else {
            stateView.render(.hidden)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { users.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseIdentifier, for: indexPath) as! UserCell
        cell.configure(with: users[indexPath.row], isFavorite: true)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(UserDetailViewController(user: users[indexPath.row]), animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete { favorites.toggle(users[indexPath.row]) }
    }

    override func tableView(_ tableView: UITableView,
                            titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? { "Remove" }
}
