import UIKit

/// SCREEN 3: every field of a user. Tapping the address pushes the weather screen.
final class UserDetailViewController: UIViewController {
    private let user: User
    private let favorites = FavoritesStore.shared
    private let avatarView = UIImageView()
    private let avatarSpinner = UIActivityIndicatorView(style: .medium)

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = user.name
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground

        buildLayout()
        updateFavoriteButton()
        loadAvatar()

        NotificationCenter.default.addObserver(self, selector: #selector(updateFavoriteButton),
                                               name: .favoritesDidChange, object: nil)
    }

    // MARK: Layout

    private func buildLayout() {
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 60
        avatarView.backgroundColor = .tertiarySystemFill
        avatarView.image = UIImage(systemName: "person.crop.circle.fill")
        avatarView.tintColor = .tertiaryLabel
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        avatarView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        avatarView.isAccessibilityElement = true
        avatarView.accessibilityLabel = "Profile picture of \(user.name)"

        avatarSpinner.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(avatarSpinner)
        avatarSpinner.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor).isActive = true
        avatarSpinner.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor).isActive = true

        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.font = .preferredFont(forTextStyle: .title2).bold()
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0

        let header = UIStackView(arrangedSubviews: [avatarView, nameLabel])
        header.axis = .vertical
        header.alignment = .center
        header.spacing = 12

        let rows = UIStackView(arrangedSubviews: [
            DetailRowView(title: "Name", value: user.name),
            DetailRowView(title: "Username", value: "@\(user.username)"),
            DetailRowView(title: "Email", value: user.email),
            DetailRowView(title: "Phone", value: user.phone),
            DetailRowView(title: "Website", value: user.website),
            DetailRowView(title: "Address", value: user.address.formatted) { [weak self] in self?.showWeather() }
        ])
        rows.axis = .vertical
        rows.spacing = 8

        let content = UIStackView(arrangedSubviews: [header, rows])
        content.axis = .vertical
        content.spacing = 24
        content.isLayoutMarginsRelativeArrangement = true
        content.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        content.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(content)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor)
        ])
    }

    // MARK: Avatar

    private func loadAvatar() {
        // Favourites carry their avatar with them, which is what makes this screen work offline.
        if let data = favorites.avatarData(for: user.id), let image = UIImage(data: data) {
            avatarView.image = image
            avatarView.contentMode = .scaleAspectFill
            return
        }
        avatarView.contentMode = .scaleAspectFit
        avatarSpinner.startAnimating()
        Task {
            let image = await ImageLoader.shared.image(for: user.avatarURL)
            avatarSpinner.stopAnimating()
            if let image {
                avatarView.contentMode = .scaleAspectFill
                avatarView.image = image
            }
        }
    }

    // MARK: Actions

    @objc private func updateFavoriteButton() {
        let isFavorite = favorites.isFavorite(user.id)
        let item = UIBarButtonItem(image: UIImage(systemName: isFavorite ? "star.fill" : "star"),
                                   style: .plain, target: self, action: #selector(toggleFavorite))
        item.tintColor = isFavorite ? .systemYellow : nil
        item.accessibilityLabel = isFavorite ? "Remove from favourites" : "Add to favourites"
        navigationItem.rightBarButtonItem = item
    }

    @objc private func toggleFavorite() { favorites.toggle(user) }

    private func showWeather() {
        navigationController?.pushViewController(WeatherViewController(user: user), animated: true)
    }
}

private extension UIFont {
    func bold() -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
