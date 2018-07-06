
// MARK: - WordPress Credentials
//
public enum WordPressCredentials {

    /// WordPress.org Site Credentials.
    ///
    case wporg(username: String, password: String, xmlrpc: String, options: [AnyHashable: Any])

    /// WordPress.com Site Credentials.
    ///
    case wpcom(username: String, authToken: String, isJetpackLogin: Bool, multifactor: Bool)
}
