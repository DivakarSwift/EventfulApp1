//
//  PlacesSearchController.swift
//  Eventful
//
//  Created by Shawn Miller on 4/6/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import GooglePlaces
import SVProgressHUD
import DZNEmptyDataSet

class PlacesSearchController: UIViewController, UICollectionViewDelegateFlowLayout {
    let cellID = "cellID"
    var homeFeedController: HomeFeedController?
    var mainVC: MainViewController?
    let titleView = UILabel()
    var placesClient = GMSPlacesClient()
    var arrayAddress = [GMSAutocompletePrediction]()
    lazy var filter : GMSAutocompleteFilter = {
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        return filter
    }()

    lazy var searchCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.setupShadow2()
        sb.sizeToFit()
        sb.barTintColor = UIColor.white
        sb.layer.borderWidth = 0.5
        sb.layer.borderColor = UIColor.lightGray.cgColor
        sb.layer.cornerRadius = 2.0
        sb.placeholder = "Search"
        sb.delegate = self
        let textFieldInsideUISearchBar = sb.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.font = UIFont.systemFont(ofSize: 14)
        return sb
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        // Do any additional setup after loading the view.
    }
    

    @objc func setupViews(){
        //register a cell to the collectionView
        searchCollectionView.register(SearchPlacesCell.self, forCellWithReuseIdentifier: cellID)
        searchCollectionView.keyboardDismissMode = .onDrag
        searchCollectionView.alwaysBounceVertical = true
        searchCollectionView.backgroundColor = .clear
        searchCollectionView.emptyDataSetDelegate = self
        searchCollectionView.emptyDataSetSource = self

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
        
        view.addSubview(searchBar)
        view.addSubview(searchCollectionView)
        searchBar.snp.makeConstraints { (make) in
            make.left.right.equalTo(view).inset(10)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
            make.height.equalTo(40)
        }
        searchCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        titleView.font = UIFont(name: "NoirPro-Medium", size: 18)
        titleView.text = "Location"
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        self.navigationItem.titleView = titleView
        titleView.isUserInteractionEnabled = true

    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @objc func GoBack(){
        print("BACK TAPPED")
        self.navigationController?.popViewController(animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension PlacesSearchController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayAddress.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! SearchPlacesCell
        cell.sectionNameLabel.attributedText = arrayAddress[indexPath.item].attributedFullText
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 55)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentLocation = arrayAddress[indexPath.item].placeID
        let city = arrayAddress[indexPath.item].attributedPrimaryText.string
        let stateHolder = arrayAddress[indexPath.item].attributedSecondaryText?.string.split(separator: ",")
        let string = "\(city), \(String(describing: stateHolder![0])) ▼"
        self.mainVC?.customLeftBar.cityText.text = string
        guard let location = currentLocation else {
            return
        }
        self.mainVC?.grabUserLocation(placeId: location)
        self.mainVC?.navigationController?.popViewController(animated: true)

    }
    
}

extension PlacesSearchController: UICollectionViewDelegate {

}

extension PlacesSearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text else {
            return
        }
        if searchText == "" {
            self.arrayAddress = [GMSAutocompletePrediction]()
        }else{
            GMSPlacesClient.shared().autocompleteQuery(searchText, bounds: nil, filter: filter, callback: { (res, err) in
                if err == nil && res != nil {
                    self.arrayAddress = res!
                    self.searchCollectionView.reloadData()
                }
            })
        }
        
    }
    
    
}


extension PlacesSearchController: DZNEmptyDataSetDelegate,DZNEmptyDataSetSource{
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attribute = [NSAttributedStringKey.font: UIFont(name: "NoirPro-Light", size: 15),NSAttributedStringKey.foregroundColor: UIColor.black]
        let str = "Hi \(String(describing: User.current.username!))! Here you will be able to search for new and potentially far away cities, in an effort to explore and discover many new events"
        return NSAttributedString(string: str, attributes: attribute as [NSAttributedStringKey : Any])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "icons8-city-filled-50")
    }
    
}
