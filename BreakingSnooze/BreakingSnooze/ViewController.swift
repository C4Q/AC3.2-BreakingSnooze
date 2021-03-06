//
//  ViewController.swift
//  BreakingSnooze
//
//  Created by C4Q on 1/9/17.
//  Copyright © 2017 C4Q. All rights reserved.
//
//APIKEYFORRADIO = ed4616717617f6e9d090f88c8f
import Foundation
import UIKit
import CoreData
import CoreLocation
import AVFoundation

fileprivate var sourcesURL = "https://newsapi.org/v1/sources"
fileprivate let reuseIdentifer = "Top Stories Cell"

class ViewController: UIViewController, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: \\ -Outlets
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var conditionsImageView: UIImageView!
    @IBOutlet weak var verticalLineView: UIView!
    @IBOutlet weak var degreeIconView: UIImageView!
    @IBOutlet weak var listeningToLabel: UILabel!
    @IBOutlet weak var radioStationNameLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var breakingSnoozeBackgroundView: UIView!
    @IBOutlet weak var breakingNewsLabel: UILabel!
    @IBOutlet weak var localNewsTableView: UITableView!
    
    @IBOutlet weak var detailCompanyLabel: UILabel!
    
    //MARK: - Properties
    var mainContext: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    private var controller: NSFetchedResultsController<NewsSource>!
    
    let locationManager: CLLocationManager = {
        let locMan = CLLocationManager()
        
        locMan.desiredAccuracy = 25.0
        locMan.distanceFilter = 25.0
        
        return locMan
    }()
    
    var currentWeather: [Weather] = []
    lazy var allArticles: [SourceArticles] = []
    let sources = ["associated-press", "bloomberg", "buisness-insider", "buzzfeed","cnbc","cnn", "google-news", "hacker-news","mashable", "national-geographic", "newsweek", "new-york-magazine", "techcrunch", "techadar", "the-economist", "the-huffington-post", "the-new-york-times", "usa-today", "time", "the-washington-post"]
     let randomNum = Int(arc4random_uniform(UInt32(19)))
     var audioPlayer = AVAudioPlayer()
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name:NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        locationManager.delegate = self
        localNewsTableView.delegate = self
        localNewsTableView.dataSource = self
        permission()
        initializeFetchedResultsController()
        getSources()
        whiteTextShadow()
        setUpButtonImages()
        getArticlesFromSources()
        setUpAudio()
        self.breakingNewsLabel.text = "Todays Breaking Snooze courtesy of"
        self.detailCompanyLabel.text = "\(sources[randomNum])"
    }
    
    func loadList(notification: NSNotification){
        let userDefaults = UserDefaults.standard
        let locationDict = userDefaults.value(forKey: "locationSave")
        guard let locDict = locationDict as? [String : Any],
            let latCoord = locDict["latCoord"] as? String,
            let longCoord = locDict["longCoord"] as? String,
            let didSetOwnLocation = locDict["didSetOwnLocation"] as? Bool else { return }
        if didSetOwnLocation == false {
            guard let lat = locationManager.location?.coordinate.latitude,
                let long = locationManager.location?.coordinate.longitude else { return }
            let latCoord =  String(format: "%0.4f", lat )
            let longCoord = String(format: "%0.4f", long)
            loadData(endPoint: "http://api.openweathermap.org/data/2.5/weather?lat=\(latCoord)&lon=\(longCoord)&appid=22b1e9d953bb8df3bcdf747f549be645&units=imperial")
            self.view.reloadInputViews()
        } else {
            loadData(endPoint: "http://api.openweathermap.org/data/2.5/weather?lat=\(latCoord)&lon=\(longCoord)&appid=22b1e9d953bb8df3bcdf747f549be645&units=imperial")
            self.view.reloadInputViews()
        }
    }
    
    func setUpButtonImages() {
        let playPauseImage = UIImage(named: "play_button")
        playPauseButton.setBackgroundImage(playPauseImage, for: UIControlState.normal)
        
        let settingsImage = UIImage(named: "settings_Icon")
        settingsButton.setBackgroundImage(settingsImage, for: UIControlState.normal)
        
        let degreeImage = UIImage(named: "degree_Icon_1x")
        degreeIconView.image = degreeImage
    }
    
    func whiteTextShadow() {
        let _ = [
            temperatureLabel,
            locationLabel,
            conditionsImageView,
            verticalLineView,
            degreeIconView,
            listeningToLabel,
            radioStationNameLabel,
            breakingSnoozeBackgroundView,
            breakingNewsLabel,
            detailCompanyLabel
            ].map { $0.layer.shadowOffset = CGSize(width: 0, height: 0) }
        
        let _ = [
            temperatureLabel,
            locationLabel,
            conditionsImageView,
            verticalLineView,
            degreeIconView,
            listeningToLabel,
            radioStationNameLabel,
            breakingNewsLabel,
            detailCompanyLabel
            ].map { $0.layer.shadowOpacity = 0.50 }
        
        breakingSnoozeBackgroundView.layer.shadowOpacity = 0.10
        
        let _ = [
            temperatureLabel,
            locationLabel,
            conditionsImageView,
            verticalLineView,
            degreeIconView,
            listeningToLabel,
            radioStationNameLabel,
            breakingSnoozeBackgroundView,
            breakingNewsLabel,
            detailCompanyLabel
            ].map { $0.layer.shadowRadius = 6 }
    }
    
    //MARK: - Load data from API
    
    func loadData(endPoint: String) {
        APIManager.shared.getData(urlString: endPoint) { (data: Data?) in
            if data != nil {
                
                if let new = Weather.getData(from: data!) {
                    self.currentWeather = new
                }
                DispatchQueue.main.async {
                    let imageName = self.currentWeather[0].icon
                    let imageString = { () -> String in
                        var articleURL = imageName
                        if articleURL.characters.count > 3 {
                            articleURL = String(articleURL.characters.suffix(3))
                            return articleURL
                        }
                        return articleURL
                    }()
                    let image = UIImage(named: imageString)
                    self.conditionsImageView.image =  image
                    
                    self.temperatureLabel.text = String(Int(self.currentWeather[0].temp.rounded()))
                    self.locationLabel.text = "\(self.currentWeather[0].name), \(self.currentWeather[0].country)"
                    print("\(self.currentWeather[0].name), \n\(self.currentWeather[0].country)")
                    
                    self.view.reloadInputViews()
                }
                
            }
        }
        
    }
    
    func getSources() {
        APIManager.shared.getData(urlString: sourcesURL)
        { (data: Data?) in
            if let validData = data {
                if let jsonData = try? JSONSerialization.jsonObject(with: validData, options:[]) {
                    if let wholeDict = jsonData as? [String:Any],
                        let rawSources = wholeDict["sources"] as? [[String:Any]] {
                        
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        let pc = appDelegate.persistentContainer
                        pc.performBackgroundTask { (context: NSManagedObjectContext) in
                            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                            
                            // Comment #2
                            // insert your core data objects here
                            for rawSource in rawSources {
                                let newsSource = NewsSource(context: context)
                                newsSource.parseJson(from: rawSource)
                            }
                            do {
                                try context.save()
                            }
                            catch let error {
                                print(error)
                            }
                            
                            DispatchQueue.main.async {
                                self.initializeFetchedResultsController()
                                //self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func initializeFetchedResultsController() {
        let request: NSFetchRequest<NewsSource> = NewsSource.fetchRequest()
        let sort = NSSortDescriptor(key: "sourceName", ascending: true)
        request.sortDescriptors = [sort]
        
        self.controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        
        do {
            try controller.performFetch()
            // self.tableView.reloadData()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Core Location
    
    func permission() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            print("All Good")
        case .denied, .restricted:
            print("NOPE")
            guard let validSettingsURL = URL(string: UIApplicationOpenSettingsURLString) else {return}
            UIApplication.shared.open(validSettingsURL, options: [:], completionHandler: nil)
        case .notDetermined:
            print("IDK")
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            self.view.reloadInputViews()
        case .denied, .restricted:
            manager.stopUpdatingLocation()
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let validLocation = locations.last else {return}
        let latCoordinate = validLocation.coordinate.latitude
        let longCoordinate = validLocation.coordinate.longitude
        var latCoord =  String(format: "%0.4f", latCoordinate )
        var longCoord = String(format: "%0.4f", longCoordinate )
        
        let userDefaults = UserDefaults.standard
        
        let locationDict: [String : Any] = ["latCoord" : latCoord,
                                            "longCoord" : longCoord,
                                            "didSetOwnLocation" : false
        ]
        
        if var locationSave = userDefaults.value(forKeyPath: "locationSave") {
            guard let locationDictionary = locationSave as? [String : Any],
                let didSetOwnLocation = locationDictionary["didSetOwnLocation"] as? Bool else { return }
            if didSetOwnLocation == false {
                locationSave = locationDict
                userDefaults.set(locationSave, forKey: "locationSave")
            } else {
                guard let lat = locationDictionary["latCoord"] as? String,
                    let long = locationDictionary["latCoord"] as? String else { return }
                latCoord = lat
                longCoord = long
            }
        }
        
        loadData(endPoint: "http://api.openweathermap.org/data/2.5/weather?lat=\(latCoord)&lon=\(longCoord)&appid=22b1e9d953bb8df3bcdf747f549be645&units=imperial")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        dump(error)
    }
    
    //MARK: // -Helper Functions
    

    func getArticlesFromSources() {
//        let random = sources[randomNum]
        let endpoint = "https://newsapi.org/v1/articles?source=hacker-news&sortBy=top&apiKey=df4c5752e0f5490490473486e24881ef"
        APIManager.shared.getData(urlString: endpoint) { (data: Data?) in
            if data != nil {
                
                if let article = SourceArticles.parseArticles(from: data!) {
                    self.allArticles = article
                    
                    
                }
                
                DispatchQueue.main.async {
                    self.localNewsTableView.reloadData()
                }
                
            }
        }
        
    }
    func setUpAudio() {
        let music = Bundle.main.path(forResource: "Viva_La_Vida", ofType: ".mp3")
        
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: music!))
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch {
                print(error)
        }
    }
    //MARK: // -Table View Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! TopStoriesTableViewCell
        
        let article = allArticles[indexPath.row]
        cell.titleLabel.text = article.title
        cell.detailLabel.text = article.description
        
        
        APIManager.shared.getData(urlString: article.imageURL) {(data: Data?) in
            if let validData = data {
                DispatchQueue.main.async {
                    cell.photoImageView.image = UIImage(data: validData)
                    cell.setNeedsDisplay()                }
            }
            
        }
        
        return cell
    }
    

    //MARK: -Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selected = segue.destination as? TopStoriesWebViewController,
            let cell = sender as? TopStoriesTableViewCell,
            let articleOf = localNewsTableView.indexPath(for: cell) {
            selected.article = allArticles[articleOf.row]
        }
        
    }
    
    //MARK: -Actions
    var imagePlay = UIImage()
    
    @IBAction func playPauseButtonPressed(_ sender: UIButton) {
        if !audioPlayer.isPlaying {
            imagePlay = UIImage(named:"Pause")!
            audioPlayer.play()
            playPauseButton.setBackgroundImage(imagePlay, for: UIControlState.normal)
            self.radioStationNameLabel.text = "Viva La Vida"
        } else {
            audioPlayer.stop()
            imagePlay = UIImage(named:"play_button")!
            playPauseButton.setBackgroundImage(imagePlay, for: .normal)
            self.radioStationNameLabel.text = "Paused"
        }
        
    }
}

