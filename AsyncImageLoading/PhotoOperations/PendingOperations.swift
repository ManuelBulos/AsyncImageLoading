import UIKit

class PendingOperations {
    
    public static var shared = PendingOperations()
    
    public lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    
    public lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    public func addOperation(_ operation: Operation) {
        downloadQueue.addOperation(operation)
    }
    
    public func suspendAllOperations() {
        downloadQueue.isSuspended = true
    }
    
    public func resumeAllOperations() {
        downloadQueue.isSuspended = false
    }
    
}
