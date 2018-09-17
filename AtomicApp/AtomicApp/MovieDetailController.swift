//
//  MovieDetailController.swift
//  AtomicApp
//
//  Created by Omar Gomez on 5/29/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import UIKit

class MovieDetailController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var writerLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    
    var selectedMovie: Movie!
    var movieDetail: MovieDetail!
    var movieCrew: Crew!
    let config = AppDelegate.configuration!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        statusLabel.isHidden = false
        contentView.isHidden = true
        
        statusLabel.text = "Loading Data..."
        
        loadData { [weak self] (detail, crew) in
            
            guard let strongSelf = self,
            let theDetail = detail,
            let theCrew = crew else {
                return
            }
            
            strongSelf.movieDetail = theDetail
            strongSelf.movieCrew = theCrew
            
            strongSelf.statusLabel.isHidden = true
            strongSelf.contentView.isHidden = false
            strongSelf.setupContent()

        }
        
    }
    
    private func loadData( completion: @escaping (MovieDetail?, Crew?) -> Void ) {
        
        let group = DispatchGroup()
        
        group.enter()
        var detail: MovieDetail?
        URLSession.shared.doJsonTask(forURL: EndPoint.movie(movieId: self.selectedMovie.id).url) { (data, error) in
            
            defer {
                group.leave()
            }
            
            guard let theData = data else {
                debugPrint(error ?? NSError.UNKNOWN)
                return
            }
            
            debugPrint(theData)
            detail = MovieDetail(fromJson: theData)
            debugPrint(detail)
            

        }
        
        group.enter()
        var crew: Crew?
        URLSession.shared.doJsonTask(forURL: EndPoint.credits(movieId: self.selectedMovie.id).url) { (data, error) in
            
            defer {
                group.leave()
            }
            
            guard let theData = data else {
                debugPrint(error ?? NSError.UNKNOWN)
                return
            }

            debugPrint(theData)
            crew = Crew(fromJson: theData)
            debugPrint(crew)

        }
        
        group.notify(queue: .main) {
            
            completion(detail, crew)
        }
        
        
    }
    
    private func setupContent() {
        
        self.titleLabel.text = String(format: "%@ (%@)", self.movieDetail.title, self.movieDetail.releaseDate.formated(as: "yyyy")! )
        self.subtitleLabel.text = String(format: "%@ | %@", self.movieDetail.genres.joined(separator: ", "), self.movieDetail.releaseDate.formated(as: "dd-MMMM-yyyy")! )
        self.summaryLabel.text = self.movieDetail.overview
        
        let directors = self.movieCrew.getDirectors()
        self.directorLabel.text = "Director: \( directors.joined(separator: ", ") )"
        
        let writers = self.movieCrew.getWriters()
        self.writerLabel.text = "Writers: \( writers.joined(separator: ", ") )"
        
        let cast = self.movieCrew.getMainCast()
        self.starsLabel.text = "Stars: \( cast.joined(separator: ", ") )"
        

        self.loadPoster(forPath: self.movieDetail.backdropPath) { [weak self] (image) in
            
            guard let strongSelf = self,
            let theImage = image else {
                return
            }
            
            strongSelf.posterImage.image = theImage

        }

    }
    
    private func loadPoster(forPath path: String, completion: @escaping (UIImage?) -> Void ) {
        
        let imageEndPoint = EndPoint.image(basePath: self.config.images.secureBaseUrl, size: self.config.images.defaultPosterSize, imageName: path)
        debugPrint(imageEndPoint.url)
        URLSession.shared.doImageTask(fromURL: imageEndPoint.url) { (image, error) in
            
            DispatchQueue.main.async {
                
                completion(image)
            }
        }
    }
    
}
