import UIKit

/// Downloads and memory-caches images. Returns raw `Data` too, so favourites can persist the avatar.
final class ImageLoader {
    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, NSData>()
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func data(for url: URL) async -> Data? {
        if let cached = cache.object(forKey: url as NSURL) {
            return cached as Data
        }
        guard let data = try? await client.rawData(from: url) else {
            return nil
        }
        cache.setObject(data as NSData, forKey: url as NSURL)
        return data
    }

    func image(for url: URL) async -> UIImage? {
        guard let data = await data(for: url) else {
            return nil
        }
        return UIImage(data: data)
    }
}
