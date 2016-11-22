//
//  PatientViewController.swift
//  Aorecare
//
//  Created by Minh Pham on 11/20/16.
//  Copyright © 2016 Minh Pham. All rights reserved.
//

import UIKit
import Parse
import MapKit

class PatientViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, SideBarDelegate {
    var sideBar:SideBar = SideBar()
    
    func sideBarDidSelectButtonAtIndex(_ index: Int) {
        
    }

    var locationManager = CLLocationManager()
    
    var patientRequestActive = true
    
    var doctorOnTheWay = false
    
    var userLocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var callADoctor: UIButton!
    
    @IBAction func callADoctor(_ sender: Any) {
        if patientRequestActive {
            callADoctor.setTitle("Call A Doctor", for: [])
            
            patientRequestActive = false
            
            let query = PFQuery(className: "PatientRequest")
            
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            print(query)
            
            print((PFUser.current()?.username)!)
            
            query.findObjectsInBackground(block: { (objects, error) in
                
                if let objects = objects {
                    for i in objects{
                        i.deleteInBackground()
                    }
                }
            })
            
            
        } else {
            
            if userLocation.latitude != 0 && userLocation.longitude != 0 {
                
                patientRequestActive = true
                
                let patientRequest = PFObject(className: "PatientRequest")
                
                patientRequest["username"] = PFUser.current()?.username
                
                patientRequest["location"] = PFGeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude)
                
                patientRequest.saveInBackground(block: { (success, error) in
                    if success {
                        self.callADoctor.setTitle("Cancel Doctor", for: [])
                    } else {
                        
                        self.callADoctor.setTitle("Call A Doctor", for: [])
                        
                        self.patientRequestActive = false
                        
                        self.displayAlert(title: "Could not call Doctor", message: "Please try again")
                        
                    }
                })
                
            } else {
                displayAlert(title: "Could bot call Doctor", message: "Cannot detect your location")
            }
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location?.coordinate{
            
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            if doctorOnTheWay == false {
            
                let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                self.mapView.setRegion(region, animated: true)
                
                self.mapView.removeAnnotations(self.mapView.annotations)
                
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = userLocation
                
                annotation.title = "Your location"
            
                self.mapView.addAnnotation(annotation)
            }
        
            
            let query = PFQuery(className: "PatientRequest")
            
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            
            query.findObjectsInBackground(block: { (objects, error) in
                if let patientRequests = objects {
                    for i in patientRequests{
                        
                        i["location"] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                        i.saveInBackground()
                    }
                }
            })
        }
        
        if patientRequestActive == true{
            let query = PFQuery(className: "PatientRequest")
            query.whereKey("username", equalTo: PFUser.current()?.username)
            
            query.findObjectsInBackground(block: { (objects, error) in
                if let patientRequests = objects {
                    for i in patientRequests {
                        if let doctorUsername = i["DoctorResponded"]{
                            let query = PFQuery(className: "DoctorLocation")
                            query.findObjectsInBackground(block: { (objects, error) in
                                if let doctorLocations = objects {
                                    for j in doctorLocations {
                                        if let doctorLocation = i["location"] as? PFGeoPoint {
                                            
                                            self.doctorOnTheWay = true
                                            
                                            let doctorCLLocation = CLLocation(latitude: doctorLocation.latitude, longitude: doctorLocation.longitude)
                                            
                                            let patientCLLocation = CLLocation(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                                            
                                            let distance = patientCLLocation.distance(from: doctorCLLocation) / 1000
                                            
                                            let roundedDistance = round(distance*100)/100
                                            
                                            self.callADoctor.setTitle("Doctor is \(roundedDistance)km away", for: [])
                                            
                                            let latDelta = abs(doctorLocation.latitude - self.userLocation.latitude) * 2 + 0.005
                                            let lonDelta = abs(doctorLocation.longitude - self.userLocation.longitude) * 2 + 0.005
                                            
                                            let region = MKCoordinateRegion(center: self.userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
                                            
                                            self.mapView.removeAnnotations(self.mapView.annotations)
                                            
                                            self.mapView.setRegion(region, animated: true)
                                            
                                            let userLocationAnnotation = MKPointAnnotation()
                                            
                                            userLocationAnnotation.coordinate = self.userLocation
                                            
                                            userLocationAnnotation.title = "Your location"
                                            
                                            self.mapView.addAnnotation(userLocationAnnotation)
                                            
                                            let driverLocationAnnotation = MKPointAnnotation()
                                            
                                            driverLocationAnnotation.coordinate = CLLocationCoordinate2D(latitude: doctorLocation.latitude, longitude: doctorLocation.longitude)
                                            
                                            driverLocationAnnotation.title = "Your driver"
                                            
                                            self.mapView.addAnnotation(driverLocationAnnotation)
                                            
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            })
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logoutSegue"{
            
            locationManager.stopUpdatingLocation()
            PFUser.logOut()
        }
    }
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        callADoctor.isHidden = true
        
        let query = PFQuery(className: "PatientRequest")
        
        query.whereKey("username", equalTo: (PFUser.current()?.username)!)
        
        query.findObjectsInBackground(block: { (objects, error) in
            
            if let patientRequests = objects {
                if patientRequests.count > 0 {
                    self.patientRequestActive = true
                    self.callADoctor.setTitle("Cancel Doctor", for: [])
                }
            }
            self.callADoctor.isHidden = false
        })

        // Do any additional setup after loading the view.
        
        
        sideBar = SideBar(sourceView: self.view, menuItems: ["first", "second", "third"])
        sideBar.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func displayAlert(title:String, message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
