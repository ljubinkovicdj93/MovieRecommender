//
//  TableDataSource.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import UIKit

// MARK: - Provider Protocol
public protocol TableDataProvider {
    associatedtype Model

    func numberOfSections() -> Int
    func numberOfRows(in section: Int) -> Int
    func row(at indexPath: IndexPath) -> Model?

    func addRows(values: [Model])
    func updateRow(at indexPath: IndexPath, value: Model)

    func filterRows(_ predicate: (Model) -> Bool) -> [Model]
}

public typealias TableRowSelectionHandlerType<Model> = (Model?, IndexPath) -> Void

open class TableDataSource<Provider: TableDataProvider, Cell: UITableViewCell & ConfigurableCell>: NSObject, UITableViewDataSource, UITableViewDelegate where Provider.Model == Cell.Model {

    // MARK: - Private Properties
    var tableRowSelectionHandler: TableRowSelectionHandlerType<Provider.Model>?
    var tableRowDeselectionHandler: TableRowSelectionHandlerType<Provider.Model>?

    private(set) var provider: Provider
    var tableView: UITableView?

    // MARK: - Lifecycle

    public init(tableView: UITableView, provider: Provider) {
        self.tableView = tableView
        self.provider = provider
        super.init()

        self.tableView?.dataSource = self
        self.tableView?.delegate = self
    }

    // MARK: - UITableView Data Source
    public func numberOfSections(in tableView: UITableView) -> Int {
        return provider.numberOfSections()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return provider.numberOfRows(in: section)
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCellWith(cellType: Cell.self, indexPath: indexPath)

        if let item = provider.row(at: indexPath) {
            cell.configure(item)
        }

        return cell
    }

    // MARK: - UITableView Delegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableRowSelectionHandler?(provider.row(at: indexPath), indexPath)
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableRowDeselectionHandler?(provider.row(at: indexPath), indexPath)
    }

    // MARK: - Register didSelect/didDeselect Events
    public func registerDidSelect(_ didSelectHandler: @escaping TableRowSelectionHandlerType<Provider.Model>) {
        self.tableRowSelectionHandler = didSelectHandler
    }

    public func registerDidDeselect(_ didDeselectHandler: @escaping TableRowSelectionHandlerType<Provider.Model>) {
        self.tableRowDeselectionHandler = didDeselectHandler
    }
}
