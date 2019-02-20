import UIKit
import CoreImage

class ViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: view.bounds, style: .grouped)
        tableView.rowHeight = 150
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
        return tableView
    }()
    
    lazy var alertController: UIAlertController = {
        let alertController = UIAlertController(title: "Oops!", message: "There was an error fetching photo details.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        return alertController
    }()
    
    var photos: [PhotoRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Photos"
        self.view.addSubview(tableView)
        fetchPhotos()
    }
    
    func fetchPhotosFromServer(completion: @escaping ([String: String]?) -> Void) {
        let dataSourceURL = URL(string:"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")!
        let request = URLRequest(url: dataSourceURL)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let task = URLSession(configuration: .default).dataTask(with: request) { data, response, error in
            
            if let data = data {
                do {
                    let propertyList = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
                    if let datasourceDictionary = propertyList as? [String: String] {
                        completion(datasourceDictionary)
                    } else {
                        completion(nil)
                    }
                } catch {
                    completion(nil)
                }
            }
            
            if error != nil {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion(nil)
            }
        }
        task.resume()
        
    }
    
    func fetchPhotos() {
        fetchPhotosFromServer { (datasourceDictionary) in
            if let datasourceDictionary = datasourceDictionary {
                for (name, value) in datasourceDictionary {
                    let url = URL(string: value)
                    if let url = url {
                        let photoRecord = Item(name: name, url: url)
                        self.photos.append(photoRecord)
                    }
                }
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.tableView.reloadData()
                }
            } else {
                self.present(self.alertController, animated: true, completion: nil)
            }
        }
    }
    
    func managePhotoRecordStateForCell(_ cell: UITableViewCell, photoDetails: PhotoRecord, indexPath: IndexPath) {
        switch (photoDetails.state) {
        case .downloaded:
            cell.stopActivityIndicator()
        case .failed:
            cell.stopActivityIndicator()
            cell.textLabel?.text = "Failed to load"
        case .new:
            cell.startActivityIndicator()
            startOperations(for: photoDetails, at: indexPath)
        }
    }
    
    func startOperations(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
        if !tableView.isDragging && !tableView.isDecelerating {
            switch (photoRecord.state) {
            case .new:
                startDownload(for: photoRecord, at: indexPath)
            case .downloaded:
                reloadRows(at: indexPath)
            default:
                NSLog("do nothing")
            }
        }
    }
    
    func startDownload(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
        
        guard PendingOperations.shared.downloadsInProgress[indexPath] == nil else { return }
        
        let downloader = ImageDownloader(photoRecord)
        
        downloader.completionBlock = {
            
            if downloader.isCancelled { return }
            
            DispatchQueue.main.async {
                PendingOperations.shared.downloadsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        
        PendingOperations.shared.downloadsInProgress[indexPath] = downloader
        PendingOperations.shared.addOperation(downloader)
    }
    
    func reloadRows(at indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    func loadImagesForOnscreenCells() {
        
        if let pathsArray = tableView.indexPathsForVisibleRows {
            
            let allPendingOperations = Set(PendingOperations.shared.downloadsInProgress.keys)
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathsArray)
            
            toBeCancelled.subtract(visiblePaths)
            
            var toBeStarted = visiblePaths
            toBeStarted.subtract(allPendingOperations)
            
            for indexPath in toBeCancelled {
                if let pendingDownload = PendingOperations.shared.downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                
                PendingOperations.shared.downloadsInProgress.removeValue(forKey: indexPath)
            }
            
            for indexPath in toBeStarted {
                let recordToProcess = photos[indexPath.row]
                startOperations(for: recordToProcess, at: indexPath)
            }
        }
    }
    
}

extension ViewController: UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        PendingOperations.shared.suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForOnscreenCells()
            PendingOperations.shared.resumeAllOperations()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForOnscreenCells()
        PendingOperations.shared.resumeAllOperations()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        cell.addActivityIndicator()
        
        let photoDetails = photos[indexPath.row]
        cell.genericSetup(text: photoDetails.name, image: photoDetails.image)
        
        managePhotoRecordStateForCell(cell, photoDetails: photoDetails, indexPath: indexPath)
        return cell
    }
    
}
