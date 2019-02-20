import UIKit

public extension UIImageView {
    
    func setImageFromURL(_ URL: URL, completion: @escaping () -> Void) {
        Cache.shared.getImageFromURL(URL) { (image) in
            DispatchQueue.main.async {
                self.image = image
                completion()
            }
        }
    }
    
    func setImageFromURL(_ URLstring: String, completion: @escaping () -> Void) {
        guard let URL = URL.init(string: URLstring) else { completion(); return }
        Cache.shared.getImageFromURL(URL) { (image) in
            DispatchQueue.main.async {
                self.image = image
                completion()
            }
        }
    }
    
}
