import Cocoa

struct Quote {
    var time: String
    var subquote: String
    var quote: String
    var title: String
    var author: String
}

struct Quote2: Decodable {
    var time: String
    var quoteFirst: String
    var quoteTimeCase: String
    var quoteLast: String
    var title: String
    var author: String
}

/*
 [
   {
     "time": "15:22",
     "quote_first": "",
     "quote_time_case": "3:22 P.M.",
     "quote_last": "\nAs Stone Aimes stepped off the elevator on the sixth floor, his mind was running through his options. This phone call had to be about Winston Bartlett. He was going to step up the pressure.",
     "title": "Syndrome",
     "author": "Thomas Hoover",
     "sfw": "yes"
   }
 ]
 */
