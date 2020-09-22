//
//  UserDefaultsStorable.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import Foundation

protocol UserDefaultsSavable {
    func saveObject<T: Encodable>(_ object: T, forKey key: String) throws
}

protocol UserDefaultsRetrievable {
    func getObject<T: Decodable>(forKey key: String) throws -> T?
}

typealias UserDefaultsStorable = UserDefaultsSavable & UserDefaultsRetrievable

extension UserDefaults: UserDefaultsStorable {
    func saveObject<T>(_ object: T, forKey key: String) throws where T : Encodable {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(object)

            self.set(data, forKey: key)
        } catch {
            throw error
        }
    }

    func getObject<T>(forKey key: String) throws -> T? where T : Decodable {
        let decoder = JSONDecoder()
        guard let objectData = self.data(forKey: key) else { return nil }

        do {
            return try decoder.decode(T.self, from: objectData)
        } catch {
            throw error
        }
    }
}
