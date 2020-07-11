//
//  ViewController.swift
//  Weather_RestAPI_IB_MVCN
//
//  Created by Ignacio Arias on 2020-07-10.
//  Copyright © 2020 Ignacio Arias. All rights reserved.
//

import UIKit
import Network
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var locationTxt: UITextField!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var cityTemp: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var dataController: DataController!
    
    //Weather object being presented
    var weathers: [Weather]!
    
    
    //Load an activity Indicator. AKA loader

    @IBAction func search(_ sender: Any) {
        
        //Make sure this is not empty
        guard let userTyped = locationTxt.text else {
            return
        }
        
        //Add a loader later
        
        
        
        //Pass the userTyped to a function
        searchUserTyped(userTyped)
        
        
    }
    
    func searchUserTyped(_ location: String) {
        
        let weatherEndPoint = WeatherAPI.EndPoints.getWeatherInfo(cityName: location).url
        
        NetworkController.requestWeatherData(url: weatherEndPoint) { (data, error) in
            
            guard let data = data else { return }
            
            //data print bytes
            
            let decoder = JSONDecoder()
            
            do {
                
                let weatherData = try decoder.decode(WeatherJson.self, from: data)
                
                DispatchQueue.main.async {
                    //Activity stop animating
                    self.cityName.text = weatherData.name
                    self.cityTemp.text = String(weatherData.wind.speed)
                }
            } catch {
                DispatchQueue.main.async {
//                    self.activityIndicator.stopAnimating()
                    self.locationTxt.text = "That's not a city, try again!"
                }
                print("That's not a city!, " + error.localizedDescription)
            }
        }
        
        
    }
    
    
    @IBAction func addToPersistence(_ sender: Any) {
        addingRow()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        loaderIndicator()
        coreDataLogic()
    }
    
    
    @available(iOS 12.0, *)
    func statusDidChange(status: NWPath.Status) {
        if status == .satisfied {
            // Internet connection is back on
            cityName.text = ""
        } else {
            // No internet connection
            cityName.text = "NO NETWORK"
            
        }
    }
    
    fileprivate func coreDataLogic() {
        
        //NSManagedContext, this is step 10.
        let fetchRequest: NSFetchRequest<Weather> = Weather.fetchRequest()
        
        //step 10.1
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            
            // Array from dataSource fetched with coreData
            weathers = result
            //refresh UI by repopulating the data
            tableView.reloadData()
            
        }
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func addingRow() {
            let name = cityName.text
            let num = cityTemp.text
            self.addWeather(name: name!, num: num!)
        }
        
        
        
        //Adds a new weather to the end of the `weathers`  array
        func addWeather(name: String, num: String) {
            
            //Create
            let weather = Weather(context: dataController.viewContext)
            
            weather.name = name
            weather.speed = num
            
            
            //Save to persistent store
            try? dataController.viewContext.save()
            
            //Append adds to the end, insert adds to the init
            weathers.insert(weather, at: 0)
            
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            
        }
        
        
        
        // MARK: - Helpers
        var numberOfWeathers: Int { return weathers.count }
        
        func weather(at indexPath: IndexPath) -> Weather {
            return weathers[indexPath.row]
        }
    }

    // MARK: - DataSource & Delegate
    extension ViewController: UITableViewDataSource, UITableViewDelegate {
        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return numberOfWeathers
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let aWeather = weather(at: indexPath)
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
            
            cell.detailTextLabel?.text = aWeather.name
            
            cell.textLabel?.text = aWeather.speed
            
            return cell
        }
    
}

