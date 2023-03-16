import Cocoa

struct Quote: Decodable {
    var time: String
    var quoteFirst: String
    var quoteTimeCase: String
    var quoteLast: String
    var title: String
    var author: String
}

extension Quote {
    var fullQuote: String {
        "\(quoteFirst) \(quoteTimeCase) \(quoteLast)"
    }
}
