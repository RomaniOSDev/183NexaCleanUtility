import Foundation

enum AppExternalLink: String {
    case privacyPolicy = "https://nexaclean183utility.site/privacy/200"
    case termsOfUse = "https://nexaclean183utility.site/terms/200"

    var url: URL? {
        URL(string: rawValue)
    }
}
