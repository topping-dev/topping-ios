import UIKit

@objc(HasDefaultViewModelProviderFactory)
protocol HasDefaultViewModelProviderFactory {
    @objc func getDefaultViewModelProviderFactory() -> ViewModelProviderFactory
}
