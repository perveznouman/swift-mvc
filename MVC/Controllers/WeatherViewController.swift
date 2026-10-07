import UIKit

/// SCREEN 4: weather at the user's address lat/long (Open-Meteo).
/// For favourites the last successful report is cached, so this works offline too (shown as "last updated").
final class WeatherViewController: UIViewController {
    private let user: User
    private let weatherService = WeatherService.shared
    private let favorites = FavoritesStore.shared

    private let stateView = StateView()
    private let scrollView = UIScrollView()
    private let content = UIStackView()

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Weather"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground

        content.axis = .vertical
        content.spacing = 16
        content.isLayoutMarginsRelativeArrangement = true
        content.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(content)
        view.addSubview(stateView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            stateView.topAnchor.constraint(equalTo: view.topAnchor),
            stateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        stateView.onAction = { [weak self] in self?.load() }
        load()
    }

    // MARK: Loading

    private func load() {
        guard let latitude = user.address.geo.latitude, let longitude = user.address.geo.longitude else {
            stateView.render(.message(symbol: "mappin.slash", text: "This address has no valid coordinates.", actionTitle: nil))
            return
        }
        stateView.render(.loading)
        scrollView.isHidden = true

        Task {
            do {
                let report = try await weatherService.fetchWeather(latitude: latitude, longitude: longitude)
                if favorites.isFavorite(user.id) { favorites.saveWeather(report, for: user.id) }
                show(report, staleSince: nil)
            } catch {
                if let cached = favorites.cachedWeather(for: user.id) {
                    show(cached.report, staleSince: cached.updatedAt)
                } else {
                    let hint = favorites.isFavorite(user.id) ? "" : "\n\nFavourite this user while online to keep their weather offline."
                    stateView.render(.message(symbol: "cloud.slash",
                                              text: "Couldn't load the weather.\n\(error.localizedDescription)\(hint)",
                                              actionTitle: "Try Again"))
                }
            }
        }
    }

    // MARK: Rendering

    private func show(_ report: WeatherReport, staleSince: Date?) {
        stateView.render(.hidden)
        scrollView.isHidden = false
        content.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if let staleSince {
            let banner = UILabel()
            banner.text = "Offline: showing weather saved \(staleSince.formatted(date: .abbreviated, time: .shortened))"
            banner.font = .preferredFont(forTextStyle: .footnote)
            banner.textColor = .systemOrange
            banner.numberOfLines = 0
            banner.textAlignment = .center
            content.addArrangedSubview(banner)
        }
        content.addArrangedSubview(makeCurrentCard(report.current))
        content.addArrangedSubview(makeDetailsCard(report.current))
        content.addArrangedSubview(makeForecastCard(report.daily))
    }

    private func makeCurrentCard(_ current: WeatherReport.Current) -> UIView {
        let place = UILabel()
        place.text = "\(user.address.city)  (\(user.address.geo.lat), \(user.address.geo.lng))"
        place.font = .preferredFont(forTextStyle: .subheadline)
        place.textColor = .secondaryLabel
        place.textAlignment = .center

        let icon = UIImageView(image: UIImage(systemName: WeatherCondition.symbol(for: current.weatherCode)))
        icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 56)
        icon.tintColor = .systemBlue
        icon.contentMode = .scaleAspectFit

        let temperature = UILabel()
        temperature.text = "\(Int(current.temperature.rounded()))°C"
        temperature.font = .systemFont(ofSize: 52, weight: .bold)

        let condition = UILabel()
        condition.text = WeatherCondition.description(for: current.weatherCode)
        condition.font = .preferredFont(forTextStyle: .title3)

        let stack = UIStackView(arrangedSubviews: [place, icon, temperature, condition])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return card(containing: stack)
    }

    private func makeDetailsCard(_ current: WeatherReport.Current) -> UIView {
        let rows = [
            detailRow("Feels like", "\(Int(current.apparentTemperature.rounded()))°C"),
            detailRow("Humidity", "\(current.humidity)%"),
            detailRow("Wind", "\(Int(current.windSpeed.rounded())) km/h")
        ]
        let stack = UIStackView(arrangedSubviews: rows)
        stack.axis = .vertical
        stack.spacing = 10
        return card(containing: stack)
    }

    private func makeForecastCard(_ daily: WeatherReport.Daily) -> UIView {
        let title = UILabel()
        title.text = "FORECAST"
        title.font = .preferredFont(forTextStyle: .caption1)
        title.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [title])
        stack.axis = .vertical
        stack.spacing = 10

        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        let weekday = DateFormatter()
        weekday.dateFormat = "EEE"

        for index in daily.dates.indices.prefix(5) {
            let date = parser.date(from: daily.dates[index])
            let day = UILabel()
            day.text = index == 0 ? "Today" : (date.map(weekday.string(from:)) ?? daily.dates[index])
            day.widthAnchor.constraint(equalToConstant: 56).isActive = true

            let icon = UIImageView(image: UIImage(systemName: WeatherCondition.symbol(for: daily.weatherCodes[index])))
            icon.tintColor = .systemBlue
            icon.contentMode = .scaleAspectFit
            icon.widthAnchor.constraint(equalToConstant: 28).isActive = true

            let range = UILabel()
            range.text = "\(Int(daily.minTemperatures[index].rounded()))° / \(Int(daily.maxTemperatures[index].rounded()))°"
            range.textAlignment = .right

            let row = UIStackView(arrangedSubviews: [day, icon, range])
            row.spacing = 12
            row.alignment = .center
            stack.addArrangedSubview(row)
        }
        return card(containing: stack)
    }

    private func detailRow(_ title: String, _ value: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .secondaryLabel
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.textAlignment = .right
        return UIStackView(arrangedSubviews: [titleLabel, valueLabel])
    }

    private func card(containing inner: UIView) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 12
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16)
        ])
        return card
    }
}
