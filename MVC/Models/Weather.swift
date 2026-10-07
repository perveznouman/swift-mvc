import Foundation

/// Subset of the Open-Meteo forecast response (https://open-meteo.com, no API key needed).
struct WeatherReport: Codable, Equatable {
    struct Current: Codable, Equatable {
        let temperature: Double
        let apparentTemperature: Double
        let humidity: Int
        let windSpeed: Double
        let weatherCode: Int

        enum CodingKeys: String, CodingKey {
            case temperature = "temperature_2m"
            case apparentTemperature = "apparent_temperature"
            case humidity = "relative_humidity_2m"
            case windSpeed = "wind_speed_10m"
            case weatherCode = "weather_code"
        }
    }

    struct Daily: Codable, Equatable {
        let dates: [String]
        let weatherCodes: [Int]
        let maxTemperatures: [Double]
        let minTemperatures: [Double]

        enum CodingKeys: String, CodingKey {
            case dates = "time"
            case weatherCodes = "weather_code"
            case maxTemperatures = "temperature_2m_max"
            case minTemperatures = "temperature_2m_min"
        }
    }

    let current: Current
    let daily: Daily
}

/// Maps WMO weather codes to a readable description and an SF Symbol.
enum WeatherCondition {
    static func description(for code: Int) -> String {
        switch code {
        case 0: return "Clear sky"
        case 1, 2: return "Partly cloudy"
        case 3: return "Overcast"
        case 45, 48: return "Fog"
        case 51...57: return "Drizzle"
        case 61...67: return "Rain"
        case 71...77: return "Snow"
        case 80...82: return "Rain showers"
        case 85, 86: return "Snow showers"
        case 95...99: return "Thunderstorm"
        default: return "Unknown"
        }
    }

    static func symbol(for code: Int) -> String {
        switch code {
        case 0: return "sun.max.fill"
        case 1, 2: return "cloud.sun.fill"
        case 3: return "cloud.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51...57: return "cloud.drizzle.fill"
        case 61...67, 80...82: return "cloud.rain.fill"
        case 71...77, 85, 86: return "cloud.snow.fill"
        case 95...99: return "cloud.bolt.rain.fill"
        default: return "questionmark.circle"
        }
    }
}
