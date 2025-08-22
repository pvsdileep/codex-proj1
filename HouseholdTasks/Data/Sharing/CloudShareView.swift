import SwiftUI
import CloudKit
import CoreData

struct CloudShareView: UIViewControllerRepresentable {
    let object: NSManagedObject

    func makeUIViewController(context: Context) -> UICloudSharingController {
        let controller = UICloudSharingController { _, completion in
            let container = PersistenceController.shared.container
            container.share([object], to: nil) { objectIDs, share, ckContainer, error in
                completion(share, ckContainer, error)
            }
        }
        controller.availablePermissions = [.allowReadWrite, .allowPrivate]
        return controller
    }

    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {}
}
