import UIKit

public class ImageDownloader: Operation {
    
    public var photoRecord: PhotoRecord
    
    init(_ photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    override public func main() {
        
        if isCancelled { return }
        
        Cache.shared.getImageFromURL(photoRecord.url) { (image) in
            if let image = image {
                self.photoRecord.image = image
                self.photoRecord.state = .downloaded
            } else {
                self.photoRecord.state = .failed
                self.photoRecord.image = UIImage(named: "Failed") ?? UIImage()
            }
        }
        
    }
    
}
