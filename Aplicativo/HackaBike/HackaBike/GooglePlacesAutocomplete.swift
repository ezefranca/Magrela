//
//  GooglePlacesAutocomplete.swift
//  GooglePlacesAutocomplete
//
//  Created by Howard Wilson on 10/02/2015.
//  Copyright (c) 2015 Howard Wilson. All rights reserved.
//

import UIKit

public let ErrorDomain: String! = "GooglePlacesAutocompleteErrorDomain"

public struct LocationBias {
    public let latitude: Double
    public let longitude: Double
    public let radius: Int
    
    public init(latitude: Double = 0, longitude: Double = 0, radius: Int = 20000000) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
    
    public var location: String {
        return "\(latitude),\(longitude)"
    }
}

public enum PlaceType: CustomStringConvertible {
    case All
    case Geocode
    case Address
    case Establishment
    case Regions
    case Cities
    
    public var description : String {
        switch self {
        case .All: return ""
        case .Geocode: return "geocode"
        case .Address: return "address"
        case .Establishment: return "establishment"
        case .Regions: return "(regions)"
        case .Cities: return "(cities)"
        }
    }
}

public class Place: NSObject {
    public let id: String
    public let desc: String
    public var apiKey: String?
    
    override public var description: String {
        get { return desc }
    }
    
    public init(id: String, description: String) {
        self.id = id
        self.desc = description
    }
    
    public convenience init(prediction: [String: AnyObject], apiKey: String?) {
        self.init(
            id: prediction["place_id"] as! String,
            description: prediction["description"] as! String
        )
        
        self.apiKey = apiKey
    }
    
    /**
     Call Google Place Details API to get detailed information for this place
     
     Requires that Place#apiKey be set
     
     - parameter result: Callback on successful completion with detailed place information
     */
    public func getDetails(result: PlaceDetails -> ()) {
        GooglePlaceDetailsRequest(place: self).request(result)
    }
}

public class PlaceDetails: CustomStringConvertible {
    public let name: String
    public let latitude: Double
    public let longitude: Double
    public let raw: [String: AnyObject]
    public let defaultFormatAddress: String
    
    // Endereco mais "quebrado"
    let fullAddress: String     // endereco com o nosso formato
    var address: String         // logradouro
    var neighborhood: String        // bairro
    var city: String            // cidade
    var state: String           // estado
    var country: String         // pais
    var postalcode: String      // cep
    
    
    public init(json: [String: AnyObject]) {
        let result = json["result"] as! [String: AnyObject]
        let geometry = result["geometry"] as! [String: AnyObject]
        let location = geometry["location"] as! [String: AnyObject]
        let addressComponents = result["address_components"] as! [[String: AnyObject]]
        
        self.defaultFormatAddress = result["formatted_address"] as! String
        self.latitude = location["lat"] as! Double
        self.longitude = location["lng"] as! Double
        self.raw = json
        self.name = ""
        
        self.address = ""
        self.neighborhood = ""
        self.city = ""
        self.state = ""
        self.country = ""
        self.postalcode = ""
        
        for component in addressComponents {
            let types = component["types"] as! [String]
            for type in types {
                switch type {
                case "route":
                    self.address = component["long_name"] as! String
                    break;
                case "neighborhood", "administrative_area_level_3", "sublocality":
                    self.neighborhood = component["short_name"] as! String
                    break;
                case "locality", "administrative_area_level_2":
                    self.city = component["short_name"] as! String
                    break;
                case "administrative_area_level_1":
                    self.state = component["short_name"] as! String
                    break;
                case "country":
                    self.country = component["long_name"] as! String
                    break;
                case "postal_code":
                    self.postalcode = component["short_name"] as! String
                    break;
                default:
                    break;
                }
            }
        }
        if self.neighborhood != "" {
            self.fullAddress = "\(self.address) - \(self.neighborhood), \(self.city) - \(self.state)"
        } else {
            self.fullAddress = "\(self.address), \(self.city) - \(self.state)"
        }
        
    }
    
    
    public var description: String {
        return "PlaceDetails: \(address) (\(latitude), \(longitude))"
    }
}

public class PlaceReversedDetails: CustomStringConvertible {
    public let defaultFormatAddress: String
    public let latitude: Double
    public let longitude: Double
    public let raw: [String: AnyObject]
    
    // Endereco mais "quebrado"
    let fullAddress: String     // endereco com o nosso formato
    var address: String         // logradouro
    var neighborhood: String    // bairro
    var city: String            // cidade
    var state: String           // estado
    var country: String         // pais
    var postalcode: String      // cep
    var streetnumber: Int?      // numero da rua
    
    public init(json: [String: AnyObject]) {
        let addressComponents = json["address_components"] as! [[String: AnyObject]]
        let geometry = json["geometry"] as! [String: AnyObject]
        let location = geometry["location"] as! [String: AnyObject]
        
        self.defaultFormatAddress = json["formatted_address"] as! String
        self.latitude = location["lat"] as! Double
        self.longitude = location["lng"] as! Double
        self.raw = json
        
        self.address = ""
        self.neighborhood = ""
        self.city = ""
        self.state = ""
        self.country = ""
        self.postalcode = ""
        
        for component in addressComponents {
            let types = component["types"] as! [String]
            for type in types {
                switch type {
                case "route":
                    self.address = component["long_name"] as! String
                    break;
                case "neighborhood":
                    self.neighborhood = component["short_name"] as! String
                    break;
                case "locality", "administrative_area_level_2":
                    self.city = component["short_name"] as! String
                    break;
                case "administrative_area_level_1":
                    self.state = component["short_name"] as! String
                    break;
                case "country":
                    self.country = component["long_name"] as! String
                    break;
                case "postal_code":
                    self.postalcode = component["short_name"] as! String
                    break;
                case "street_number":
                    self.streetnumber = ((component["short_name"] as! String) as NSString).integerValue
                    break;
                default:
                    break;
                }
            }
        }
        
        if self.neighborhood != "" {
            self.fullAddress = "\(self.address) - \(self.neighborhood), \(self.city) - \(self.state)"
        } else {
            self.fullAddress = "\(self.address), \(self.city) - \(self.state)"
        }
    }
    
    public var description: String {
        return "PlaceReversed: \(fullAddress) (\(latitude), \(longitude))"
    }
}

@objc public protocol GooglePlacesAutocompleteDelegate {
    optional func placesFound(places: [Place])
    optional func placeSelected(place: Place)
    optional func placeViewClosed()
    optional func placeViewSave()
    optional func geocodingAddressFound(address: String)
    optional func geocodingAddressError()
}

// MARK: - GooglePlacesAutocomplete
public class GooglePlacesAutocomplete: UINavigationController {
    public var gpaViewController: GooglePlacesAutocompleteContainer!
    public var closeButton: UIBarButtonItem!
    //    public var saveButton: UIBarButtonItem!
    
    // Proxy access to container navigationItem
    public override var navigationItem: UINavigationItem {
        get { return gpaViewController.navigationItem }
    }
    
    public var placeDelegate: GooglePlacesAutocompleteDelegate? {
        get { return gpaViewController.delegate }
        set { gpaViewController.delegate = newValue }
    }
    
    public var locationBias: LocationBias? {
        get { return gpaViewController.locationBias }
        set { gpaViewController.locationBias = newValue }
    }
    
    public convenience init(apiKey: String, placeType: PlaceType = .All) {
        let gpaViewController = GooglePlacesAutocompleteContainer(
            apiKey: apiKey,
            placeType: placeType
        )
        
        self.init(rootViewController: gpaViewController)
        self.gpaViewController = gpaViewController
        
        closeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: #selector(GooglePlacesAutocomplete.close))
        closeButton.style = UIBarButtonItemStyle.Done
        closeButton.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)        
        gpaViewController.navigationItem.leftBarButtonItem = closeButton
        gpaViewController.navigationItem.title = "Buscar endereço"
    }
    
    func close() {
        placeDelegate?.placeViewClosed?()
    }
    
    func salvar(){
        placeDelegate?.placeViewSave?()
    }
    
    public func reset() {
        gpaViewController.searchBar.text = ""
        gpaViewController.searchBar.returnKeyType = .Next
        gpaViewController.searchBar(gpaViewController.searchBar, textDidChange: "")
    }
}

// MARK: - GooglePlacesAutocompleteContainer
public class GooglePlacesAutocompleteContainer: UIViewController {
    @IBOutlet public weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    weak var delegate: GooglePlacesAutocompleteDelegate?
    var apiKey: String?
    var places = [Place]()
    var placeType: PlaceType = .All
    var locationBias: LocationBias?
    
    var indexSelected: Int?
    var lastIndexPath: NSIndexPath?
    
    var tapGestureDismiss: UITapGestureRecognizer!
    
    convenience init(apiKey: String, placeType: PlaceType = .All) {
        let bundle = NSBundle(forClass: GooglePlacesAutocompleteContainer.self)
        
        self.init(nibName: "GooglePlacesAutocomplete", bundle: bundle)
        self.apiKey = apiKey
        self.placeType = placeType
        self.indexSelected = -1
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override public func viewWillLayoutSubviews() {
        topConstraint.constant = topLayoutGuide.length
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GooglePlacesAutocompleteContainer.keyboardWasShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GooglePlacesAutocompleteContainer.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        searchBar.becomeFirstResponder()
        searchBar.returnKeyType = .Next
        tableView.registerNib(UINib(nibName: "GooglePlacesCell", bundle: nil), forCellReuseIdentifier: "myCell")
        
        tapGestureDismiss = UITapGestureRecognizer(target: self, action: #selector(GooglePlacesAutocompleteContainer.dismissBG(_:)))
        tapGestureDismiss.cancelsTouchesInView = true
        
        tableView.addGestureRecognizer(tapGestureDismiss)
        tableView.reloadData()
    }
        
    func keyboardWasShown(notification: NSNotification) {
        if isViewLoaded() && view.window != nil {
            let info: Dictionary = notification.userInfo!
            let keyboardSize: CGSize = (info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size)!
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
            
            tableView.contentInset = contentInsets;
            tableView.scrollIndicatorInsets = contentInsets;
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        if isViewLoaded() && view.window != nil {
            self.tableView.contentInset = UIEdgeInsetsZero
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero
        }
    }
    
    func dismissBG(sender: UITapGestureRecognizer? = nil) {
        let position = sender!.locationInView(tableView)
        if tableView.pointInside(position, withEvent: nil) {
            if let indexPath = self.tableView.indexPathForRowAtPoint(position) {
                let cell = self.tableView.cellForRowAtIndexPath(indexPath)
                
                if let last = self.lastIndexPath {
                    let lastCell = self.tableView.cellForRowAtIndexPath(last)
                    lastCell?.setSelected(false, animated: false)
                }
                
                self.lastIndexPath = indexPath
                self.indexSelected = indexPath.row
                cell?.setSelected(true, animated: false)
                
                delegate?.placeSelected?(self.places[indexPath.row])
            } else {
                delegate?.placeViewClosed?()
            }
        }
    }
    
}

// MARK: - GooglePlacesAutocompleteContainer (UITableViewDataSource / UITableViewDelegate)
extension GooglePlacesAutocompleteContainer: UITableViewDataSource, UITableViewDelegate {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath) as! GooglePlacesTableViewCell
        
        // Get the corresponding candy from our candies array
        let place = self.places[indexPath.row]
        
        // Configure the cell
        cell.enderecoLabel.text = place.description
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 46.0
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.indexSelected = indexPath.row
        delegate?.placeSelected?(self.places[indexPath.row])
    }
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            cell.setSelected(true, animated: false)
            self.indexSelected = 0
            self.lastIndexPath = indexPath
        }
    }
}

// MARK: - GooglePlacesAutocompleteContainer (UISearchBarDelegate)
extension GooglePlacesAutocompleteContainer: UISearchBarDelegate {
    public func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            self.places = []
            tableView.reloadData()
            //            tableView.hidden = true
        } else {
            getPlaces(searchText)
        }
    }
    
    public func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if self.indexSelected != -1 {
            delegate?.placeSelected?(self.places[indexSelected!])
        }
    }
    
    /**
     Call the Google Places API and update the view with results.
     
     - parameter searchString: The search query
     */
    
    private func getPlaces(searchString: String) {
        var params = [
            "input": searchString,
            "language": "pt-BR",
            "types": placeType.description,
            "key": apiKey ?? ""
        ]
        
        if searchString == "reverse"{
            if let bias = locationBias {
                params["location"] = bias.location
                params["radius"] = bias.radius.description
            }
        }
        
        if (searchString == ""){
            return
        }
        
        GooglePlacesRequestHelpers.doRequest(
            "https://maps.googleapis.com/maps/api/place/autocomplete/json",
            params: params
            ) { json, error in
                if let json = json{
                    if let predictions = json["predictions"] as? Array<[String: AnyObject]> {
                        self.places = predictions.map { (prediction: [String: AnyObject]) -> Place in
                            return Place(prediction: prediction, apiKey: self.apiKey)
                        }
                        self.tableView?.reloadData()
                        self.tableView?.hidden = false
                        self.delegate?.placesFound?(self.places)
                    }
                }
        }
    }
    
    public func getPlacesReversed(latitude: Double, longitude: Double) {
        self.placeType = .Geocode
        
        let params = [
            "latlng": "\(latitude),\(longitude)",
            "result_type": "street_address",
            "language": "pt-BR",
            "key": apiKey ?? ""
        ]
        
        GooglePlacesRequestHelpers.doRequest(
            "https://maps.googleapis.com/maps/api/geocode/json",
            params: params
            ) { json, error in
                if let json = json {
                    if let results = json["results"] as? Array<[String: AnyObject]> {
                        if !results.isEmpty {
                            let result: [String: AnyObject] = results[0]
                            let prd = PlaceReversedDetails(json: result)
                            
                            if !prd.address.isEmpty || prd.address != "" {
                                
                                self.delegate?.geocodingAddressFound?(prd.fullAddress)
                                
                            } else {
                                self.delegate?.geocodingAddressError?()
                            }
                        } else {
                            self.delegate?.geocodingAddressError?()
                        }
                        
                    }
                    
                }
        }
        self.placeType = .All
    }
    
}

// MARK: - GooglePlaceDetailsRequest
class GooglePlaceDetailsRequest {
    let place: Place
    
    init(place: Place) {
        self.place = place
    }
    
    func request(result: PlaceDetails -> ()) {
        GooglePlacesRequestHelpers.doRequest(
            "https://maps.googleapis.com/maps/api/place/details/json",
            params: [
                "placeid": place.id,
                "language": "pt-BR",
                "key": place.apiKey ?? ""
            ]
            ) { json, error in
                if let json = json as? [String: AnyObject] {
                    result(PlaceDetails(json: json))
                }
                if let error = error {
                    // TODO: We should probably pass back details of the error
                    print("Error fetching google place details: \(error)")
                }
        }
    }
}

// MARK: - GooglePlacesRequestHelpers
class GooglePlacesRequestHelpers {
    /**
     Build a query string from a dictionary
     
     - parameter parameters: Dictionary of query string parameters
     - returns: The properly escaped query string
     */
    private class func query(parameters: [String: AnyObject]) -> String {
        var components: [(String, String)] = []
        for key in Array(parameters.keys).sort(<) {
            let value: AnyObject! = parameters[key]
            components += [(escape(key), escape("\(value)"))]
        }
        
        return (components.map{"\($0)=\($1)"} as [String]).joinWithSeparator("&")
    }
    
    private class func escape(string: String) -> String {
        let legalURLCharactersToBeEscaped: CFStringRef = ":/?&=;+!@#$()',*"
        return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
    }
    
    private class func doRequest(url: String, params: [String: String], completion: (NSDictionary?,NSError?) -> ()) {
        let request = NSMutableURLRequest(
            URL: NSURL(string: "\(url)?\(query(params))")!
        )
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            self.handleResponse(data, response: response as? NSHTTPURLResponse, error: error, completion: completion)
        }
        
        task.resume()
    }
    
    private class func handleResponse(data: NSData!, response: NSHTTPURLResponse!, error: NSError!, completion: (NSDictionary?, NSError?) -> ()) {
        
        // Always return on the main thread...
        let done: ((NSDictionary?, NSError?) -> Void) = {(json, error) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(json,error)
            })
        }
        
        if let error = error {
            print("GooglePlaces Error: \(error.localizedDescription)")
            done(nil,error)
            return
        }
        
        if response == nil {
            print("GooglePlaces Error: No response from API")
            let error = NSError(domain: ErrorDomain, code: 1001, userInfo: [NSLocalizedDescriptionKey:"No response from API"])
            done(nil,error)
            return
        }
        
        if response.statusCode != 200 {
            print("GooglePlaces Error: Invalid status code \(response.statusCode) from API")
            let error = NSError(domain: ErrorDomain, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:"Invalid status code"])
            done(nil,error)
            return
        }
        
        let json: NSDictionary?
        do {
            json = try NSJSONSerialization.JSONObjectWithData(
                data,
                options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
        } catch {
            print("Serialisation error")
            let serialisationError = NSError(domain: ErrorDomain, code: 1002, userInfo: [NSLocalizedDescriptionKey:"Serialization error"])
            done(nil,serialisationError)
            return
        }
        
        if let status = json?["status"] as? String {
            if status != "OK" && status != "ZERO_RESULTS"{
                print("GooglePlaces API Error: \(status)")
                let error = NSError(domain: ErrorDomain, code: 1002, userInfo: [NSLocalizedDescriptionKey:status])
                done(nil,error)
                return
            }
        }
        
        done(json,nil)
        
    }
}
