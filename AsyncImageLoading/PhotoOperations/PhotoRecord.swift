import UIKit

public protocol PhotoRecord {
    var name: String { get set }
    var url: URL { get set }
    var state: PhotoRecordState { get set }
    var image: UIImage { get set }
}
