//
//  MainMovieCell.swift
//  AtomicApp
//
//  Created by Omar Gomez on 6/19/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import UIKit

class MainMovieCell: UITableViewCell {

    weak var imageTask: URLSessionTask!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

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
                strongSelf.imageView?.image = theImage
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
        
        self.textLabel?.text = nil
        self.imageView?.image = nil
        
    }
    
}
