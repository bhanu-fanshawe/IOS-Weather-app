//
//  ViewController.swift
//  weatherAppLab3Bhanu1
//
//  Created by Bhanu on 2024-11-07.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

var locationData: weatherResponse?
@IBOutlet weak var Image: UIImageView!
@IBOutlet weak var location: UILabel!
@IBOutlet weak var Temperature: UILabel!
@IBOutlet weak var locationTextfield: UITextField!
@IBOutlet weak var toggleBtn: UISwitch!
@IBOutlet weak var toggleLabel: UILabel!

private var value = true
private let locationManager = CLLocationManager()
private let geocoder = CLGeocoder()

override func viewDidLoad() {
super.viewDidLoad()
locationTextfield.delegate = self
locationManager.delegate = self
}

func textFieldShouldReturn(_ sender: UITextField) -> Bool {
locationTextfield.endEditing(true)
return true
}

@IBAction func switchChange(_ sender: UISwitch) {
value = sender.isOn
if let currentData = locationData {
Temperature.text = value ? "\(currentData.current.temp_c)C" : "\(currentData.current.temp_f)F"
toggleLabel.text = value ? "Celsius" : "Fahrenheit"
}
}

@IBAction func searchLocationTapped(_ sender: UIButton) {
weatherShow(search: locationTextfield.text)
}

@IBAction func currentLocationTapped(_ sender: UIButton) {
locationManager.requestWhenInUseAuthorization()
locationManager.startUpdatingLocation()
}

private func weatherShow(search: String?) {
guard let search = search, let url = getURL(query: search) else { return }

let session = URLSession.shared
let dataTask = session.dataTask(with: url) { data, response, error in
guard error == nil, let data = data else {
print("Error or no data")
return
}

if let responseW = self.parseJson(data: data) {
self.locationData = responseW
DispatchQueue.main.async {
self.location.text = responseW.location.name
self.updateTemperatureLabel(for: responseW)
self.updateWeatherImage(for: responseW)
}
}
}
dataTask.resume()
}

private func getURL(query: String) -> URL? {
let baseUrl = "https://api.weatherapi.com/v1/"
let currentEndpoint = "current.json"
let apiKey = "6c07f59540ff415eaf4205741241803"

guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
let urlString = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(encodedQuery)"
return URL(string: urlString)
}

private func parseJson(data: Data) -> weatherResponse? {
let decoder = JSONDecoder()
do {
return try decoder.decode(weatherResponse.self, from: data)
} catch {
print("Error Decoding JSON")
return nil
}
}

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
if let location = locations.last {
currentLocationName(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
}
}

func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
print("Location Manager Error: \(error)")
}

private func currentLocationName(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
let location = CLLocation(latitude: latitude, longitude: longitude)
geocoder.reverseGeocodeLocation(location) { placemarks, error in
if let city = placemarks?.first?.locality {
self.weatherShow(search: city)
} else {
self.location.text = "Unknown"
}
}
}

// Helper function to update temperature label based on the selected unit
private func updateTemperatureLabel(for weather: weatherResponse) {
let temp = value ? weather.current.temp_c : weather.current.temp_f
Temperature.text = value ? "\(temp)C" : "\(temp)F"
}

// Helper function to update the weather image based on the condition code
private func updateWeatherImage(for weather: weatherResponse) {
let code = weather.current.condition.code
let config = UIImage.SymbolConfiguration(paletteColors: [.systemYellow, .white])

switch code {
case 1000:
Image.preferredSymbolConfiguration = config
Image.image = UIImage(systemName: "sun.max")
case 1003...1009:
Image.preferredSymbolConfiguration = config
Image.image = UIImage(systemName: "sun.min")
case 1010...1050:
Image.preferredSymbolConfiguration = config
Image.image = UIImage(systemName: "snowflake.circle.fill")
case 1050...1079:
Image.preferredSymbolConfiguration = config
Image.image = UIImage(systemName: "cloud.drizzle")
case 1180...1209:
Image.preferredSymbolConfiguration = config
Image.image = UIImage(systemName: "cloud.bolt")
case 1210...1260:
Image.preferredSymbolConfiguration = config
Image.image = UIImage(systemName: "snowflake")
case 1270...1285:
Image.preferredSymbolConfiguration = config
Image.image = UIImage(systemName: "cloud.sleet.fill")
default:
Image.preferredSymbolConfiguration = config
Image.image = UIImage(systemName: "cloud")
}
}
}

// Model structures to parse the response from the weather API
struct weatherResponse: Decodable {
let location: Location
let current: Weather
}

struct Location: Decodable {
let name: String
}

struct Weather: Decodable {
let temp_c: Float
let temp_f: Float
let condition: WeatherCondition
}

struct WeatherCondition: Decodable {
let text: String
let code: Int
}



