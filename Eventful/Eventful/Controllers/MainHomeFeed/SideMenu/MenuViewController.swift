//
//  MenuViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 9/18/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import SideMenuSwift

class MenuViewController: UIViewController {
    let cellID = "cellID"
    let headerID = "headerID"

    let sideMenuTableView: UITableView = {
        let sideMenuTableView = UITableView(frame: CGRect.zero, style: .grouped)
        sideMenuTableView.backgroundColor = .white
        sideMenuTableView.separatorStyle = .none
        sideMenuTableView.showsVerticalScrollIndicator = false
        return sideMenuTableView
    }()
    let footer = MenuFooter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        // Do any additional setup after loading the view.
    }
    
    @objc func configureView(){
        view.backgroundColor = .white
        view.addSubview(sideMenuTableView)
        view.addSubview(footer)
        sideMenuTableView.delegate = self
        sideMenuTableView.dataSource = self
        sideMenuTableView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(view.bounds.height *  (3.50 / 4))
        }
        footer.snp.makeConstraints { (make) in
            make.top.equalTo(sideMenuTableView.snp.bottom)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        registerCells()
    }
    
    @objc func registerCells(){
        sideMenuTableView.register(MenuHeader.self, forCellReuseIdentifier: headerID)
        sideMenuTableView.register(MenuCell.self, forCellReuseIdentifier: cellID)
        footer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.presentSettings)))
    }

    @objc func presentSettings(){
        self.sideMenuController?.hideMenu()
        let settingView = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingView)
        sideMenuController?.contentViewController = settingsNav
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MenuViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
}


extension MenuViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MenuCell
        cell.nameLabel.text = "Option"
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: headerID) as! MenuHeader
        return cell
    }
    

    
    
}

