import UIKit

@objc(HasDefaultViewModelProviderFactory)
public protocol HasDefaultViewModelProviderFactory {
    @objc func getDefaultViewModelProviderFactory() -> ViewModelProviderFactory
}
