//
//  IndividualSectionProvider.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import Foundation

public class IndividualSectionProvider<Model>: TableDataProvider {
    // MARK: - Internal Properties
    private(set) var items: [Model]

    // MARK: - Lifecycle
    init(array: [Model]) {
        items = array
    }

    // MARK: - TableDataProvider
    public func numberOfSections() -> Int {
        return 1
    }

    public func numberOfRows(in section: Int) -> Int {
        return items.count
    }

    public func row(at indexPath: IndexPath) -> Model? {
        guard indexPath.section == 0 && indexPath.row < items.count else {
            return nil
        }

        return items[indexPath.item]
    }

    public func updateRow(at indexPath: IndexPath, value: Model) {
        guard indexPath.section == 0 && indexPath.row < items.count else {
            return
        }

        items[indexPath.item] = value
    }

    public func addRows(values: [Model]) {
        items.append(contentsOf: values)
    }

    public func removeRows() {
        items = []
    }

    public func filterRows(_ predicate: (Model) -> Bool) -> [Model] {
        return items.filter(predicate)
    }
}

public extension IndividualSectionProvider {
    func addItem(value: Model) {
        items.append(value)
    }

    func item(at row: Int) -> Model {
        return items[row]
    }
}
