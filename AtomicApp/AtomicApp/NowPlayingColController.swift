//
//  NowPlayingColController.swift
//  AtomicApp
//
//  Created by Omar Eduardo Gomez Padilla on 6/8/20.
//  Copyright © 2020 Omar Gómez. All rights reserved.
//

import UIKit

class NowPlayingColController: UIViewController {

    static let storyboardId = String(describing: NowPlayingColController.self)
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<Int, Movie>
    typealias SnapshotType = NSDiffableDataSourceSnapshot<Int, Movie>
    
    lazy var dataSource: DataSourceType = {
        DataSourceType(collectionView: self.collectionView, cellProvider: { [weak self] (collectionView, indexPath, movie) -> UICollectionViewCell? in
            self?.provideCell(indexPath, movie)
        })
    }()
    
    private func provideCell(_ indexPath: IndexPath, _ movie: Movie) -> UICollectionViewCell? {
        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: NowPlayingCell.reuseId, for: indexPath) as? NowPlayingCell else {
            fatalError("No Cell")
        }
        
        cell.movieTitle.text = movie.title
        cell.posterImage?.image = NowPlayingController.placeholderImage
        let imageEndPoint = EndPoint.image(basePath: AppDelegate.configuration!.images.secureBaseUrl, size: AppDelegate.configuration!.images.defaultLogoSize, imageName: movie.posterPath)
        cell.scheduleImageLoading(fromURL: imageEndPoint.url)

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
    
    private func snapshot(for data: [Movie]) -> SnapshotType {
        var result = SnapshotType()
        result.appendSections([0])
        result.appendItems(data)
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        dataSource.apply( snapshot(for: []) )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadData(loadConfig: AppDelegate.configuration == nil ) { [weak self] (configuration, movies) in
            
            print("Main: \(Thread.isMainThread)")
            
            guard let self = self else {
                return
            }
            
            guard AppDelegate.configuration != nil || configuration != nil else {
                fatalError("No Configuration!!!")
            }
            
            if configuration != nil {
                AppDelegate.configuration = configuration
            }

            guard let theMovies = movies else {
                return
            }
            
            self.dataSource.apply(self.snapshot(for: theMovies))
            
            Logger.shared.log(.DEBUG, "Data Loaded!!!")
            
        }
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? MovieDetailController, let movie = sender as? Movie else {
            fatalError("No parameter!")
        }
        controller.selectedMovie = movie
    }

}

extension NowPlayingColController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = self.dataSource.itemIdentifier(for: indexPath) else {
            fatalError("No movie!")
        }
        
        self.performSegue(withIdentifier: "SHOW_DETAIL_SEGUE", sender: movie)
    }
    
}
