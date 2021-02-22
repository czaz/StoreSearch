//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Wm. Zazeckie on 2/19/21.
//

import Foundation

class ResultArray: Codable { // response wrapper, contains a results count, and an array of SearchResult objects.
    
    var resultCount = 0
    var results = [SearchResult]()
    
}


class SearchResult:Codable, CustomStringConvertible { // SearchResult class  supports the Codable protocol as well
    

  var artistName: String? = "" // properties trackName and artistName are optional
  var trackName: String? = ""
    
    var trackViewUrl: String? // optional properties for the variant keys
    var collectionName: String?
    var collectionViewUrl: String?
    var collectionPrice: Double?
    var itemPrice: Double?
    var itemGenre: String?
    var bookGenre: [String]?
    
  var kind: String? = ""
  
    // naming the SearchResults properties to be as you want them and not as the JSON data sets them
    var trackPrice: Double? = 0.0
    var currency = ""
    
    var imageSmall = ""
    var imageLarge = "" // removed storeURL property from enum and from class properties as well as genre property
    
   

    // a list of values and names for those values, we are specificying how you want the SearchResult properties matched to the JSON data
    enum CodingKeys: String, CodingKey { // added all the properties to CodingKeys enumartion
      case imageSmall = "artworkUrl60"
      case imageLarge = "artworkUrl100"
      case itemGenre = "primaryGenreName"
      case bookGenre = "genres"
      case itemPrice = "price"
      case kind, artistName, currency
      case trackName, trackPrice, trackViewUrl
      case collectionName, collectionViewUrl, collectionPrice
    }
    
    
    // MARK:- Computed properties
    
    var name:String {
    
    return trackName ?? collectionName ?? "" // checking if trackName is nil, if it is, move onto collectionName and do the same check, if both are nil we return an empty string.
                                                // if trackName is not nil, we return the unwrapped value of trackName
        
  }
    
    var description: String { // consists of the values for the name and atistName properties, since artistName is an optional, so we put "None" when that happens. We also have ?? , our nil-coalescing operator. It unwraps the variable from left to right. 
        return "Kind: \(kind ?? "None"), Name: \(name), Artist Name: \(artistName ?? "None")\n"
    }
    
    var storeURL: String {
        
      return trackViewUrl ?? collectionViewUrl ?? ""
        
    }
    
    var price: Double {
        
    return trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
        
    }
    
    var genre: String { // returns the genre for items that arent e-books , if an item is an e-book, the method combines all the genre values in the array seperated by commas, then returning the combined string
        
      if let genre = itemGenre {
        return genre
      }
      else if let genres = bookGenre {
    return genres.joined(separator: ", ")
        
      }
    return ""
    }
    
    // these properties are useful for displaying what type of product is being shown
    var type: String {
        let kind = self.kind ?? "audiobook"
        switch kind {
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default: break // if none of the above types arent determined, a string is returned saying "Unknown"

        }
        return "Unknown"
    }
    
    var artist: String {
        return artistName ?? ""
    }
}


// has the same code as the closure from the original sort, two SearchResult objects are called lhs and rhs, left-hand side, and right-hand side
func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}
