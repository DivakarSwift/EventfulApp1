//
//  SearchVC.swift
//  Eventful
//
//  Created by Mohammed Abubaker on 7/23/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import PinterestSegment
import AlgoliaSearch
import Alamofire
import DZNEmptyDataSet

class resultObj {
    var name : String = ""
    var img : String = ""
    var desc : String = ""
}

class SearchVC: UIViewController,DeleteButtonDelegate {
    
    struct indice {
        static let events = "events"
        static let users = "users"
    }
    
    struct Algolia {
        static let appID = "3OSE97W06O"
        static let apiKey = "22c7b6d9fddd424d07701352dccf2745"
    }
    
    
    let searchImage : UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "search")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    let searchTxt : UITextField = {
       let TF = UITextField()
        TF.returnKeyType = .search
        TF.placeholder = "Search what you want"
        TF.font = UIFont.systemFont(ofSize: 14.0)
        TF.addTarget(self, action: #selector(instantSearch), for: UIControlEvents.editingChanged)

        TF.borderStyle = .none
        TF.clearButtonMode = .whileEditing
        return TF
    }()
    
    
    @objc func instantSearch(textField: UITextField){
        guard let text = textField.text, text != "" else {
            return
        }
        doSearch(searchText: text, index: client.index(withName: self.index))
    }
    let cancelButton : UIButton = {
       let button = UIButton()
       button.addTarget(self, action: #selector(hideCancelButton), for: .touchUpInside)
       button.setTitle("Cancel", for: .normal)
       button.setTitleColor(UIColor.darkGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        button.isHidden = true
       return button
    }()
    
    
    lazy var topSearchesLabel : UILabel = {
        let label = UILabel()
        label.text = "Top Searches"
        label.font =  UIFont.systemFont(ofSize: 14.0)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    lazy var topSearches: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let searchHistoryLabel : UILabel = {
       let label = UILabel()
        label.text = "Search History"
        label.font =  UIFont.systemFont(ofSize: 14.0)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    let searchHistory: UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: .grouped)
        tv.backgroundColor = .white
        tv.separatorStyle = .singleLine
        tv.allowsSelection = true
        tv.showsVerticalScrollIndicator = false
        tv.separatorColor = UIColor(hex: "EBEBEB")
        tv.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        return tv
    }()
    
    let searchResult: UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: .grouped)
        tv.allowsSelection = true
        tv.backgroundColor = .white
        tv.showsVerticalScrollIndicator = false
        return tv
    }()
    
    var mainView = UIView()
    
    var resultView : UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
//    ✔︎@IBOutlet weak var cancelButton: UIButton!
//    ✔︎@IBOutlet weak var searchTxt: UITextField!
//    ✔︎@IBOutlet weak var mainView: UIView!
//    ✔︎@IBOutlet weak var searchView: UIView!
//    ✔︎@IBOutlet weak var topSearches: UICollectionView!
//    ✔︎@IBOutlet weak var searchHistory: UITableView!
//    ✔︎@IBOutlet weak var searchResult: UITableView!
    
    
    
    var style = PinterestSegmentStyle()
    var _topSearches = [String]()
    var _searchHistory = [String]()
    var _searchResult = [resultObj]()
    let client = Client(appID: Algolia.appID, apiKey: Algolia.apiKey)
    var index = indice.events
    var topEvents = [String]()
    var topUsers = [String]()
    let searchCellID = "CustomCell"
    let historyCellID = "HistoryCell"
    let topsCellID = "TopCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        indexSwap()
        getTops(index: index)
    }
    
    func setupView() {
        self.navigationController?.isNavigationBarHidden = true
        
        searchTxt.delegate = self
        topSearches.delegate = self
        topSearches.dataSource = self
        topSearches.register(TopCell.self, forCellWithReuseIdentifier: topsCellID)
        topSearches.emptyDataSetSource = self
        topSearches.emptyDataSetDelegate = self
        
        searchResult.delegate = self
        searchResult.dataSource = self
        searchResult.tableFooterView = UIView()
        searchResult.register(CustomCell.self, forCellReuseIdentifier: searchCellID)
        searchResult.emptyDataSetSource = self
        searchResult.emptyDataSetDelegate = self

        searchHistory.delegate = self
        searchHistory.dataSource = self
        searchHistory.tableFooterView = UIView()
        searchHistory.register(HistoryCell.self, forCellReuseIdentifier: historyCellID)
        searchHistory.emptyDataSetSource = self
        searchHistory.emptyDataSetDelegate = self

        
        let searchView = UIView(frame: CGRect(x: 0, y: 80, width: self.view.frame.width, height: 50))
        view.addSubview(searchView)
        
        searchView.addSubview(searchImage)
        searchView.addSubview(cancelButton)
        searchView.addSubview(searchTxt)
        
        
        searchImage.snp.makeConstraints { (make) in
            make.height.equalTo(15.0)
            make.width.equalTo(20.0)
            make.centerY.equalTo(searchView.snp.centerY)
            make.leading.equalToSuperview().offset(15.0)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.width.equalTo(50.0)
            make.centerY.equalTo(searchView.snp.centerY)
            make.trailing.equalToSuperview().offset(-15.0)
        }
        
        searchTxt.snp.makeConstraints { (make) in
            make.centerY.equalTo(searchImage.snp.centerY)
            make.left.equalTo(searchImage.snp.right).offset(8.0)
            make.right.equalTo(cancelButton.snp.left).offset(-15.0)
        }
        
        view.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.top.equalTo(searchView.snp.bottom)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(15.0)
            make.trailing.equalToSuperview().offset(-15.0)
        }
        
        mainView.addSubview(searchHistory)
        searchHistory.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        let topSearchesView = UIView(frame: CGRect(x: 0, y: 0, width: searchHistory.frame.width, height: 160))
        
        searchHistory.tableHeaderView = topSearchesView
        topSearchesView.addSubview(topSearchesLabel)
        topSearchesView.addSubview(topSearches)
        topSearchesView.addSubview(searchHistoryLabel)
        
        topSearchesLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(8.0)
        }
        
        topSearches.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(85.0)
            make.top.equalTo(topSearchesLabel.snp.bottom).offset(10.0)
        }
        
        searchHistoryLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.top.equalTo(topSearches.snp.bottom).offset(15.0)
        }
        
        // Search Result
        view.addSubview(resultView)
        resultView.snp.makeConstraints { (make) in
            make.top.equalTo(searchView.snp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
        }
        
        resultView.addSubview(searchResult)
        searchResult.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    func indexSwap(){
        style.indicatorColor = UIColor(white: 0.95, alpha: 1)
        style.titleMargin = 15
        style.titlePendingHorizontal = 14
        style.titlePendingVertical = 14
        style.titleFont = UIFont.boldSystemFont(ofSize: 14)
        style.normalTitleColor = UIColor.lightGray
        style.selectedTitleColor = UIColor.darkGray
        
        let segment = PinterestSegment(frame: CGRect(x: 0, y: 40, width: 150, height: 40), segmentStyle: style, titles: ["Events", "Users"])
        segment.center.x = self.view.center.x
        self.view.addSubview(segment)
        segment.valueChange = { index in
            print(index)
            if index == 0 {
                self.index = indice.events
                self.getTops(index: self.index)
            } else if index == 1 {
                self.index = indice.users
                self.getTops(index: self.index)
            }
        }
    }
    
    func getTops(index:String){
        var array = [String]()
        var httpHeader = HTTPHeaders()
        httpHeader["X-Algolia-Application-Id"] = Algolia.appID
        httpHeader["X-Algolia-API-Key"] = Algolia.apiKey
        
        let url = "https://analytics.algolia.com/2/searches?index=\(index)"
        
        Alamofire.request(url, method: .get, parameters: nil, headers: httpHeader).responseString { (response) in
            switch response.result {
            case .success(let val):
                print(val)
                let searchDict = (UIApplication.shared.delegate as! AppDelegate).convertToDictionary(text: val)
                
                if let arr = searchDict!["searches"] as? [NSDictionary] {
                    for obj in arr {
                        array.append(obj["search"] as! String)
                    }
                }
                
                self._topSearches = array
                self.topSearches.reloadData()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    @IBAction func hideCancelButton(_ sender: UIButton) {
        self.searchTxt.text = ""
        searchTxt.endEditing(true)
        self._searchResult = []
        self.searchResult.reloadData()
        self.searchHistory.reloadData()

        //Transition to the original view
        UIView.animate(withDuration: 0.3, animations: {
            self.mainView.alpha = 1
            self.resultView.alpha = 0
        }) { (true) in
            self.mainView.isHidden = false
            self.resultView.isHidden = true
            self.cancelButton.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return true
        }
        _searchHistory.append(text)
        doSearch(searchText: text, index: client.index(withName: self.index))
        return true
    }
    
    func doSearch(searchText:String,index:Index){
        DispatchQueue.main.async {
            let query = Query(query: searchText)
            if self.index == indice.events {
                query.restrictSearchableAttributes = ["event:name"]
            } else {
                query.restrictSearchableAttributes = ["username","name"]
            }

            index.search(query, completionHandler: { (content, error) -> Void in
                if error == nil {
                    //print(content)
                    let data = content!["hits"]! as! [NSDictionary]
                    print("Result: \(data.count)")
                    self._searchResult = []
                    for result in data {
                        if self.index == "events"{
                            let obj = resultObj()
                            obj.name = result["event:name"] as? String ?? ""//name
                            obj.img = result["event:imageURL"] as? String ?? ""
                            obj.desc = result["event:city"] as? String ?? ""
                            obj.desc += " "
                            obj.desc += result["event:state"] as? String ?? ""
                            self._searchResult.append(obj)
                        } else {
                            let obj = resultObj()
                            obj.name = result["name"] as? String ?? ""
                            obj.img = result["profilePic"] as? String ?? ""
                            self._searchResult.append(obj)
                        }
                        self.searchResult.reloadData()
                    }
                } else {
                    //print(error)
                }
            })
        }
    }
    
    func deleteButtonTaped(at index: IndexPath) {
        for (i,_) in self._searchHistory.enumerated().reversed() {
            if i == index.row {
                self._searchHistory.remove(at: i)
            }
        }
        searchHistory.reloadData()
    }

}

extension SearchVC: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {

        UIView.animate(withDuration: 0.3, animations: {
            self.mainView.alpha = 0
            self.resultView.alpha = 1
        }) { (true) in
            self.mainView.isHidden = true
            self.resultView.isHidden = false
            self.cancelButton.isHidden = false
        }

    }
    
    

}

extension SearchVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _topSearches.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: topsCellID, for: indexPath) as! TopCell
        cell.cellInit(text: self._topSearches[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = (collectionView.frame.width - 40) / 4
            return CGSize(width: width, height: 18.0)
    }

    //Action for popular searches
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            self.searchTxt.text = _topSearches[indexPath.row]
    }

}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchResult {
        return _searchResult.count
        } else {
        return _searchHistory.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == searchResult {
            let cell = tableView.dequeueReusableCell(withIdentifier: searchCellID, for: indexPath) as! CustomCell
        cell.cellInit(obj: self._searchResult[indexPath.row])
        return cell
        } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: historyCellID, for: indexPath) as! HistoryCell
            cell.titleLabel.text = _searchHistory[indexPath.row]
            cell.delegate = self
            cell.indexPath = indexPath
        return cell
        }
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Action for search history table
        if tableView == searchHistory {
        self.searchTxt.text = _searchHistory[indexPath.row]
        //Action for search result
        } else if tableView == searchResult {

        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == searchResult {
        return 90
        } else {
        return 50
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

}

extension SearchVC: DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attribute = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 10)]
        let str = "No results to display."
        return NSAttributedString(string: str, attributes: attribute)
    }
}
