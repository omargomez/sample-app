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
    var config: Configuration!
    static let placeholderImage = UIImage(named: "movieLogo")!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private func loadData(loadConfig: Bool, completion: @escaping (Configuration?, [Movie]?) -> Void ) {
        
        let group = DispatchGroup()
        
        var configuration: Configuration?
        if loadConfig {
            group.enter()
            URLSession.shared.doJsonTask(forURL: EndPoint.configuration.url) { (data, error) in
                
                defer {
                    group.leave()
                }
                
                guard let theData = data else {
                    print("Error starting App!!! \(error ?? NSError.UNKNOWN)")
                    return
                }
                
                print("[CONF] config: \(theData.description)")
                configuration = Configuration(fromJson: theData)
                print("[CONF] app config: \(configuration!)")
            }
        }
        
        group.enter()
        var movies: [Movie]?
        URLSession.shared.doJsonTask(forURL: EndPoint.nowPlaying.url) { (data, error) in
            movies = []
            defer {
                group.leave()
            }
            
            guard let theData = data,
                let results = theData["results"] as? [Any] else {
                    print("Error starting App!!! \(error ?? NSError.UNKNOWN)")
                    return
            }
            print("[CONF] nor playing: \(theData.description)")

            for case let movieJson as [String:Any] in results {
                
                guard let movie = Movie(fromJson: movieJson) else {
                    return
                }
                
                movies?.append(movie)
            }
            
        }

        group.notify(queue: .main) {
            
            completion(configuration, movies)
        }

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
            
            if AppDelegate.configuration == nil {
                guard let theConfiguration = configuration else {
                    return
                }

                AppDelegate.configuration = theConfiguration
                strongSelf.config = theConfiguration
            }

            guard let theMovies = movies else {
                return
            }

            strongSelf.movies = theMovies

            print("Data Loaded!!!")

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

        let imageEndPoint = EndPoint.image(basePath: self.config.images.secureBaseUrl, size: self.config.images.defaultLogoSize, imageName: movie.posterPath)
        cell.scheduleImageLoading(fromURL: imageEndPoint.url)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let movie = self.movies[indexPath.row]

        self.performSegue(withIdentifier: "SHOW_DETAIL_SEGUE", sender: movie)

    }

    
}
