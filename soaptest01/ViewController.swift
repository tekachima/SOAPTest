import UIKit

// This is based on following example:
// http://webindream.com/soap-with-swift/

// Use NSURLConnectionDelegate and NSXMLParserDelegate to get all relevant
// events of NSURLConnection object and NSXMLParser object to return their
// actions to this file...
class ViewController: UIViewController, UITextFieldDelegate, URLSessionDataDelegate, URLSessionDelegate, URLSessionTaskDelegate, XMLParserDelegate {
    
    // Mutable data object is created as an object (not Nil).
    var mutableData:NSMutableData  = NSMutableData()
    
    var currentElementName:NSString = ""
    
    @IBOutlet weak var MyFahrenheitTextField: UITextField!
    @IBOutlet weak var myCelsiusTextField: UITextField!
    
    @IBAction func MyConversionAction(_ sender: UIButton) {
        // First we need to determined what we are going to send as SOAP message
        let MyInputValue = myCelsiusTextField.text
        
        // This is the actual soap message - see also following:
        // http://www.w3schools.com/webservices/tempconvert.asmx?op=CelsiusToFahrenheit
        
        var MySOAPMessage = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><CelsiusToFahrenheit xmlns='https://www.w3schools.com/xml/'><Celsius>"
        
        MySOAPMessage += MyInputValue!
        MySOAPMessage += "</Celsius></CelsiusToFahrenheit></soap:Body></soap:Envelope>"
        
        print("SOAP Message packet \(MySOAPMessage)")
        
        
        // The SOAP message must be sent to a suitable web service
        // This web service has URI which is located with URL
        let urlString = "https://www.w3schools.com/xml/tempconvert.asmx"
        let url = NSURL(string: urlString)
        
        // SOAP message length equals number of elements within SOAP message
        // This is actually number of characters to be sent within message
        let SOAPMsgLength = String(MySOAPMessage.characters.count)
        
        // Create actual SOAP request by adding information that is needed in header
        // Values must match the SOAP service's values - following values are "typical"
        let MyRequest = NSMutableURLRequest(url: url! as URL)
        MyRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        MyRequest.addValue(SOAPMsgLength, forHTTPHeaderField: "Content-Length")
        MyRequest.httpMethod = "POST"
        MyRequest.httpBody = MySOAPMessage.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        // Following iOS 9 the NSURLConnection was changed to NSURLSession
        // Following code creates a NSURLSession that uses default queue
        // of iOS phone  and sets delegate to this class so task's returning
        // events are handled in this file.
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration:config, delegate: self, delegateQueue: OperationQueue.main)
        // This is typical asynchronic data fetching request
        let MyTask = session.dataTask(with: MyRequest as URLRequest)
        MyTask.resume()
    }
    
    // This function assumes a HTTPS connection with authorization.
    // This is NOT used in example but it serves as basic implemtentation
    // for authorization issues.
    /*
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("NSURLSessionDelegate - didReceiveChallenge")
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust && challenge.protectionSpace.host == "w3schools.com" {
            NSLog("authorised")
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            challenge.sender!.use(credential, for: challenge)
        } else {
            NSLog("No authorization")
            challenge.sender!.performDefaultHandling!(for: challenge)
        }
        
    }
    */

    
    // This function is fired if application is working in background
    // and URLSession is finished (returns data or fails)
    // This function is not fired in this example
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print("URLSessionDidFinishEventsForBackgroundURLSession")
        
    }
    
    // Error message handling for failure in internet connections
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("error of \(error!)")
    }
    
    // This function is fired when target web service has received successfully
    // and returns a message that SOAP request has been sent successfully
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("didReceiveResponse")
        mutableData.length = 0
        // This line sets iOS phone to receive actual data
        // This command MUST be set.
        //
        // Note: See also that plist.info has set exception domain as
        // with NSTemporaryExceptionAllowsInsecureHTTPLoads value as TRUE
        // (not setting it creates -1100 errors in NSURLDomain)
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    // This function is fired when actual data has been received.
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("didReceiveData")
        // this stores the data to this class for later handling
        mutableData.append(data)
        
        // This sets the NSXMLParser which uses NSXMLParserDelegate
        // to set necessary functions for going through parsed
        // data and find out actual data snippts. See below for functions.
        let xmlParser = XMLParser(data: mutableData as Data)
        xmlParser.delegate = self
        xmlParser.parse()
        xmlParser.shouldResolveExternalEntities = true
    }
    
    // This function is ALWAYS fired!
    // didCompleteWithError has value nil if there are no errors in SOAP request.
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            print("No errors in download")
        }
        else {
            print("error of \(error!)")
        }
    }
    
    // Following four functions are used to parsing through data to seek out what SOAP
    // return message from web service shows.
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        print(elementName)
        currentElementName=elementName as NSString;
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print(elementName)
    }
    
    // foundCharacters returns actual value set within XML structure for
    // any particular element.
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElementName == "CelsiusToFahrenheitResult" {
            print(string)
            MyFahrenheitTextField.text = string
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
    }

    class ViewController: UIViewController {

        override func viewDidLoad() {
            super.viewDidLoad()
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
    }
}
