//
//  ViewController.swift
//  TuneSearch
//
//  Created by Srini Motheram on 2/13/17.
//  Copyright © 2017 Srini Motheram. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController  /*, UITableViewDelegate, UITableViewDataSource */ {
    
    var museumArray = [MuseumItem]()
    
    @IBOutlet var coffeeMap :MKMapView!
    
    var locationMgr = CLLocationManager()
    
    func zoomToPins(){
        coffeeMap.showAnnotations(coffeeMap.annotations, animated: true)
    }
    
    func zoomToLocation(lat: Double, lon: Double, radius: Double){
        if lat == 0 && lon == 0 {
            print("invalid data")
            
        } else {
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let viewRegion = MKCoordinateRegionMakeWithDistance(coord, radius, radius)
            let adjustedRegion = coffeeMap.regionThatFits(viewRegion)
            coffeeMap.setRegion(adjustedRegion, animated: true)
            
        }
        coffeeMap.showAnnotations(coffeeMap.annotations, animated: true)
    }
    
    
    //MARK :- LIFE CYCLE METHODS
    
    let hostName = "data.imls.gov"
    var reachability :Reachability?
    
    @IBOutlet var networkStatusLabel    :UILabel!
   // @IBOutlet var searchField           :UITextField!
   // @IBOutlet var museumTableView        :UITableView!
    
    //MARK :- CORE METHODS
    // not using the following func left it for ref
    func parseJason(data: Data){
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]
          //  print("JSON: \(jsonResult)")
            let flavorsArray = jsonResult["flavors"] as! [[String:Any]]
            for flavorDict in flavorsArray {
                print("Flavor:\(flavorDict)")
            }
            for flavorDict in flavorsArray {
                print("Flavor:\(flavorDict["name"])")
            }
            
        } catch {
            print("JSON Parsing Error")
        }
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
    }
    
    func parseItunesJason(data: Data){
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSArray
             //   [String:Any]()
           // print("JSON: \(jsonResult)")
            let firstRow = jsonResult[0]
            print("first row: \(firstRow)")
            let museumArray2 = jsonResult as! [[String:Any]]

            for museumDict in museumArray2 {
                print("museum:\(museumDict["commonname"])")

            let museumName2 = museumDict["commonname"] as? String ?? "no data"
            let street2 = museumDict["location_1_address"] as? String ?? "no street data"
            let city2 = museumDict["location_1_city"] as? String ?? "no city data"
            let state2 = museumDict["location_1_state"] as? String ?? "no state data"
           
            let coordDict = museumDict["location_1"] as? NSDictionary ?? nil
              //  print("museum1:\(coordDict)")
            let coordArray = coordDict?["coordinates"] as? NSArray ?? nil
              //  print("coord: \(coordArray?[0])")
            let lat1 = coordArray?[0] as? Double  ?? 0.0
            let lon1 = coordArray?[1] as? Double  ?? 0.0
             //   print("lat: \(lat1), long: \(lon1)")

                
                //  let lon = museumDict["coordinates[1]"] as? Double ?? "no state data"

            museumArray.append(MuseumItem(museumName: museumName2, street: street2, city: city2,  state: state2, lat: lat1, lon: lon1))
            
           }
     
            print("Museum Array: \(museumArray[0])")
        }
       catch {
            print("JSON Parsing Error")
        }
        DispatchQueue.main.async {
           // self.museumTableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
    }
    
    func getFile(filename: String){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlString = "https://\(hostName)\(filename)"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let recvData = data else {
                print ("no data")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
                
            }
            if recvData.count > 0 && error == nil {
                
                print("Got Data: \(recvData)")
                let dataString = String.init(data: recvData, encoding: .utf8)
                print("Got Data String: \(dataString)")
                self.parseItunesJason(data: recvData)
                
            } else {
                print("Got data of length 0")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            }
        }
        task.resume()
    }
    
    //MARK: - setup METHODS -- just for testing
    func fillArray() -> [MuseumItem]{
        let museum3 = MuseumItem(museumName: "Bill Museum", street: "123 oak", city: "ypsi", state: "FL", lat: 83.1254, lon: -42.123)
        let museum2 = MuseumItem(museumName: "Joe Museum", street: "123 maple", city: "canton", state: "FL", lat: 83.1254, lon: -42.123)
        return [museum3, museum2]
    }
    
    
   // @IBAction func getFilePressed(button: UIButton){
    func getFilePressed() {
        guard let reach = reachability else {
            return
        }
       
        if reach .isReachable {
            // getFile(filename: "/classfiles/iOS_URL_Class_Get_File.txt")
             getFile(filename: "/resource/et8i-mnha.json")
            // getFile(filename: "/search?term=\(searchTerm)")
            
        } else {
            print("Host Not reachable. Turn on the internet")
        }
        
        
    }
    
    func annotateMapLocations(){
        
        var pinsToRemove = [MKPointAnnotation]()
        for annotation in coffeeMap.annotations{
            if annotation is MKPointAnnotation {
                pinsToRemove.append(annotation as! MKPointAnnotation)
            }
            
        }
        coffeeMap.removeAnnotations(pinsToRemove)
        
        print("in annotate pins func \(museumArray.count)")
        
        for museumLoc in museumArray {
            let pa1 = MKPointAnnotation()
            pa1.coordinate = CLLocationCoordinate2D(latitude: museumLoc.locationLat, longitude: museumLoc.locationLon)
            pa1.title = museumLoc.museumName
            pa1.subtitle = museumLoc.city
            
            print("in annotate pins \(museumLoc.locationLat)")
            coffeeMap.addAnnotations([pa1])
        }
        // zoomToPins()
    }
    
    //MARK :- Table View Methods
  
    
    //MARK :- REACHABILITY METHODS
    
    func setupReachability(hostName: String){
        reachability = Reachability(hostname: hostName)
        reachability!.whenReachable = { reachability in
            DispatchQueue.main.async {
                self.updateLabel(reachable: true, reachability: reachability)
            }
        }
        reachability!.whenUnreachable = { reachability in
            DispatchQueue.main.async {
                self.updateLabel(reachable: false, reachability: reachability)
            }
        }
        
    }
    
    func startReachability(){
        do {
            try reachability!.startNotifier()
        } catch {
            networkStatusLabel.text = "Unable to start notifier"
            networkStatusLabel.textColor = .red
            return
        }
    }
    
    func updateLabel(reachable: Bool, reachability: Reachability){
        if reachable {
            if reachability.isReachableViaWiFi {
                networkStatusLabel.textColor = .green
            } else {
                networkStatusLabel.textColor = .blue
            }
        } else {
            networkStatusLabel.textColor = .red
        }
        networkStatusLabel.text = reachability.currentReachabilityString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupReachability(hostName: hostName)
        startReachability()
        getFilePressed()
        annotateMapLocations()
        
       setupLocationMonitoring()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLoc = locations.last!
        print("Last loc: \(lastLoc.coordinate.latitude), \(lastLoc.coordinate.longitude)")
        zoomToLocation(lat: lastLoc.coordinate.latitude, lon: lastLoc.coordinate.longitude, radius: 500)
        manager.stopUpdatingLocation()
    }
    
    //MARK - LOCATION AUTHORISING METHODS
    
    func turnOnLocationMonitoring(){
        locationMgr.startUpdatingLocation()
        coffeeMap.showsUserLocation = true
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        setupLocationMonitoring()
    }
    
    func setupLocationMonitoring(){
        locationMgr.delegate = self
        locationMgr.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                turnOnLocationMonitoring()
            case .denied, .restricted:
                print("hey turn us back on in settings")
            case .notDetermined:
                if locationMgr.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)){
                    locationMgr.requestAlwaysAuthorization()
                }
                
            }
        } else {
            print("hey turn on location on settings please")
        }
    }
}




