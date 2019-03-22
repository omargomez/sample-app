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
    var config: Configuration!
    static let placeholderImage = UIImage(named: "movieLogo")!
    
    // New support to handle coredata
    var entityArr: [NowPlayingEntity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private func loadData(loadConfig: Bool, completion: @escaping (Configuration?, [Dictionary<String,Any>]?) -> Void ) {
        
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
        var movies: [Dictionary<String,Any>]?
        URLSession.shared.doJsonTask(forURL: EndPoint.nowPlaying.url) { (data, error) in
            movies = []
            defer {
                group.leave()
            }
            
            guard let theData = data,
                let results = theData["results"] as? [Dictionary<String,Any>] else {
                    print("Error starting App!!! \(error ?? NSError.UNKNOWN)")
                    return
            }
            print("[CONF] nor playing: \(theData.description)")

            movies = results
            
        }

        group.notify(queue: .main) {
            
            completion(configuration, movies)
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            self.entityArr = try context.fetch(NowPlayingEntity.fetchRequest())
            print("Now playing items: \(self.entityArr.count)")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        if self.entityArr.count < 1 {
            self.playingTable.isHidden = true
            self.statusLabel.isHidden = false
            self.statusLabel.text = " Getting Data ..."
        } else {
            // Nothing for now
        }
            

        self.loadData(loadConfig: AppDelegate.configuration == nil ) { [weak self] (configuration, moviesJson) in
            
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

            guard let theMovies = moviesJson else {
                return
            }
            
            print("Data Loaded!!!")
            
            // Trigger table update

            strongSelf.playingTable.isHidden = false
            strongSelf.statusLabel.isHidden = true

            strongSelf.playingTable.reloadData()

            OperationQueue.main.addOperation {
                strongSelf.reloadData(withJson: theMovies)
            }

        }
        
    }
    
    func reloadData(withJson json: [Dictionary<String,Any>]) {
        
        do {
            // First we remove al items
            for item in self.entityArr {
                self.context.delete(item)
                self.appDelegate.saveContext()
            }
            
            let jsonSample =
"""
            {
            "vote_count": 650,
            "id": 399579,
            "video": false,
            "vote_average": 6.7,
            "title": "Alita: Battle Angel",
            "popularity": 362.08,
            "poster_path": "/xRWht48C2V8XNfzvPehyClOvDni.jpg",
            "original_language": "en",
            "original_title": "Alita: Battle Angel",
            "genre_ids": [28, 878, 53],
            "backdrop_path": "/aQXTw3wIWuFMy0beXRiZ1xVKtcf.jpg",
            "adult": false,
            "overview": "When Alita awakens with no memory of who she is in a future world she does not recognize, she is taken in by Ido, a compassionate doctor who realizes that somewhere in this abandoned cyborg shell is the heart and soul of a young woman with an extraordinary past.",
            "release_date": "2019-01-31"
        }
"""
            for i in json {
                
                let n = NowPlayingEntity(entity: NowPlayingEntity.entity(), insertInto: self.context)
                let root = JSONRoot(i)
                n.adult = root?["adult"]?.asBool ?? false
                n.backdropPath = root?["backdrop_path"]?.asString ?? ""
                n.genreIds = root?["genre_ids"]?.asJSONString ?? ""
                n.id = Int64(root?["id"]?.asInt ?? 0)
                n.originalLanguage = root?["original_language"]?.asString ?? ""
                n.originalTitle = root?["original_title"]?.asString ?? ""
                n.overview = root?["overview"]?.asString ?? ""
                n.popularity = root?["popularity"]?.asDouble ?? 0.0
                n.posterPath = root?["poster_path"]?.asString ?? ""
                n.releaseDate = root?["relese_date"]?.asString ?? "2000-01-01"
                n.title = root?["title"]?.asString ?? ""
                n.video = root?["video"]?.asBool ?? false
                n.voteAverage = root?["vote_average"]?.asDouble ?? 0.0
                n.voteCount = Int32(root?["vote_count"]?.asInt ?? 0)
                
                appDelegate.saveContext()

            }

            self.entityArr = try context.fetch(NowPlayingEntity.fetchRequest())
            
            self.playingTable.reloadData()

        } catch {
            print("Error reloading data")
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
        // TODO
        let detailController = segue.destination as! MovieDetailController
        detailController.selectedMovie = sender as! Movie
        
    }

    // MARK: - Table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.entityArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MAIN_MOVIE_CELL")! as! MainMovieCell

        let item = self.entityArr[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.imageView?.image = NowPlayingController.placeholderImage

        if let path = item.posterPath, let config = self.config {
            let imageEndPoint = EndPoint.image(basePath: config.images.secureBaseUrl, size: config.images.defaultLogoSize, imageName: path)
            cell.scheduleImageLoading(fromURL: imageEndPoint.url)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // TODO
//        let movie = self.movies[indexPath.row]
//
//        self.performSegue(withIdentifier: "SHOW_DETAIL_SEGUE", sender: movie)

    }

    
}
