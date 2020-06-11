//
//  OldSchoolColController.swift
//  AtomicApp
//
//  Created by Omar Eduardo Gomez Padilla on 6/11/20.
//  Copyright © 2020 Omar Gómez. All rights reserved.
//

import UIKit

class OldSchoolColController: UIViewController {

    //Types
    typealias DataType = Int
    typealias CellType = UICollectionViewCell
    
    //state
    var data: [DataType] = []
    
    //specific
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
}

extension OldSchoolColController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "resuseId", for: indexPath) as? CellType else {
            fatalError("No cell!")
        }
        
        //configure cell
        let item = data[indexPath.row]
        
//        cell.movieTitle.text = item.title

        return cell
    }

}

extension OldSchoolColController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Empty
    }
    
}

