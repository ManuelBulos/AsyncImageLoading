import UIKit

public class Item: PhotoRecord {
    
    public var name: String
    public var url: URL
    public var state = PhotoRecordState.new
    public var image: UIImage = UIImage(named: "Placeholder") ?? UIImage()
    
    init(name:String, url:URL) {
        self.name = name
        self.url = url
    }
    
}
