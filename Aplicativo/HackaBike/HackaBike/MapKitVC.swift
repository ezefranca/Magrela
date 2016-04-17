//
//  MapKitVC.swift
//  HackaBike
//
//  Created by Ezequiel on 4/16/16.
//  Copyright © 2016 Ezequiel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapKitVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, GooglePlacesAutocompleteDelegate, LiquidFloatingActionButtonDelegate, LiquidFloatingActionButtonDataSource, DispositivosBluetoothProtocol {
    
    @IBOutlet weak var temperatura: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var esqButton: UIButton!
    @IBOutlet weak var dirButton: UIView!
    
    var distancias:[Double]?
    var passos:[String]?
    
    
    var myRoute : MKRoute?
    // Distancia inicial de abrangencia (Zoom)
    let regionRadius: CLLocationDistance = 1000
    
    // Pin da localizacao
    var pinAnnotation: PinAnnotation!
    
    // Busca de enderecos
    var gpaViewController = GooglePlacesAutocomplete(
        // Server API Key, esta na conta do Ramon
        apiKey: "AIzaSyCuUsA5Yw9i59zjSU-cyNOimualxC2HqkM",
        placeType: .Address
    )
    
    // Helpers endereco
    var locationManager:CLLocationManager!
    var userAddress: String?
    var userNumber: Int?
    var addressPlace: Place?
    var addressClosed = false
    var request:MKDirectionsRequest?
    var blurMapBackground = UIView()
    var cells: [LiquidFloatingCell] = []
    var liquidButtonBackground = UIView()
    var floatingActionButton: LiquidFloatingActionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        gpaViewController.gpaViewController.delegate = self
        
        // Configurando a mapview
        mapView.delegate = self
        //locationManager.delegate = self
        
        blurMapBackground.frame.size = screenSize()
        blurMapBackground.backgroundColor = UIColorFromHex(0x000000, alpha: 0.8)
        blurMapBackground.bounds = UIScreen.mainScreen().bounds
        blurMapBackground.alpha = 0.8
        
        self.esqButton.layer.cornerRadius = self.esqButton.frame.width/2
        
        let createButton: (CGRect, LiquidFloatingActionButtonAnimateStyle) -> LiquidFloatingActionButton = { (frame, style) in
            self.floatingActionButton = LiquidFloatingActionButton(frame: frame)
            self.floatingActionButton.animateStyle = style
            self.floatingActionButton.dataSource = self
            self.floatingActionButton.delegate = self
            return self.floatingActionButton
        }
        
        let cellFactory: (String) -> LiquidFloatingCell = { (iconName) in
            return LiquidFloatingCell(icon: UIImage(named: iconName)!)
        }
        
        cells.append(cellFactory("icone_sibebuttons_feed"))
        cells.append(cellFactory("icone_sibebuttons_localderisco"))
        cells.append(cellFactory("icone_sibebuttons_traffic"))
        cells.append(cellFactory("icone_sibebuttons_ladeira"))
        cells.append(cellFactory("icone_sibebuttons_buracos"))
        
        let floatingFrame = self.dirButton.layer.frame
        let bottomRightButton = createButton(floatingFrame, .Up)
        self.view.addSubview(bottomRightButton)
        Singleton.sharedInstance.floatingActionButton = self.floatingActionButton
        
        liquidButtonBackground.frame.size = screenSize()
        liquidButtonBackground.backgroundColor = UIColorFromHex(0x000000, alpha: 0.7)
        liquidButtonBackground.bounds = UIScreen.mainScreen().bounds
        liquidButtonBackground.alpha = 0.7
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestAlwaysAuthorization()
        
        Singleton.sharedInstance.dispositivosBluetooth?.delegate = self
        //let timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(MapKitVC.readValue), userInfo: nil, repeats: true)
        //timer.fire()
    }
    
    func retornaBluetooth(retorno: String) {
        var x = false
        x = retorno.containsString("ALT")
        var y = false
        y = retorno.containsString("TEMP")
        
        if x {
            let alerta = CLLocationCoordinate2DMake((locationManager.location?.coordinate.latitude)!, (locationManager.location?.coordinate.longitude)!)
            // Drop a pin
            let dropPin = MKPointAnnotation()
            
            dropPin.coordinate = alerta
            dropPin.title = "Cuidado, buraco na pista!"
            mapView.addAnnotation(dropPin)
        }
        
        if y {
            self.temperatura.text = retorno
            print("Temperatura: \(retorno)")
        }
        
    }
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            // authorized location status when app is in use; update current location
            locationManager.startUpdatingLocation()
            // implement additional logic if needed...
            
            Singleton.sharedInstance.pessoaAtual?.latitude = manager.location?.coordinate.latitude
            Singleton.sharedInstance.pessoaAtual?.longitude = manager.location?.coordinate.longitude
        }
        // implement logic for other status values if needed...
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let distanceSpan:Double = 2000
        
        if let mapView = self.mapView {
            let region = MKCoordinateRegionMakeWithDistance(locations[0].coordinate, distanceSpan, distanceSpan)
            mapView.setRegion(region, animated: true)
            
            
            
            //
            //        if (s.first as? CLLocation) != nil {
            //            // implement logic upon location change and stop updating location until it is subsequently updated
            //            locationManager.stopUpdatingLocation()
            //        }
        }
    }
    //    func mapView(mapView: MKMapView, _rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    //        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
    //        renderer.strokeColor = UIColor.blueColor()
    //        return renderer
    //    }
    /*........*/
    
    
    
    //    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    //        request = MKDirectionsRequest()
    //        request!.source = MKMapItem(placemark: MKPlacemark(coordinate: (locationManager.location?.coordinate)!, addressDictionary: nil))
    //        request!.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37.783333, longitude: -122.416667), addressDictionary: nil))
    //        request!.requestsAlternateRoutes = true
    //        request!.transportType = .Automobile
    //
    //        let directions = MKDirections(request: request!)
    //
    //        directions.calculateDirectionsWithCompletionHandler { [unowned self] response, error in
    //            guard let unwrappedResponse = response else { return }
    //
    //            for route in unwrappedResponse.routes {
    //                self.mapView.addOverlay(route.polyline)
    //                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
    //            }
    //        }
    //    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // Usado para criar as celulas do botão flutuante
    func numberOfCells(liquidFloatingActionButton: LiquidFloatingActionButton) -> Int {
        return cells.count
    }
    
    func cellForIndex(index: Int) -> LiquidFloatingCell {
        return cells[index]
    }
    
    func liquidFloatingActionButton(liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int) {
        var post = Post()
        
        
        switch index {
        case 0:
            performSegueWithIdentifier("SendAlertVC", sender: self)
        case 1:
            post.titulo = ""
            post.pessoaId = Singleton.sharedInstance.pessoaAtual?.objectId
            post.latitude = locationManager.location?.coordinate.latitude
            post.longitude = locationManager.location?.coordinate.longitude
            post.pessoaNome = "risco"
            DevicesVC.writeValue("RISK/r/n")

            PostController.insertPost(post) { (resp:String?) in
                print(resp)
                DevicesVC.writeValue("DIR+UP/r/n")
                //alertSucess("Enviado feed com sucesso", description: "Enviado")
            }
        case 2:
            post.titulo = ""
            post.pessoaId = Singleton.sharedInstance.pessoaAtual?.objectId
            post.latitude = locationManager.location?.coordinate.latitude
            post.longitude = locationManager.location?.coordinate.longitude
            post.pessoaNome = "transito"
            DevicesVC.writeValue("DIR+LEFT/r/n")

            PostController.insertPost(post) { (resp:String?) in
                print(resp)
                DevicesVC.writeValue("DIR+LEFT/r/n")
                //alertSucess("Enviado risco com sucesso", description: "Enviado")
            }
            
        case 3:
            post.titulo = ""
            post.pessoaId = Singleton.sharedInstance.pessoaAtual?.objectId
            post.latitude = locationManager.location?.coordinate.latitude
            post.longitude = locationManager.location?.coordinate.longitude
            post.pessoaNome = "ladeira"
            DevicesVC.writeValue("DIR+RIGHT/r/n")

            PostController.insertPost(post) { (resp:String?) in
                print(resp)
                DevicesVC.writeValue("DIR+RIGHT/r/n")
                //alertSucess("Enviado transito com sucesso", description: "Enviado")
            }
            
        case 4:
            
            post.titulo = ""
            post.pessoaId = Singleton.sharedInstance.pessoaAtual?.objectId
            post.latitude = locationManager.location?.coordinate.latitude
            post.longitude = locationManager.location?.coordinate.longitude
            post.pessoaNome = "buraco"
            DevicesVC.writeValue("HOLE/r/n")

            PostController.insertPost(post) { (resp:String?) in
                print(resp)
                DevicesVC.writeValue("HOLE/r/n")
                //alertSucess("Enviado transito com sucesso", description: "Enviado")
            }
            
        default:
            print("Error")
        }
        
        Singleton.sharedInstance.pessoaAtual?.latitude = post.latitude
        Singleton.sharedInstance.pessoaAtual?.longitude = post.longitude
    }
    
    func didSelectLiquidFloatingActionButton(isOpening: Bool) {
        if isOpening {
            self.view.insertSubview(liquidButtonBackground, belowSubview: Singleton.sharedInstance.floatingActionButton)
            UIView.animateWithDuration(0.2, animations: {self.liquidButtonBackground.alpha = 0.7}, completion: nil)
        } else {
            UIView.animateWithDuration(0.2, animations: {self.liquidButtonBackground.alpha = 0.0}, completion: {(value: Bool) in
                self.liquidButtonBackground.removeFromSuperview()
            })
        }
    }
    
    /**
     Metodo helper, que serve pra centralizar o mapa na posicao selecionada
     */
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func desconectou() {
        print("desc")
    }
    
    /**
     Quando ha uma deteccao do gestureRecognizer, esta funcao eh chamada. Convertemos o ponto de onde o usuario tocou, para um ponto no mapa, pegando assim as coordenadas para adicionar o respectivo pin
     */
    func handleLongPressGesture(sender: UIGestureRecognizer){
        if sender.state == UIGestureRecognizerState.Ended {
            self.mapView.removeGestureRecognizer(sender)
        } else {
            let point = sender.locationInView(self.mapView)
            let locCord = self.mapView.convertPoint(point, toCoordinateFromView: self.mapView)
            
            self.adicionarPinAoMapa(locCord.latitude, longitude: locCord.longitude)
            gpaViewController.gpaViewController.getPlacesReversed(locCord.latitude, longitude: locCord.longitude)
            
        }
    }
    
    /**
     Adiciona uma notacao ao mapa, conforme as coordenadas passadas por parametro
     */
    func adicionarPinAoMapa(latitude: Double, longitude: Double){
        if (self.pinAnnotation != nil) {
            self.mapView.removeAnnotation(self.pinAnnotation)
        }
        
        self.pinAnnotation = PinAnnotation()
        self.pinAnnotation.setCoordinate(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        self.pinAnnotation.title = "Destino"
        
        self.mapView.addAnnotation(self.pinAnnotation)
        self.mapView.selectAnnotation(self.pinAnnotation, animated: true)
    }
    
    /*
     (delegate) Definimos as propriedades do pin
     */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is PinAnnotation {
            
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            pinAnnotationView.pinTintColor = UIColor(red: 99/255, green: 71/255, blue: 92/255, alpha: 0.75)
            pinAnnotationView.draggable = true
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            return pinAnnotationView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let capital = view.annotation as! PinAnnotation
        let placeName = capital.title
        let placeInfo = "EITA LELELE"
        
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("Carajo")
        request = MKDirectionsRequest()
        request!.source = MKMapItem(placemark: MKPlacemark(coordinate: (locationManager.location?.coordinate)!, addressDictionary: nil))
        request!.destination = MKMapItem(placemark: MKPlacemark(coordinate: view.annotation!.coordinate, addressDictionary: nil))
        request!.requestsAlternateRoutes = true
        request!.transportType = .Walking
        
        
        var r = Rota()
        
        let directions = MKDirections(request: request!)
        
        directions.calculateDirectionsWithCompletionHandler { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.myRoute = response!.routes[0]
                
                print(self.myRoute)
                
                r.arrayRetas.append([(self.myRoute?.polyline.coordinate.latitude)!, route.polyline.coordinate.longitude])
                r.personId = Singleton.sharedInstance.pessoaAtual?.objectId
                r.nomePessoa = Singleton.sharedInstance.pessoaAtual?.name
                r.tempo = "2016-04-13T06:51:00.000Z"
                r.kmRota = route.distance
                
                self.mapView.addOverlay((self.myRoute?.polyline)!)
                self.mapView.addOverlay(route.polyline)
                
                print(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                for step in route.steps {
                    self.passos?.append(step.instructions)
                    self.distancias?.append(step.distance)
                    print(step.instructions)
                }
                
            }
        }
        
        //        var directions = MKDirections(request: request!)
        //        directions.calculateDirectionsWithCompletionHandler { (response:MKDirectionsResponse!, error: NSError!) -> Void in
        //            if error == nil {
        //                self.myRoute = response.routes[0] as? MKRoute
        //                self.myMap.addOverlay(self.myRoute?.polyline)
        //            }
        //        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let myLineRenderer = MKPolylineRenderer(polyline: (myRoute?.polyline)!)
        myLineRenderer.strokeColor = UIColor.redColor()
        myLineRenderer.lineWidth = 3
        return myLineRenderer
    }
    
    @IBAction func changeAddress(sender: AnyObject) {
        self.userNumber = nil
        
        self.view.addSubview(blurMapBackground)
        UIView.animateWithDuration(0.2, animations: {self.blurMapBackground.alpha = 0.8}, completion: nil)
        
        gpaViewController.placeDelegate = self
        gpaViewController.modalPresentationStyle = .OverCurrentContext
        
        
        /******************** ROTA *********************/
        // Apresenta a view controller
        presentViewController(gpaViewController, animated: true, completion: nil)
    }
    
    func placeSelected(place: Place) {
        self.addressPlace = place
        placeViewSave()
    }
    
    func placeViewClosed() {
        UIView.animateWithDuration(0.2, animations: {self.blurMapBackground.alpha = 0.0},
                                   completion: {(value: Bool) in
                                    self.blurMapBackground.removeFromSuperview()
                                    self.dismissViewControllerAnimated(true, completion: nil)
        })
        
    }
    
    func placeViewSave() {
        self.addressPlace?.getDetails { details in
            // Passando o endereco (string) que foi selecionado na API GPlaces para a nossa class
            self.userAddress = details.fullAddress
            
            let localizacaoCL = CLLocation(latitude: details.latitude, longitude:details.longitude)
            
            // Adicionando um pin dessa localizacao no mapa
            self.adicionarPinAoMapa(details.latitude, longitude: details.longitude)
            
            // Centralizando o mapa
            self.centerMapOnLocation(localizacaoCL)
        }
        self.placeViewClosed()
    }
    
    func geocodingAddressFound(address: String) {
        self.userAddress = address
        self.showStreetNumberAlert()
    }
    
    func showStreetNumberAlert() {
        let alert = SCLAlertView()
        alert.shouldDismissOnTapOutside = true
        alert.setBodyTextFontFamily("FiraSans-Light", withSize: 17)
        alert.setTitleFontFamily("FiraSans-Regular", withSize: 17)
        alert.setButtonsTextFontFamily("FiraSans-Light", withSize: 17)
        alert.customViewColor = UIColor.grayColor()
        let txt = alert.addTextField("")
        txt.keyboardType = .NumberPad
        alert.addButton("Salvar") { () -> Void in
            if txt.text?.isEmpty == false {
                self.userNumber = ((txt.text as String!) as NSString).integerValue
            }
        }
        alert.showEdit(self, title: "Informar número", subTitle: "O endereço selecionado é \(self.userAddress!). Caso esteja de acordo, informe o número abaixo:", closeButtonTitle: "Alterar endereço", duration: 0.0)
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.Ending {
            gpaViewController.gpaViewController.getPlacesReversed(self.pinAnnotation.coordinate.latitude, longitude: self.pinAnnotation.coordinate.longitude)
        }
    }
    
    func screenSize() -> CGSize {
        let screenSize = UIScreen.mainScreen().bounds.size
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
            return CGSizeMake(screenSize.height, screenSize.width)
        }
        return screenSize
    }
}