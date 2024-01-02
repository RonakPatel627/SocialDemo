//
//  HomeViewController.swift
//  SocialDemo
//
//  Created by STL on 01/01/2024.
//

import UIKit
import GoogleSignIn
import Alamofire
import SDWebImage
import CoreData
import Network

class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var homeViewModel = HomeViewModel()
    var arrFeed : Welcome!
    var sqliteHelper = SQLiteHelper()
    let monitor = NWPathMonitor()
    var isOnline: Bool = false
    var offlineData: [CDAPIResponse] = []
    
    var currentPage: Int = 1
    let itemsPerPage: Int = 10
    var isFetchingData: Bool = false
    
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.showsVerticalScrollIndicator = false
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "Tablecell")
        
        self.setupResult()
        self.loadNextBatchOfItems()
        
        // Do any additional setup after loading the view.
        if let user = homeViewModel.user {
            print("User details in HomeViewController: Email: \(user.email ?? ""), Name: \(user.name ?? "")")
            
        }
        
    }
    
    func setupResult(){
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied{
                print("Conncted")
                self.isOnline = true
                self.parseJson(page: self.currentPage)
                
                
            }else{
                print("Not Connected")
                self.isOnline = false
                DispatchQueue.main.async { [self] in
                    
                    if offlineData.isEmpty {
                        self.checkCoreData()
                    }
                    
                    
                }
            }
        }
        monitor.start(queue: DispatchQueue.global())
    }
    
    
    
    // MARK: - Using SQLite
    //    func parseJson(page: Int) {
    //        let url = "https://rss.applemarketingtools.com/api/v2/us/apps/top-free/50/apps.json"
    //
    //        // Check for internet connectivity
    //        if isInternetAvailable() {
    //            AF.request(url, method: .get, parameters: nil, headers: nil).responseJSON { response in
    //                guard let info = response.data else {
    //                    // Handle error case
    //
    //                    // Fetch data from SQLite
    //                    let items = self.sqliteHelper.getAllItems()
    //                    print("Items from SQLite: \(items)")
    //                    self.arrFeed = nil // Set arrFeed to nil to indicate that network data is not available
    //                    self.tableView.reloadData()
    //
    //                    return
    //                }
    //
    //                print("response >>>>>>>>", response)
    //                self.arrFeed = try? JSONDecoder().decode(Welcome.self, from: info)
    //                print(self.arrFeed as Any)
    //                if let arrFeed = self.arrFeed {
    //                    for result in arrFeed.feed.results {
    //                        self.sqliteHelper.insertItem(name: result.name, imageUrl: result.artworkUrl100)
    //                    }
    //                }
    //
    //                // Fetch data from SQLite
    //                let items = self.sqliteHelper.getAllItems()
    //                print("Items from SQLite: \(items)")
    //                self.tableView.reloadData()
    //            }
    //        } else {
    //            // Fetch data from SQLite when there is no internet connection
    //            let items = self.sqliteHelper.getAllItems()
    //            print("Items from SQLite: \(items)")
    //            self.arrFeed = nil // Set arrFeed to nil to indicate that network data is not available
    //            self.tableView.reloadData()
    //        }
    //    }
    //
    //    // Function to check for internet connectivity
    //    func isInternetAvailable() -> Bool {
    //        return NetworkReachabilityManager()?.isReachable ?? false
    //    }
    
    
    // MARK: - Using Core Data
    
    func saveToCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        for result in arrFeed.feed.results {
            let cdApiResponseEntity = CDAPIResponse(context: managedContext)
            cdApiResponseEntity.name = result.name
            cdApiResponseEntity.image = result.artworkUrl100
            cdApiResponseEntity.id = UUID()
            cdApiResponseEntity.artistName = result.artistName
            cdApiResponseEntity.url = result.url
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save to CoreData. \(error), \(error.userInfo)")
            }
        }
    }
    
    func checkCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<CDAPIResponse>(entityName: "CDAPIResponse")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            self.offlineData = results
            print("self.offlineData >>>>", self.offlineData)
//            if !self.offlineData.isEmpty {
                self.tableView.reloadData()
//            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func parseJson(page: Int) {
        
        let url = "https://rss.applemarketingtools.com/api/v2/us/apps/top-free/50/apps.json"
        let parameters: [String: Any] = ["page": page, "limit": itemsPerPage]
        AF.request(url,
                   method: .get,
                   parameters: parameters,
                   headers: nil).responseJSON {
            (response) in
            guard let info = response.data else {
                return
            }
//            print("response >>>>>>>>", response)
            self.arrFeed = try? JSONDecoder().decode(Welcome.self, from: info)
            print(self.arrFeed as Any)
            self.tableView.reloadData()
            self.saveToCoreData()
            self.loadingIndicator.stopAnimating()
        }
    }
    
    func loadNextBatchOfItems() {
        // Start the loading indicator
        loadingIndicator.startAnimating()
        
        // Load the next batch of items after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self else { return }
            self.currentPage += 1
            self.isFetchingData = true
            self.parseJson(page: self.currentPage)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set the frame of the loading indicator as the table view's footer view
        loadingIndicator.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40)
        tableView.tableFooterView = loadingIndicator
    }
    
    @IBAction func btnProfileDidTap(_ sender: Any) {
        var userEmail: String?
        var userName: String?
        if let user = homeViewModel.user {
            userEmail = user.email
            userName = user.name
        }
        let VC = self.storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        VC.profileViewModel = ProfileViewModel(userEmail: userEmail, userName: userName)
        print("ProfileViewModel user: \(VC.profileViewModel?.user)")
        
        self.navigationController?.pushViewController(VC, animated: true)
        
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if arrFeed != nil{
//            return arrFeed.feed.results.count
//        }else{
//            return 0
//        }
        if isOnline {
            return arrFeed?.feed.results.count ?? 0
        } else {
            return offlineData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tablecell", for: indexPath) as! TableViewCell
//        if arrFeed != nil {
//
//            let data = arrFeed.feed.results[indexPath.row]
//            //            print("cellForRowAt>>>>>>>>>>", data)
//
//            cell.selectionStyle = .none
//            cell.titleLbl.text = data.name
//            // cell.profileImg.image = try? UIImage(data: Data(contentsOf: URL(string: arrFeed.feed.results[indexPath.row].artworkUrl100)!))
//            if let imageUrl = URL(string: data.artworkUrl100) {
//                URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
//                    if let imageData = data {
//                        DispatchQueue.main.async {
//                            cell.profileImg.image = UIImage(data: imageData)
//                        }
//                    }
//                }.resume()
//            }
        
        if isOnline {
            let data = arrFeed?.feed.results[indexPath.row]
            cell.titleLbl.text = data?.name
            if let imageUrl = URL(string: data?.artworkUrl100 ?? "") {
                URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                    if let imageData = data {
                        DispatchQueue.main.async {
                            cell.profileImg.image = UIImage(data: imageData)
                        }
                    }
                }.resume()
            }
        } else {
            let data = offlineData[indexPath.row]
            cell.titleLbl.text = data.name
            if let imageUrl = URL(string: data.image ?? "") {
                URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                    if let imageData = data {
                        DispatchQueue.main.async {
                            cell.profileImg.image = UIImage(data: imageData)
                        }
                    }
                }.resume()
            }
            
        }
            
            cell.profileImg.layer.cornerRadius = 8.0
            cell.mainView.layer.cornerRadius = 8.0
            cell.mainView.layer.masksToBounds = true
            cell.mainView.layer.shadowColor = UIColor.green.cgColor
            cell.mainView.layer.shadowOpacity = 1
            cell.mainView.layer.shadowOffset = .zero
            cell.mainView.layer.shadowRadius = 10
            cell.mainView.layer.shadowColor = UIColor.black.cgColor
            cell.mainView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
            cell.mainView.layer.shadowRadius = 2.0
            cell.mainView.layer.shadowOpacity = 0.5
            cell.mainView.layer.masksToBounds = false
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}


