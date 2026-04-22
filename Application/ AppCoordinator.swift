import UIKit

@MainActor
final class AppCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    private let window: UIWindow
    private let diContainer: AppDIContainer

    // MARK: - Init

    init(
        window: UIWindow,
        diContainer: AppDIContainer
    ) {
        self.window = window
        self.diContainer = diContainer
    }

    // MARK: - Start

    func start() {

        if diContainer.makeAuthService().currentUserID != nil {
            showHome()
        } else {
            showAuth()
        }

        window.makeKeyAndVisible()
    }

    // MARK: - Auth

    private func showAuth() {

        let nav = UINavigationController()

        window.rootViewController = nav

        let authCoordinator = AuthCoordinator(
            navigationController: nav,
            authService: diContainer.makeAuthService()
        )

        authCoordinator.onAuthCompleted = { [weak self, weak authCoordinator] in
            guard let self, let authCoordinator else { return }

            self.removeChild(authCoordinator)
            self.showHome()
        }

        addChild(authCoordinator)
        authCoordinator.start()
    }

    // MARK: - Home

    private func showHome() {

        guard let uid = diContainer.makeAuthService().currentUserID else {
            showAuth()
            return
        }

        let nav = UINavigationController()
        window.rootViewController = nav

        let homeCoordinator = HomeCoordinator(
            navigationController: nav,
            diContainer: diContainer,
            uid: uid
        )

        homeCoordinator.onLogout = { [weak self, weak homeCoordinator] in
            guard let self, let homeCoordinator else { return }

            self.removeChild(homeCoordinator)
            self.showAuth()
        }

        addChild(homeCoordinator)
        homeCoordinator.start()
    }
}
