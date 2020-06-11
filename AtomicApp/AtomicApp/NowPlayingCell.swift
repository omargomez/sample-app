//
//  NowPlayingCell.swift
//  AtomicApp
//
//  Created by Omar Eduardo Gomez Padilla on 6/9/20.
//  Copyright © 2020 Omar Gómez. All rights reserved.
//

import UIKit

class NowPlayingCell: UICollectionViewCell {
    
    static let reuseId = String(describing: NowPlayingCell.self)
    
    @IBOutlet weak var movieTitle: UILabel!
    
    @IBOutlet weak var posterImage: UIImageView!
    weak var imageTask: URLSessionTask!
    
    func scheduleImageLoading(fromURL url: URL) {
        
        Logger.shared.debug("Loading image from \(url)")
        var task: URLSessionTask?
        task = URLSession.shared.createImageTask(fromURL: url) { [weak self] (image, error) in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let theImage = image else {
                Logger.shared.error("Error loading image", error ?? NSError.UNKNOWN)
                return
            }
            
            DispatchQueue.main.async {
                
                guard let currentTask = strongSelf.imageTask,
                    task == currentTask else {
                        Logger.shared.debug("Too old!!!")
                        return
                }
                
                // If this is canceled the this won't happen
                strongSelf.posterImage?.image = theImage
                strongSelf.imageTask = nil
                strongSelf.setNeedsLayout()
                Logger.shared.debug("Loaded image from \(url)")
                
            }
            
        }
        
        self.imageTask = task
        self.imageTask.resume()
        
    }
    
    override func prepareForReuse() {
        
        if let task = self.imageTask {
            if task.state == .running {
                Logger.shared.debug("Cancelling task for \(task)")
                task.cancel()
            }
        }
        
        self.movieTitle?.text = nil
        self.posterImage?.image = nil
        
    }

}
