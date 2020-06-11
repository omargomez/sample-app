//
//  NowShowingController.swift
//  AtomicApp
//
//  Created by Omar Gomez on 5/25/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import UIKit

class NowPlayingController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var playingTable: UITableView!
    @IBOutlet weak var statusLabel: UILabel!
    var movies: [Movie] = []
    static let placeholderImage = UIImage(named: "movieLogo")!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.playingTable.isHidden = true
        self.statusLabel.isHidden = false
        self.statusLabel.text = " Getting Data ..."
        
        self.loadData(loadConfig: AppDelegate.configuration == nil ) { [weak self] (configuration, movies) in
            
            guard let strongSelf = self else {
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

            strongSelf.movies = theMovies

            Logger.shared.log(.DEBUG, "Data Loaded!!!")

            strongSelf.playingTable.isHidden = false
            strongSelf.statusLabel.isHidden = true

            strongSelf.playingTable.reloadData()

        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let detailController = segue.destination as! MovieDetailController
        detailController.selectedMovie = sender as! Movie
        
    }

    // MARK: - Table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MAIN_MOVIE_CELL")! as! MainMovieCell

        let movie = self.movies[indexPath.row]
        
        cell.textLabel?.text = movie.title
        cell.imageView?.image = NowPlayingController.placeholderImage

        let imageEndPoint = EndPoint.image(basePath: AppDelegate.configuration!.images.secureBaseUrl, size: AppDelegate.configuration!.images.defaultLogoSize, imageName: movie.posterPath)
        cell.scheduleImageLoading(fromURL: imageEndPoint.url)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let movie = self.movies[indexPath.row]

        self.performSegue(withIdentifier: "SHOW_DETAIL_SEGUE", sender: movie)

    }

    
}
