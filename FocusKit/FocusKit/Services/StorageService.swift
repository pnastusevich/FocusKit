import Foundation

protocol StorageServiceProtocol {
    func save<T: Codable>(_ object: T, forKey key: String)
    func load<T: Codable>(_ type: T.Type, forKey key: String) -> T?
    func saveArray<T: Codable>(_ array: [T], forKey key: String)
    func loadArray<T: Codable>(_ type: T.Type, forKey key: String) -> [T]
    func remove(forKey key: String)
}

final class StorageService: StorageServiceProtocol {
    private let userDefaults = UserDefaults.standard
    
    func save<T: Codable>(_ object: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(object) {
            userDefaults.set(encoded, forKey: key)
            Logger.shared.debug("Saved object for key: \(key)")
        } else {
            Logger.shared.error("Failed to encode object for key: \(key)")
        }
    }
    
    func load<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode(type, from: data) else {
            Logger.shared.debug("No data found or failed to decode for key: \(key)")
            return nil
        }
        Logger.shared.debug("Loaded object for key: \(key)")
        return decoded
    }
    
    func saveArray<T: Codable>(_ array: [T], forKey key: String) {
        if let encoded = try? JSONEncoder().encode(array) {
            userDefaults.set(encoded, forKey: key)
            Logger.shared.debug("Saved array with \(array.count) items for key: \(key)")
        } else {
            Logger.shared.error("Failed to encode array for key: \(key)")
        }
    }
    
    func loadArray<T: Codable>(_ type: T.Type, forKey key: String) -> [T] {
        guard let data = userDefaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([T].self, from: data) else {
            Logger.shared.debug("No array data found or failed to decode for key: \(key)")
            return []
        }
        Logger.shared.debug("Loaded array with \(decoded.count) items for key: \(key)")
        return decoded
    }
    
    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}

