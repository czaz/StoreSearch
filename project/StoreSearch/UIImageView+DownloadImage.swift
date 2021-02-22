//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by Wm. Zazeckie on 2/21/21.
//

import UIKit


extension UIImageView {
    
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        // 1 Obtained refernce to the shared URLSession, we then create a download task. Saving the downloaded file to a temporary location on disk.
        let downloadTask = session.downloadTask(with: url,completionHandler: { [weak self] url, response, error in
      // 2 Inside of the completion hanlder of the download task, the URL given to us can be used to find the downloaded file, this URL points to a local file rather than an internet address. Before moving on, we check that error is nil.
      if error == nil, let url = url,
         let data = try? Data(contentsOf: url), // 3 With the local URL, we load the file into a Data object, creating an image from it.
         let image = UIImage(data: data) {

        // 4 We have the image, we can then put it into the UIImageView's image property.
        DispatchQueue.main.async {
            if let weakSelf = self {
                weakSelf.image = image
            
        }
    }
}
})
// 5 After creating the download task, we execute resume() to start it, followed by returning the URLSessionDownloadTask object to the caller. We return it since it gives the app the opportunity to call cancel() on the download task if necessary.
downloadTask.resume()
    return downloadTask
  }
    // we are able to now call loadIMage(url:) on any UIImageView object
}

