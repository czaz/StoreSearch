//
//  ViewController.swift
//  StoreSearch
//
//  Created by Wm. Zazeckie on 2/19/21.
//

import UIKit

class SearchViewController: UIViewController {

    
    
    // outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
    // instance variables
    
    // array / the data model for the table
    var searchResults = [SearchResult]()
    
    // flag variable, false by default to not have the default Nothing found message displayed at start of search
    var hasSearched = false
    
    var isLoading = false // flag for letting the table view's data source know the app is currently in a state of downloading data from the server.
    
    // optional since there wont be a data task until the user performs a search
    var dataTask: URLSessionDataTask?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        // Configures the two starting (2) table cells to no longer display underneath the search bar, but after it
        // 64 point margin top, -20 for status bar, and 44 for Search Bar
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        
        // creating a new variable to hold an UINib named SearchResultCell
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        // registering in the tableview the cellNib that is using the identifier SearchResultCell
        tableView.register(cellNib, forCellReuseIdentifier:
                            TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName:
                            TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier:
                            TableView.CellIdentifiers.nothingFoundCell)
        
        // registering the LoadinCell nib in viewDidLoad()
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell,
                        bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier:
                            TableView.CellIdentifiers.loadingCell)
        
        
        searchBar.becomeFirstResponder() // makes the search bar immediatly visible upon app launch
        // changing the color of the segment in its normal, selected, and highlighted state
        let segmentColor = UIColor(red: 10/255, green: 80/255, blue: 80/255, alpha: 1)
        let selectedTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white]
        let normalTextAttributes =
            [NSAttributedString.Key.foregroundColor: segmentColor]
        segmentedControl.selectedSegmentTintColor = segmentColor

        
        segmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .highlighted)
    }

    
    struct TableView { // creating a struct holding a secondary struct named CellIdentifiers that contains a constant named searchResultCell with th the value "SearchResultCell"
        // this is helpful since if we need to rename the reuse identifier, we would have to change its name in all places it occurs, but now we only need to limit those changes to one spot. Is the same for both constants
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell = "LoadingCell"
        }
    }
    
    
    
    
    // MARK:- Helper Methods
    
    // builds a URL string via placing the search text behind the "term=" parameter, then turning this string into a URL object
    func iTunesURL(searchText: String, category: Int) -> URL {
       
        let kind: String
        switch category { // determining via the category index, we turn the the number from the index into a string, kind
            case 1: kind = "musicTrack"
            case 2: kind = "software"
            case 3: kind = "ebook"
            default: kind = ""
        }
        
        
        
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! // using add percent encoding method to create a string where all special characters are escaped, allowing the user to now type into the search bar multiple words. We also set a limit of 200 to the URL
        let urlString = "https://itunes.apple.com/search?" + // inserting encodedText and kind into the string interpolation, into a urlString
            "term=\(encodedText)&limit=200&entity=\(kind)"
            
        let url = URL(string: urlString)
        return url!
    }
    


    
    func parse(data: Data) -> [SearchResult] {
        do{
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from:data) // using a JSONDecoder object to convert response data from the server to a temporary ResultArray object which the results property is extracted
            return result.results
        }
        catch {
            print("JSON Error: \(error)")
            return []
        }
    }
    
    
    // method that displays an alert to handle any potential errors
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...",
        message: "There was an error accessing the iTunes Store." + " Please try again.", preferredStyle: .alert)
     
        let action = UIAlertAction(title: "OK", style: .default,
                                   handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
}

// MARK:- Extensions
// this extensions handles all search bar related delegate methods
extension SearchViewController: UISearchBarDelegate {
    
    // this function is executed when the user taps the Search button the keyboard
    
    // is it as of right now putting some fake data into the array and displaying it using the table
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
        if !searchBar.text!.isEmpty { // everything happens in the brackets when the user actually inputs something into the searchBar
        searchBar.resignFirstResponder() // tells searchBar to no longer listen for keyboard input (Hiding itself)
        
            
            dataTask?.cancel() // if there's an active data task, cancel it. This way no old searches can ever get in the way of the new search.
            
        isLoading = true // reloading the table view to make the Loading... cell appear
        tableView.reloadData()
            
        hasSearched = true
        searchResults = [] // istantiate a new String array, thus replacing the contents of searchResults property with it

            let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex) // text from the search bar is sent to iTunesURL helper method, the returned URL is then assigned to constant named url
            
            let session = URLSession.shared   // Getting a shared URLSession instance which uses the default configuration with respect to catching, cookies, and other web stuff
            
             dataTask = session.dataTask(with: url,          // Creating a data task, used for fetching the contents of a given URL. The code from the completion handler will be executed when the data task has received a response from the server
                                            completionHandler: {data, response, error in
                                                
                                                // inside the closure. Three parameters: data, response, and error. Since they are all options, there able to nil and have to be unwrapped before use
                                                if let error = error as NSError?, error.code == -999 { // If a problem arises, error contains an Error object with the error code -999 describing what went wrong and the search is then canceled via the return keyword
                                                return
                                                }
                                                else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 { // casting the URLResponse the proper type, then looking at its statusCode property, which will be true if it is 200
                                                    
                                                    // Unwraps the optional object from the data parameter, then calls parse(data:) to turn the contents of the dictionary into SearchResult objects.
                                                    if let data = data {
                                                        self.searchResults = self.parse(data: data)
                                                        self.searchResults.sort(by: <) // Sorting the results via the function named <
                                                        DispatchQueue.main.async {
                                                            self.isLoading = false
                                                            self.tableView.reloadData()
                                                        }
                                                        return
                                                    }
                                                }
                                                else {
                                                  print("Failure! \(response!)")
                                                }
                                                
                                                // code here at the end of the closure for if something went wrong
                                                DispatchQueue.main.async {
                                                    self.hasSearched = false
                                                    self.isLoading = false
                                                    self.tableView.reloadData() // Is here to get refresh the table, to rid of the Loading... * indicator
                                                    self.showNetworkError()   // Callling showNetworkError() to show alert to user letting them know about the problem
                                                }
                                              
                                            })
            dataTask?.resume()
            
              }
            }
        
    

    // gives the search bar the ability to indicate its top position
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        
        return .topAttached
    }
    
   
}
    






// this extension will handle all table view related delegate methods
extension SearchViewController: UITableViewDelegate,
                                UITableViewDataSource {
    
    
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   // creates a single cell that will display (based on cellForRowAt: ) (Nothing Found). This is needed since otherwise the user would see nothing
    // this singular row lets them know now there were no results found. If the search button hasnt been pressed, then return 0 rows (display 0 rows)
   
    if isLoading {
        return 1 // need a row to show the user the table is loading
    }
    else if !hasSearched {
        return 0
    }
   else if searchResults.count == 0 {
        return 1 // need a row to display a table was not found
    }
    else {
    
    return searchResults.count
    }
}
    
    
    
    
    // returning the number of rows to display based on the contents of the searchResults array, then creating a UITableViewCell (by hand) to display the table rows
    
func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // if statement returning an instance of the new loading... cell. It also looks up the UIActivityIndicatorView by its tag and tells the spiiner to start animating
    if isLoading {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
        let spinner = cell.viewWithTag(100) as!
            UIActivityIndicatorView
        
        spinner.startAnimating()
        return cell
    } else if searchResults.count == 0 { // if no results were found display
        return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell,
                                             for: indexPath)
    }
    // if results were found aka there are more than  0 results, then do :
    else {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, // using this variable we can put the name and artist name from the search result into the proper labels
                                                 for: indexPath) as! SearchResultCell
        let searchResult = searchResults[indexPath.row]
        cell.configure(for: searchResult)
 
        return cell
        
    }
    
}
    
    // these two methods makes the row that is tapped to no longer stay selected
    // tableView(didSelectRowAt: ) will deselect the row with an animation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // willSelectRowAt makes sure the user can only select rows when there are actual search results
    func tableView(_ tableView: UITableView,
    willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
    if searchResults.count == 0 || isLoading { // users wont be able to select the Nothing Found cell as well as the Loading... cell
        return nil
    } else {
        return indexPath
      }
    }
    

}


    
    



