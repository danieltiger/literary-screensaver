import Foundation
import ScreenSaver

class Main: ScreenSaverView {
    
    var latestTime: String = ""
    var quotes: [Quote] = []
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        
        // Only update the frame every 5 seconds.
        animationTimeInterval = 5
        
        // Read in the quotes CSV.
        self.quotes = readCSVToQuoteArray(fileName: "litclock_annotated")
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    /**
     Retrieves the quote associated with the provided time. If one does not exists,
     a default quote is returned.
     
     - Parameter time: The time to retrieve the quote for, as a string formatted in HH:mm
     
     - Returns: the Quote struct associated with the given time, or a default one if
                a quote does not exist.
     */
    func getQuoteFor(time: String) -> Quote {
        let quotesForTime = self.quotes.filter { $0.time == time }
        
        if quotesForTime.count > 0 {
            return quotesForTime[0]
        } else {
            return self.quotes[0]
        }
    }
    
    /**
     Reads a CSV file at a specified file path into an array of Quote structs.
     
     - Parameter fileName: The name of the CSV file to read.
     
     - Returns: an array of Quote structs
     */
    func readCSVToQuoteArray(fileName: String) -> [Quote]! {
        let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "csv")
        let contents = try? String(contentsOfFile: path!, encoding: .utf8)
        
        // Parse the CSV file into a 2D array, separating the rows by the newline character, and each
        // column by the pipe symbol.
        let parsedCSV: [[String]] = contents!.components(separatedBy: "\n").map{ $0.components(separatedBy: "|") }
        
        // Map each record to a new instance of Quote struct, returning the resulting array.
        return parsedCSV.map {Quote(time: $0[0], subquote: $0[1], quote: $0[2], title: $0[3], author: $0[4])}
    }
    
    /**
     animateOneFrame is called every time the screen saver frame is to be updated, and
     is used to re-draw the time/quote if required.
     */
    override func animateOneFrame() {
        let time = getTime()
        
        let quote = getQuoteFor(time: time)
        
        if time != self.latestTime {
            clearStage()
            drawText("\(quote.quote)\n\n\(quote.title)\n\(quote.author)")
        } else {
            self.latestTime = time
        }
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
     drawText draws a provided string to the bottom-left of the stage.
     
     - Parameter text: The text to draw onto the stage.
     */
    func drawText(_ text: String) {
        NSColor.gray.set()
        
        let font = NSFont(name: "Baskerville", size: 48)
        let attributes = [NSFontAttributeName: font]
        
        text.draw(in: CGRect(x: 100.0, y: 200.0, width: 1400, height: 700), withAttributes: attributes)
    }
    
    /**
     clearStage clears the stage, by filling it with a solid colour.
     */
    func clearStage() {
        NSColor(red:1.00,green:0.97,blue:0.89,alpha:1.00).setFill()
        NSRectFill(self.bounds)
    }
    
    /**
     draw is called to initialise the stage of the screen saver.
     */
    override func draw(_ rect: NSRect) {
        super.draw(rect)
        
        let time = getTime()
        
        clearStage()
        drawText(time)
    }
}
