//
//  WeatherManager.swift
//  Clima
//
//  Created by Anas Salah on 14/08/2024.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(weather: WeatherModel)
}

struct WeatherManager: WeatherManagerDelegate {
    
    let appId = "" // Put your app ID you can generate it from  "https://home.openweathermap.org/api_keys"
    var weatherURL: String {
        return "https://api.openweathermap.org/data/2.5/weather?&units=metric&appid=\(appId)"
    }
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(url: urlString)
        print(urlString)
    }

    func fetchWeather(lat: CLLocationDegrees, long: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(long)"
        performRequest(url: urlString)
        print(urlString)
    }
    
    func performRequest(url: String) {
        guard let url = URL(string: url) else { print("URL is not valid pleas check WeahterManager class line 21 in Model group and here is the url \(url)") ; return }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { data, response, error in
            if error != nil {
                print(error!)
                return
            }
            
            if let safeData = data {
                if let weather = pareseJson(data: safeData) {
                    delegate?.didUpdateWeather(weather: weather)
                } else {
                    print("DAta is Nil line 36 at Services")
                }
            }
        }
        task.resume()
    }
    
    func pareseJson(data: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: data)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionID: id, cityName: name, temperature: temp)
            print(weather)
            return weather
            
        } catch {
            print(error)
            return nil
        }
    }
    
    func didUpdateWeather(weather: WeatherModel) {
        print(weather.temperature)
    }
}
