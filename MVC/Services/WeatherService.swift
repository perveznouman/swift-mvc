import Foundation

final class WeatherService {
    static let shared = WeatherService()

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherReport {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code"),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min"),
            URLQueryItem(name: "timezone", value: "auto")
        ]
        guard let url = components.url else { throw APIError.invalidURL }
        return try await client.get(WeatherReport.self, from: url)
    }
}
