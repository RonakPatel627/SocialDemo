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

class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var btnGoogleSignOut: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var homeViewModel = HomeViewModel()
    var arrFeed : Welcome!
    var sqliteHelper = SQLiteHelper()
    var currentPage = 1
    var isFetchingData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.showsVerticalScrollIndicator = false
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "Tablecell")
        
        parseJson(page: currentPage)
        
        // Do any additional setup after loading the view.
        if let user = homeViewModel.user {
            print("User details in HomeViewController: Email: \(user.email ?? ""), Name: \(user.name ?? "")")
            
        }
        
    }
    
    //    func parseJson(page: Int) {
    //
    //        let url = "https://rss.applemarketingtools.com/api/v2/us/apps/top-free/50/apps.json"
    //
    //        AF.request(url,
    //                   method: .get,
    //                   parameters: nil,
    //                   headers: nil).responseJSON {
    //            (response) in
    //            guard let info = response.data else {
    //                return
    //            }
    //
    //            print("response >>>>>>>>", response)
    //            self.arrFeed = try? JSONDecoder().decode(Welcome.self, from: info)
    //            print(self.arrFeed as Any)
    //            if let arrFeed = self.arrFeed {
    //                for result in arrFeed.feed.results {
    //                    self.sqliteHelper.insertItem(name: result.name, imageUrl: result.artworkUrl100)
    //                }
    //            }
    //
    //            // Fetch data from SQLite
    //            let items = self.sqliteHelper.getAllItems()
    //            print("Items from SQLite: \(items)")
    //            self.tableView.reloadData()
    //        }
    //    }
    
    
    func parseJson(page: Int) {
        let url = "https://rss.applemarketingtools.com/api/v2/us/apps/top-free/50/apps.json"
        
        // Check for internet connectivity
        if isInternetAvailable() {
            AF.request(url, method: .get, parameters: nil, headers: nil).responseJSON { response in
                guard let info = response.data else {
                    // Handle error case
                    
                    // Fetch data from SQLite
                    let items = self.sqliteHelper.getAllItems()
                    print("Items from SQLite: \(items)")
                    self.arrFeed = nil // Set arrFeed to nil to indicate that network data is not available
                    self.tableView.reloadData()
                   
                    return
                }
                
                print("response >>>>>>>>", response)
                self.arrFeed = try? JSONDecoder().decode(Welcome.self, from: info)
                print(self.arrFeed as Any)
                if let arrFeed = self.arrFeed {
                    for result in arrFeed.feed.results {
                        self.sqliteHelper.insertItem(name: result.name, imageUrl: result.artworkUrl100)
                    }
                }
                
                // Fetch data from SQLite
                let items = self.sqliteHelper.getAllItems()
                print("Items from SQLite: \(items)")
                self.tableView.reloadData()
            }
        } else {
            // Fetch data from SQLite when there is no internet connection
            let items = self.sqliteHelper.getAllItems()
            print("Items from SQLite: \(items)")
            self.arrFeed = nil // Set arrFeed to nil to indicate that network data is not available
            self.tableView.reloadData()
        }
    }
    
    // Function to check for internet connectivity
    func isInternetAvailable() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    
    @IBAction func btnGoogleSignOutDidTap(_ sender: Any) {
        var userEmail: String?
        var userName: String?
        if let user = homeViewModel.user {
            userEmail = user.email
            userName = user.name
        }
        print(userName, userEmail)
        let VC = self.storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        VC.profileViewModel = ProfileViewModel(userEmail: userEmail, userName: userName)
        print("ProfileViewModel user: \(VC.profileViewModel?.user)")
        
        self.navigationController?.pushViewController(VC, animated: true)
        
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrFeed != nil{
            return arrFeed.feed.results.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tablecell", for: indexPath) as! TableViewCell
        if arrFeed != nil {
            
            let data = arrFeed.feed.results[indexPath.row]
            //            print("cellForRowAt>>>>>>>>>>", data)
            
            cell.selectionStyle = .none
            cell.titleLbl.text = data.name
            // cell.profileImg.image = try? UIImage(data: Data(contentsOf: URL(string: arrFeed.feed.results[indexPath.row].artworkUrl100)!))
            if let imageUrl = URL(string: data.artworkUrl100) {
                URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                    if let imageData = data {
                        DispatchQueue.main.async {
                            cell.profileImg.image = UIImage(data: imageData)
                        }
                    }
                }.resume()
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
        }
        return cell
    }
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //
    //        let VC = self.storyboard!.instantiateViewController(withIdentifier: "SecondVC") as! SecondVC
    //
    //        VC.name = arrFeed.feed.results[indexPath.row].artistName
    //        VC.id = arrFeed.feed.results[indexPath.row].id
    //        VC.date = arrFeed.feed.results[indexPath.row].releaseDate
    //        VC.image = try! UIImage(data: Data(contentsOf: URL(string: arrFeed.feed.results[indexPath.row].artworkUrl100)!))!
    //        VC.movie = arrFeed.feed.results[indexPath.row].name
    //
    //        self.navigationController?.pushViewController(VC, animated: true)
    //    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let boundsHeight = scrollView.bounds.height
        
        // Number of items per page
        let itemsPerPage = 10
        
        // Calculate the current page based on the number of items displayed
        let currentDisplayedPage = Int(ceil(Double(arrFeed.feed.results.count) / Double(itemsPerPage)))
        let hasDisplayedFirstSet = currentDisplayedPage > 1
        print(hasDisplayedFirstSet)
        
        if offsetY > contentHeight - boundsHeight * 2 {
            if !isFetchingData && currentDisplayedPage * itemsPerPage < arrFeed.feed.results.count {
                isFetchingData = true
                
                // Show loader while fetching data
                showLoader()
                
                // Fetch data for the next page
                parseJson(page: currentDisplayedPage + 1)
            }
        }
    }
    
    
    func showLoader() {
        let loaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
        let loader = UIActivityIndicatorView(style: .gray)
        loader.center = loaderView.center
        loader.startAnimating()
        loaderView.addSubview(loader)
        
        tableView.tableFooterView = loaderView
        tableView.tableFooterView?.isHidden = false
    }
    
    func hideLoader() {
        tableView.tableFooterView = nil
    }
}
