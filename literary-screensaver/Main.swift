import Foundation
import ScreenSaver


extension NSFont {

    /**
     Will return the best font conforming to the descriptor which will fit in the provided bounds.
     */
    static func bestFittingFontSize(for text: String, in bounds: CGRect, fontDescriptor: NSFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> CGFloat {
        let properBounds = CGRect(origin: .zero, size: bounds.size)
        var attributes = additionalAttributes ?? [:]

        let infiniteBounds = CGSize(width: bounds.width, height: CGFloat.infinity)
        var bestFontSize: CGFloat = 80

        for fontSize in stride(from: bestFontSize, through: 0, by: -1) {
            let newFont = NSFont(descriptor: fontDescriptor, size: fontSize)
            attributes[.font] = newFont

            let currentFrame = text.boundingRect(with: infiniteBounds, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)

            // TODO: Get rid of magic number
            if currentFrame.height <= properBounds.height - 250 {
                bestFontSize = fontSize
                break
            }
        }
        return bestFontSize
    }

    static func bestFittingFont(for text: String, in bounds: CGRect, fontDescriptor: NSFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> NSFont {
        let bestSize = bestFittingFontSize(for: text, in: bounds, fontDescriptor: fontDescriptor, additionalAttributes: additionalAttributes)
        return NSFont(descriptor: fontDescriptor, size: bestSize) ?? NSFont.systemFont(ofSize: bestSize)
    }
}

class Main: ScreenSaverView {
    var currQuote: Quote?
    var currTime: String?

    let THEME_MODE = "LIGHT"
    
    let COLOUR = [
        "LIGHT": [
            "BACKGROUND": NSColor(red:1.00,green:1.0,blue:1.0,alpha:1.00),
            "QUOTE": NSColor(red:105/255,green:105/255,blue:105/255,alpha:1.00),
            "TIME": NSColor(red:49/255,green:116/255,blue:183/255,alpha:1.00),
            "METADATA": NSColor(red:105/255,green:105/255,blue:105/255,alpha:1.00)
        ],
        "DARK": [
            "BACKGROUND": NSColor(red:0.31,green:0.31,blue:0.33,alpha:1.00),
            "QUOTE": NSColor(red:0.94,green:0.95,blue:0.94,alpha:1.00),
            "TIME": NSColor(red:1.00,green:0.55,blue:0.65,alpha:1.00),
            "METADATA": NSColor(red:1.00,green:1.00,blue:1.00,alpha:1.00)
        ]
    ]
    
    let FONT_QUOTE = NSFont(name: "Baskerville", size: 80) ?? NSFont.systemFont(ofSize: 80)
    let FONT_TIME = NSFont(name: "Baskerville", size: 80) ?? NSFont.systemFont(ofSize: 80)
    let FONT_TITLE = NSFont(name: "Baskerville", size: 54) ?? NSFont.systemFont(ofSize: 54)
    let FONT_METADATA = NSFont(name: "Baskerville-Italic", size: 54) ?? NSFont.systemFont(ofSize: 54)
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        
        // Only update the frame every 5 seconds.
        animationTimeInterval = 5
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    /**
     Retrieves the quote associated with the provided time. If one does not exists,
     nil is returned.
     
     - Parameter time: The time to retrieve the quote for, as a string formatted in HH:mm
     
     - Returns: the Quote struct associated with the given time, or nil if
                a quote does not exist.
     */
    func quote(for time: String) -> Quote? {
        guard currTime != time else { return currQuote }
        currTime = time

        let jsonTime = time.replacingOccurrences(of: ":", with: "_")
        let path = Bundle(for: type(of: self)).path(forResource: "times/\(jsonTime)", ofType: "json")
        guard let path else { return currQuote }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let contents = try? String(contentsOfFile: path, encoding: .utf8)
        if let jsonData = contents?.data(using: .utf8), let quotes = try? decoder.decode([Quote].self, from: jsonData) {
            return quotes.randomElement()
        }

        return currQuote
    }
    
    /**
     animateOneFrame is called every time the screen saver frame is to be updated, and
     is used to pull the appropriate quote.
     */
    override func animateOneFrame() {
        let time = getTime()
        self.currQuote = quote(for: time)
        
        // Tell Swift we want to use the draw(_:) method to handle rendering.
        self.setNeedsDisplay(self.frame)
    }
    
    /**
     getTime returns the current time as a formatted string.
     
     - Returns: A new string showing the current time, formatted as HH:mm
     */
    func getTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: date)
    }
    
    /**
     drawQuote draws the provided quote to the stage.
     
     - Parameter quote: The quote to draw onto the stage.
     */
    func draw(quote: Quote) {
        let QUOTE_PADDING_LEFT = 100;
        let QUOTE_PADDING_RIGHT = 100;
        let QUOTE_PADDING_TOP = 100;

        // Where frame.size is the resolution of the current screen (works for multi-monitor display)
        let QUOTE_BOX_WIDTH = Int(frame.size.width) - (QUOTE_PADDING_LEFT + QUOTE_PADDING_RIGHT);
        let QUOTE_BOX_HEIGHT = Int(frame.size.height) - QUOTE_PADDING_TOP;

        let rect = CGRect(x: QUOTE_PADDING_LEFT, y: 0, width: QUOTE_BOX_WIDTH, height: QUOTE_BOX_HEIGHT)
        let font = NSFont.bestFittingFont(for: quote.fullQuote, in: rect, fontDescriptor: FONT_QUOTE.fontDescriptor)

        let styledQuote = NSMutableAttributedString(string: quote.quoteFirst)
        styledQuote.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, styledQuote.length))
        styledQuote.addAttribute(NSAttributedString.Key.foregroundColor, value: COLOUR[self.THEME_MODE]!["QUOTE"]!, range: NSMakeRange(0, styledQuote.length))

        let styledTime = NSMutableAttributedString(string: quote.quoteTimeCase)
        styledTime.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, styledTime.length))
        styledTime.addAttribute(NSAttributedString.Key.foregroundColor, value: COLOUR[self.THEME_MODE]!["TIME"]!, range: NSMakeRange(0, styledTime.length))
        styledQuote.append(styledTime)

        let styledQuoteLast = NSMutableAttributedString(string: quote.quoteLast)
        styledQuoteLast.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, styledQuoteLast.length))
        styledQuoteLast.addAttribute(NSAttributedString.Key.foregroundColor, value: COLOUR[self.THEME_MODE]!["QUOTE"]!, range: NSMakeRange(0, styledQuoteLast.length))
        styledQuote.append(styledQuoteLast)

        styledQuote.draw(in: CGRect(x: QUOTE_PADDING_LEFT, y: 0, width: QUOTE_BOX_WIDTH, height: QUOTE_BOX_HEIGHT))
    }
    
    /**
     drawMetadata draws the provided title and author onto the stage.
     
     - Parameter title: The title of the book.
     - Parameter author: The author of the book.
     */
    func drawMetadata(title: String, author: String) {
        let properBounds = CGRect(origin: .zero, size: bounds.size)

        let styledMetadata = NSMutableAttributedString(string: "- \(title), ")
        styledMetadata.addAttribute(NSAttributedString.Key.foregroundColor, value: COLOUR[self.THEME_MODE]!["METADATA"]!, range: NSMakeRange(0, styledMetadata.length))
        styledMetadata.addAttribute(NSAttributedString.Key.font, value: FONT_TITLE, range: NSMakeRange(0, styledMetadata.length))

        let styledAuthor = NSMutableAttributedString(string: author)
        styledAuthor.addAttribute(NSAttributedString.Key.foregroundColor, value: COLOUR[self.THEME_MODE]!["METADATA"]!, range: NSMakeRange(0, styledAuthor.length))
        styledAuthor.addAttribute(NSAttributedString.Key.font, value: FONT_METADATA, range: NSMakeRange(0, styledAuthor.length))
        styledMetadata.append(styledAuthor)
        
        styledMetadata.draw(in: CGRect(x: 100.0, y: 50, width: properBounds.width, height: 150))
    }
    
    /**
     clearStage clears the stage, by filling it with a solid colour.
     */
    func clearStage() {
        COLOUR[self.THEME_MODE]!["BACKGROUND"]!.setFill()
        bounds.fill()
    }
    
    /**
     draw is called each time the screensaver should be re-rendered.
     */
    override func draw(_ rect: NSRect) {
        super.draw(rect)
        
        // Provide a default quote if one was not pulled for the current time.
        let quote = self.currQuote ?? Quote(time: "00:00",
                                            quoteFirst: "",
                                            quoteTimeCase: "",
                                            quoteLast: "You would measure time the measureless and the immeasurable.\nYou would adjust your conduct and even direct the course of your spirit according to hours and seasons.\nOf time you would make a stream upon whose bank you would sit and watch its flowing.\nYet the timeless in you is aware of life’s timelessness,\nAnd knows that yesterday is but today’s memory and tomorrow is today’s dream.",
                                            title: "The Prophet",
                                            author: "Khalil Gibran")

        clearStage()
        draw(quote: quote)
        drawMetadata(title: quote.title, author: quote.author)
    }
}
