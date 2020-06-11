//
//  DiffableColController.swift
//  AtomicApp
//
//  Created by Omar Eduardo Gomez Padilla on 6/11/20.
//  Copyright © 2020 Omar Gómez. All rights reserved.
//

import UIKit

class DiffableColController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    typealias ItemType = Int
    typealias CellType = UICollectionViewCell // change
    typealias DataSourceType = UICollectionViewDiffableDataSource<Int, ItemType>
    typealias SnapshotType = NSDiffableDataSourceSnapshot<Int, ItemType>
    
    lazy var dataSource: DataSourceType = {
        DataSourceType(collectionView: self.collectionView, cellProvider: { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            self?.provideCell(indexPath, item)
        })
    }()
    
    private func provideCell(_ indexPath: IndexPath, _ item: ItemType) -> UICollectionViewCell? {
        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "reuseId", for: indexPath) as? CellType else {
            fatalError("No Cell")
        }
        
        // customize cell
//        cell.movieTitle.text = movie.title

        return cell
    }
    
    lazy var layout: UICollectionViewCompositionalLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(88+44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }()
    
    private func snapshot(for data: [ItemType]) -> SnapshotType {
        var result = SnapshotType()
        result.appendSections([0])
        result.appendItems(data)
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Init col view
        collectionView.collectionViewLayout = layout
//        collectionView.delegate = self (In case)
        dataSource.apply( snapshot(for: []) )
    }
    
}
