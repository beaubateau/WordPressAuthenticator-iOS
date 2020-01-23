import MessageUI
import UIKit

/// App selector that selects an app from a list and opens it
/// Note: it's a wrapper of UIAlertController (which cannot be sublcassed)
class AppSelector {
    // the action sheet that will contain the list of apps that can be called
    let alertController: UIAlertController

    /// initializes the picker with a dictionary. Initialization will fail if an empty/invalid app list is passed
    /// - Parameters:
    ///   - appList: collection of apps to be added to the selector
    ///   - defaultAction: default action, if not nil, will be the first element of the list
    init?(with appList: [String: String], defaultAction: UIAlertAction? = nil) {
        /// inline method that builds a list of app calls to be inserted in the action sheet
        func buildAppCalls(from appList: [String: String]) -> [UIAlertAction]? {
            guard !appList.isEmpty else {
                return nil
            }
            var actions = [UIAlertAction]()
            for (name, urlString) in appList {
                guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
                    continue
                }
                actions.append(UIAlertAction(title: AppSelectorTitles(rawValue: name)?.localized ?? name, style: .default) { action in
                    UIApplication.shared.open(url)
                })
            }
            guard !actions.isEmpty else {
                return nil
            }
            //sort the apps alphabetically
            actions = actions.sorted { $0.title ?? "" < $1.title ?? "" }
            actions.append(UIAlertAction(title: AppSelectorTitles.cancel.localized, style: .cancel, handler: nil))

            if let action = defaultAction {
                actions.insert(action, at: 0)
            }
            return actions
        }

        guard let appCalls = buildAppCalls(from: appList) else {
            return nil
        }

        alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        appCalls.forEach {
            alertController.addAction($0)
        }
    }
}


/// Email Clients Selector
extension AppSelector {
    /// initializes the picker with a plist file in a specified bundle
    convenience init?(with plistFile: String, in bundle: Bundle, defaultAction: UIAlertAction? = nil) {

        guard let plistPath = bundle.path(forResource: plistFile, ofType: "plist"),
            let availableApps = NSDictionary(contentsOfFile: plistPath) as? [String: String] else {
            return nil
        }
        self.init(with: availableApps, defaultAction: defaultAction)
    }

    /// Convenience init for a picker that calls supported email clients apps, defined in EmailClients.plist
    convenience init?() {
        guard let bundlePath = Bundle(for: type(of: self))
            .path(forResource: "WordPressAuthenticatorResources", ofType: "bundle"),
            let wpAuthenticatorBundle = Bundle(path: bundlePath) else {
                return nil
        }

        let plistFile = "EmailClients"
        var defaultAction: UIAlertAction?

        // if available, prepend apple mail
        if MFMailComposeViewController.canSendMail(), let url = URL(string: "message://") {
            defaultAction = UIAlertAction(title: AppSelectorTitles.appleMail.localized, style: .default) { action in
                UIApplication.shared.open(url)
            }
        }
        self.init(with: plistFile, in: wpAuthenticatorBundle, defaultAction: defaultAction)
    }
}


/// Email picker presenter
class LinkMailPresenter {
    /// Presents the available mail clients in an action sheet. If none is available,
    /// Falls back to Apple Mail and opens it.
    /// If not even Apple Mail is available, presents an alert to check your email
    /// - Parameters:
    ///   - viewController: the UIViewController that will present the action sheet
    ///   - appSelector: the app picker that contains the available clients. Nil if no clients are available
    ///                  reads the supported email clients from EmailClients.plist
    func presentEmailClients(on viewController: UIViewController,
                             appSelector: AppSelector? = AppSelector()) {

        guard let picker = appSelector else {
            // fall back to Apple Mail if no other clients are installed
            if MFMailComposeViewController.canSendMail(), let url = URL(string: "message://") {
                UIApplication.shared.open(url)
            } else {
                showAlertToCheckEmail(on: viewController)
            }
            return
        }
        viewController.present(picker.alertController, animated: true)
    }

    private func showAlertToCheckEmail(on viewController: UIViewController) {
        let title = NSLocalizedString("Please check your email", comment: "Alert title for check your email during logIn/signUp.")
        let message = NSLocalizedString("Please open your email app and look for an email from WordPress.com.", comment: "Message to ask the user to check their email and look for a WordPress.com email.")

        let alertController =  UIAlertController(title: title,
                                                 message: message,
                                                 preferredStyle: .alert)
        alertController.addCancelActionWithTitle(NSLocalizedString("OK",
                                                                   comment: "Button title. An acknowledgement of the message displayed in a prompt."))
        viewController.present(alertController, animated: true, completion: nil)
    }
}


/// Localizable app selector titles
enum AppSelectorTitles: String {
    case appleMail
    case gmail
    case airmail
    case msOutlook
    case spark
    case yahooMail
    case fastmail
    case cancel

    var localized: String {
        switch self {
        case .appleMail:
            return NSLocalizedString("Mail (Default)", comment: "Label for Apple Mail as default email client")
        case .gmail:
            return NSLocalizedString("Gmail", comment: "Gmail")
        case .airmail:
            return NSLocalizedString("Airmail", comment: "Airmail")
        case .msOutlook:
            return NSLocalizedString("Microsoft Outlook", comment: "Microsoft Outlook")
        case .spark:
            return NSLocalizedString("Spark", comment: "Spark")
        case .yahooMail:
            return NSLocalizedString("Yahoo Mail", comment: "Yahoo Mail")
        case .fastmail:
            return NSLocalizedString("Fastmail", comment: "Fastmail")
        case .cancel:
            return NSLocalizedString("Cancel", comment: "Cancel")
        }
    }
}
