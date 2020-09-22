//
//  TableIndividualSectionDataSource.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import UIKit

open class TableIndividualSectionDataSource<Model, Cell: UITableViewCell>: TableDataSource<IndividualSectionProvider<Model>, Cell> where Cell: ConfigurableCell, Cell.Model == Model {

    // MARK: - Initialization
    public init(tableView: UITableView, array: [Model]) {
        let provider = IndividualSectionProvider(array: array)
        super.init(tableView: tableView, provider: provider)
    }

    // MARK: - Public Methods
    public func row(at indexPath: IndexPath) -> Model? {
        return provider.row(at: indexPath)
    }

    public func updateRow(at indexPath: IndexPath, value: Model) {
        provider.updateRow(at: indexPath, value: value)
    }

    public func removeRows() {
        provider.removeRows()
    }

    public func filterRows(_ predicate: (Model) -> Bool) -> [Model] {
        return provider.filterRows(predicate)
    }
}
