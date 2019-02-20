import UIKit

public extension UITableViewCell {
    
    func addActivityIndicator() {
        if accessoryView == nil {
            accessoryView = UIActivityIndicatorView(style: .gray)
        }
    }
    
    func startActivityIndicator() {
        guard let indicator = accessoryView as? UIActivityIndicatorView else { return }
        indicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        guard let indicator = accessoryView as? UIActivityIndicatorView else { return }
        indicator.stopAnimating()
    }
    
    func genericSetup(text: String = String(), image: UIImage = UIImage()) {
        textLabel?.text = text
        imageView?.image = image
    }
    
}
