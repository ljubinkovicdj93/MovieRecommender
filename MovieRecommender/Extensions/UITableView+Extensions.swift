//
//  UITableView+Extensions.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import UIKit

extension UITableView {
    func dequeueCellWith<CellType: UITableViewCell & ReusableCell>(cellType: CellType.Type, indexPath: IndexPath) -> CellType {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? CellType else {
            assertionFailure("Cell doesn't have cell identifier set to \(CellType.self)")
            return CellType()
        }
        return cell
    }

    func registerCell<CellType: UITableViewCell & ReusableCell>(with cellType: CellType.Type) {
        register(UINib(nibName: cellType.reuseIdentifier, bundle: nil), forCellReuseIdentifier: cellType.reuseIdentifier)
    }
}
