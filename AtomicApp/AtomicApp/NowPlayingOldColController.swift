//
//  NowPlayingOldColController.swift
//  AtomicApp
//
//  Created by Omar Eduardo Gomez Padilla on 6/10/20.
//  Copyright © 2020 Omar Gómez. All rights reserved.
//

import UIKit

class NowPlayingOldColController: UIViewController {

    //Types
    typealias DataType = Movie
    typealias CellType = NowPlayingCell
    
    //state
    var data: [DataType] = []
    
    //specific
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.loadData(loadConfig: AppDelegate.configuration == nil ) { [weak self] (configuration, movies) in
            
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
            
            self.data = theMovies
            self.collectionView.reloadData()
            
            Logger.shared.log(.DEBUG, "Data Loaded!!!")
            
        }
        
    }
    
}

extension NowPlayingOldColController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellType.reuseId, for: indexPath) as? CellType else {
            fatalError("No cell!")
        }
        
        //configure cell
        let item = data[indexPath.row]
        
        cell.movieTitle.text = item.title
        cell.posterImage?.image = NowPlayingController.placeholderImage
        let imageEndPoint = EndPoint.image(basePath: AppDelegate.configuration!.images.secureBaseUrl, size: AppDelegate.configuration!.images.defaultLogoSize, imageName: item.posterPath)
        cell.scheduleImageLoading(fromURL: imageEndPoint.url)
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? MovieDetailController, let movie = sender as? Movie else {
            fatalError("No parameter!")
        }
        controller.selectedMovie = movie
    }
    
}

extension NowPlayingOldColController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = self.data[indexPath.row]
        self.performSegue(withIdentifier: "SHOW_DETAIL_SEGUE", sender: movie)
    }
    
}
