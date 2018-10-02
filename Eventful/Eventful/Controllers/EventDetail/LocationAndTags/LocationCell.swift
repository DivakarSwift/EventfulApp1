//
//  LocationCell.swift
//  Eventful
//
//  Created by Shawn Miller on 9/23/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import TagListView
import CoreLocation
import GoogleMaps
import MapKit


class LocationCell: UICollectionViewCell {
    var zip: Int? {
        didSet{
        }
    }
    var streetAddress: String? {
        didSet{
        }
    }
    var state: String? {
        didSet{
        }
    }
    var city: String? {
        didSet{
        createAddressString()
        }
    }
    let tagList = TagListView()

    var tags: [String]? {
        didSet{
            print("got tags")
            guard let tags = tags else {
                return
            }
            populateTagList(tags: tags)
            
        }
    }
    //wil be responsible for creating the address  label
    lazy var addressLabel : UILabel = {
        let currentAddressLabel = UILabel()
        currentAddressLabel.numberOfLines = 0
        currentAddressLabel.textColor = UIColor.lightGray
        currentAddressLabel.isUserInteractionEnabled = true
        currentAddressLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openMaps)))
        return currentAddressLabel
    }()
    
    lazy var locationLabel : UILabel = {
        let locationLabel = UILabel()
        locationLabel.numberOfLines = 0
        locationLabel.text = "Location"
        locationLabel.textColor = UIColor.rgb(red: 32, green: 32, blue: 32)
        locationLabel.font = UIFont(name: "NoirPro-SemiBold", size: 15)
        
        return locationLabel
    }()
    
    
    @objc func createAddressString(){
        guard let currentZip = zip else{
            return
        }
        guard let streetAddress = streetAddress else{
            return
        }
        guard let state = state else{
            return
        }
        guard let city = city else{
            return
        }
        
        let addressString = (streetAddress.capitalized) + ", "+(city.capitalized) +  ", "+(state.uppercased()) + " "+String(describing: currentZip)
        let attributedText2 = NSMutableAttributedString(string: addressString, attributes: [NSAttributedStringKey.font: UIFont(name: "NoirPro-Light", size: 15) as Any, NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 132, green: 132, blue: 132)])
        addressLabel.attributedText = attributedText2

        
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    fileprivate func setupViews(){
        addSubview(locationLabel)
        addSubview(addressLabel)
        addSubview(tagList)
        locationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top)
            make.left.equalTo(self.snp.left).offset(5)
        }
        addressLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(5)
            make.right.equalTo(self.snp.right)
            make.top.equalTo(locationLabel.snp.bottom).offset(10)
        }
        tagList.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(5)
            make.right.equalTo(self.snp.right)
            make.top.equalTo(addressLabel.snp.bottom).offset(10)
            make.bottom.equalTo(self.snp.bottom).inset(5)

        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func populateTagList(tags : [String]){
        for tag in tags {
            tagList.addTag(tag)
        }
        
        guard let customFont = UIFont(name: "NoirPro-Light", size: 15) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        tagList.textFont = customFont
        tagList.textColor = UIColor.rgb(red: 132, green: 132, blue: 132)
        tagList.alignment = .left
        tagList.tagBackgroundColor = UIColor.white
        tagList.borderColor = UIColor.rgb(red: 185, green: 185, blue: 185)
        tagList.borderWidth = 1
        tagList.cornerRadius = 7
        
    }
    
    
    @objc func openMaps() {
        print("Trying to open a map")
        guard let currentZip = zip else{
            return
        }
        guard let streetAddress = streetAddress else{
            return
        }
        guard let state = state else{
            return
        }
        guard let city = city else{
            return
        }
        let geoCoder = CLGeocoder()
        
        let addressString = (streetAddress) + ", "+(city) +  ", "+(state) + " "+String(describing: currentZip)
        print(addressString)
        geoCoder.geocodeAddressString(addressString) { (placeMark, err) in
            guard let currentPlaceMark = placeMark?.first else{
                return
            }
            guard let lat = currentPlaceMark.location?.coordinate.latitude else {
                return
            }
            guard let long = currentPlaceMark.location?.coordinate.longitude else {
                return
            }
            print(lat)
            print(long)
            if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
                let addressParse = (streetAddress).components(separatedBy: " ")
                print(addressParse[0])
                print(addressParse[1])
                print(addressParse[2])
                let directionsRequest = "comgooglemaps-x-callback://" +
                    "?daddr=\(addressParse[0])+\(addressParse[1])+\(addressParse[2]),+\((city)),+\((state))+\(String(describing: self.zip))" +
                "&x-success=sourceapp://?resume=true&x-source=Haipe"
                
                let directionsURL = URL(string: directionsRequest)!
                UIApplication.shared.open(directionsURL, options: [:], completionHandler: nil)
                
            } else {
                print("Opening in Apple Map")
                
                let coordinate = CLLocationCoordinate2DMake(lat, long)
                let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.01, 0.02))
                let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                let options = [
                    MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
                    MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)]
                mapItem.name = addressString
                mapItem.openInMaps(launchOptions: options)
            }
        }
    }
    
}
