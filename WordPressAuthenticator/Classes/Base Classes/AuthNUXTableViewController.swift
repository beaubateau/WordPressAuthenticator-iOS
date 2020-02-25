// MARK: - NUXTableViewController
/// Base class to use for NUX view controllers that are also a table view controller
/// Note: shares most of its code with NUXViewController and NUXCollectionViewController.
open class AuthNUXTableViewController: UITableViewController, AuthNUXViewControllerBase, UIViewControllerTransitioningDelegate {
    // MARK: NUXViewControllerBase properties
    /// these properties comply with NUXViewControllerBase and are duplicated with NUXTableViewController
    public var helpNotificationIndicator: WPHelpIndicatorView = WPHelpIndicatorView()
    public var helpButton: UIButton = UIButton(type: .custom)
    public var dismissBlock: ((_ cancelled: Bool) -> Void)?
    public var loginFields = LoginFields()
    open var sourceTag: WordPressSupportSourceTag {
        get {
            return .generalLogin
        }
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.isPad() ? .all : .portrait
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setupHelpButtonIfNeeded()
        setupCancelButtonIfNeeded()
    }

    public func shouldShowCancelButton() -> Bool {
        return shouldShowCancelButtonBase()
    }
}
