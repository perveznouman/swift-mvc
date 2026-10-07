import UIKit

/// CONTROLLER (MVC): composes the two root screens.
final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let users = UINavigationController(rootViewController: UsersListViewController())
        users.tabBarItem = UITabBarItem(title: "Users", image: UIImage(systemName: "person.3"), tag: 0)

        let favorites = UINavigationController(rootViewController: FavoritesViewController())
        favorites.tabBarItem = UITabBarItem(title: "Favourites", image: UIImage(systemName: "star"), tag: 1)

        viewControllers = [users, favorites]
    }
}
