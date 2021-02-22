//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Wm. Zazeckie on 2/20/21.
//

import UIKit

// this file accompanies the nib file named SearchResultCell.xib


class SearchResultCell: UITableViewCell {
    
    // outlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    // instance variables
    var downloadTask: URLSessionDownloadTask?
    
    // is called after the cell object has been loaded from the nib, but before the cell is added to the table view
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // tapping a row will instead of being highlighted grey, will now be teal-colored
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        
        selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // If the image is already downloaded, the pending download of that already downloaded image is cancelled
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    
    
    // MARK:- Public Methods
    
    func configure(for result: SearchResult) {
        nameLabel.text = result.name
        
        
        if result.artist.isEmpty {
            artistNameLabel.text = "Unknown"
        }
        else {
            artistNameLabel.text = String(format: "%@ (%@)",
                                          result.artist, result.type)
        }
        
        // telling UIImageView to load the image from imageSmall and to place it in the cell's image view. While the real artwork is downloading, the image view displays a placeholder image, the same one from the nib for this cell
        artworkImageView.image = UIImage(named: "Placeholder")
        if let smallURL = URL(string: result.imageSmall) {
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
        
        
        
    }
    
    

}
