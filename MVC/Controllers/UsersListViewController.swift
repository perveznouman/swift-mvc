import UIKit

/// SCREEN 1: all users from the API. The controller talks to the model (UserService, FavoritesStore)
/// directly and pushes data into the views, which is the essence of MVC.
final class UsersListViewController: UITableViewController {
    private let userService = UserService.shared
    private let favorites = FavoritesStore.shared
    private let stateView = StateView()
    private var users: [User] = []

    init() { super.init(style: .insetGrouped) }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Users"
        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
        tableView.backgroundView = stateView
        stateView.onAction = {
            [weak self] in self?.loadUsers()
        }
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(pulledToRefresh), for: .valueChanged)

        NotificationCenter.default.addObserver(self, selector: #selector(favoritesChanged),
                                               name: .favoritesDidChange, object: nil)
        loadUsers()
    }

    // MARK: Loading

    @objc private func pulledToRefresh() {
        loadUsers(showSpinner: false)
    }

    private func loadUsers(showSpinner: Bool = true) {
        if showSpinner && users.isEmpty { stateView.render(.loading) }
        Task {
            do {
                users = try await userService.fetchUsers()
                stateView.render(.hidden)
            } catch {
                if users.isEmpty {
                    stateView.render(.message(symbol: "wifi.slash",
                                              text: "Couldn't load users.\n\(error.localizedDescription)\n\nFavourites are still available offline.",
                                              actionTitle: "Try Again"))
                }
            }
            tableView.reloadData()
            refreshControl?.endRefreshing()
        }
    }

    @objc private func favoritesChanged() { tableView.reloadData() }

    // MARK: Table view

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { users.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseIdentifier, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.configure(with: user, isFavorite: favorites.isFavorite(user.id))
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(UserDetailViewController(user: users[indexPath.row]), animated: true)
    }

    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let user = users[indexPath.row]
        let isFavorite = favorites.isFavorite(user.id)
        let action = UIContextualAction(style: .normal, title: isFavorite ? "Unfavourite" : "Favourite") { [weak self] _, _, done in
            self?.favorites.toggle(user)
            done(true)
        }
        action.image = UIImage(systemName: isFavorite ? "star.slash" : "star.fill")
        action.backgroundColor = .systemOrange
        return UISwipeActionsConfiguration(actions: [action])
    }
}
