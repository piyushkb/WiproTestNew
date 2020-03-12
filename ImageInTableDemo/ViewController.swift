//
//  ViewController.swift
//  ImageInTableDemo
//
//  Created by apple on 29/01/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

struct UserViewModel {
    
    var image = ""
    var title = ""
    var des = ""
    
    init(image:String,title:String,des:String) {
        self.title = title
        self.image = image
        self.des = des
    }
}

class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate{
   //MARK: variables
  @IBOutlet weak var tableView: UITableView!
   
    var userArray =  [UserViewModel]()
    var userDetails:UserDetails!
    var spinner = UIActivityIndicatorView()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        addSpinnerInTableView()
    }
    
    //MARK:funtions
    func addSpinnerInTableView(){
        spinner = UIActivityIndicatorView(style: .gray)
        spinner.stopAnimating()
        spinner.hidesWhenStopped = true
        spinner.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 60)
        tableView.tableFooterView = spinner
    }
    fileprivate func getUserDetails() {
        for item in self.userDetails.rows ?? [] {
            if let image = item.imageHref{
                if(!image.isEmpty) {
                    let title = item.title ?? "No Title"
                    let desc = item.description ?? "No Description"
                    self.userArray.append(UserViewModel(image: image, title: title, des: desc))
                }
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
        getApiCall { (data, error) in
            self.userDetails = data as? UserDetails
            
            DispatchQueue.main.async {
                self.title = self.userDetails.title
            }
            
            self.getUserDetails()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                //TODO: when we have more data need to stopAnimating
                self.spinner.stopAnimating()
                }
            }
         
       }
    
   //MARK:Api Call
    func getApiCall(completion: @escaping (_ jsonData: Any?, _ error: String?)->()) {
        
        let url = URL(string: "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json")!
              
             
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                completion(nil, "Error")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                let result = ResponseStatusHandler.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        
                        
                        completion(nil, ResponseStatus.noData.rawValue)
                        return
                    }
                    do {
                        let utf8Data = String(decoding: responseData, as: UTF8.self).data(using: .utf8)
                        let userDetails = try JSONDecoder().decode(UserDetails.self, from:utf8Data!)
                        completion(userDetails,nil)
                        
                    }catch {
                        print(error)
                        completion(nil, ResponseStatus.unableToDecode.rawValue)
                    }
                case .failure(let error):
                    completion(nil, error)
                }
            }
            
        }
        
        task.resume()
    }
    
    
   //MARK:TableView DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.userArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell")  as!  ImageCell
        cell.imageFeedImage.sd_setImage(with: URL(string: item.image), placeholderImage: UIImage(named: "loader"))
        cell.imageTitle.text =  item.title
        cell.imageDescription.text = item.des
        return cell
    }
   
     func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            let offset = scrollView.contentOffset
            let bounds = scrollView.bounds
            let size = scrollView.contentSize
            let inset = scrollView.contentInset

            let y = offset.y + bounds.size.height - inset.bottom
            let h = size.height

            let reloadDistance = CGFloat(30.0)
            if y > h + reloadDistance {
                spinner.startAnimating()
                //MARK: call getApiCall method when more data to show in tableView
                print("fetch more data")
                 // not call api here so for demo purpose stop animation
                 let seconds = 1.0
                 DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.spinner.stopAnimating()
                 }
                
            }
    }
    

}

