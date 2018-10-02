//
//  WeatherCell.swift
//  Eventful
//
//  Created by Shawn Miller on 9/23/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class WeatherCell: UICollectionViewCell {
    
    var location: String?{
        didSet{
        }
    }
    
    var date: Date?{
        didSet{
            //will get weather
            guard let date = date else {
                return
            }
            guard  let location = location else {
                return
            }
            fetchWeatherData(location: location, time: date)
        }
    }
    
    
    lazy var weatherLabel: UILabel = {
        let weatherLabel = UILabel()
        weatherLabel.text = "Weather"
        guard let customFont = UIFont(name: "NoirPro-SemiBold", size: 15) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        weatherLabel.textColor = .black
        weatherLabel.textAlignment = .left
        weatherLabel.font = customFont
        weatherLabel.numberOfLines = 0
        return weatherLabel
    }()
    
    lazy var degreesLabel: UILabel = {
        let degreesLabel = UILabel()
        guard let customFont = UIFont(name: "NoirPro-Medium", size: 20) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        degreesLabel.textColor = UIColor.rgb(red: 32, green: 32, blue: 32)
        degreesLabel.textAlignment = .left
        degreesLabel.font = customFont
        degreesLabel.numberOfLines = 0
        return degreesLabel
    }()
    
    lazy var summaryLabel: UILabel = {
        let summaryLabel = UILabel()
        guard let customFont = UIFont(name: "NoirPro-Light", size: 13) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        summaryLabel.textColor = UIColor.rgb(red: 132, green: 132, blue: 132)
        summaryLabel.textAlignment = .left
        summaryLabel.font = customFont
        summaryLabel.numberOfLines = 0
        return summaryLabel
    }()
    
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    fileprivate func setupViews(){
        addSubview(weatherLabel)
        addSubview(degreesLabel)
        addSubview(summaryLabel)
        addSubview(iconImageView)
        weatherLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(10)
            make.left.right.equalTo(self).inset(5)
        }
        
        degreesLabel.snp.makeConstraints { (make) in
            make.top.equalTo(weatherLabel.snp.bottom).offset(10)
            make.left.equalTo(self.snp.left).inset(10)
        }
        
        summaryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(degreesLabel.snp.bottom).offset(5)
            make.left.equalTo(self.snp.left).inset(10)
        }
        iconImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(degreesLabel.snp.centerY)
            make.left.equalTo(degreesLabel.snp.right).offset(35)
        }
    }
    
    
    @objc func fetchWeatherData(location: String, time: Date){
        LocationService.getEventLocation(address: location) { (place) in
            guard let places = place else  {
                return
            }
            
            for place in places {
                print(place.coordinates?.latitude as Any)
                print(place.coordinates?.longitude as Any)
                let jsonURLString = "https://api.darksky.net/forecast/d455ebdd2abdcb5160adc4e70919367c/\(place.coordinates?.latitude ?? 0),\(place.coordinates?.longitude ?? 0),\(Int(time.timeIntervalSince1970))?exclude=minutely,flags,hourly,daily,alerts"
                print(jsonURLString)
                guard let url = URL(string: jsonURLString) else {
                    return
                }
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, err) in
                    guard let data = data else {
                        return
                    }
                    do {
                        let weather = try JSONDecoder().decode(Weather.self, from: data)
                        print(weather)
                        print(weather.currently.icon)
                        DispatchQueue.main.async {
                            self.iconImageView.image = UIImage(named: weather.currently.icon)
                            self.degreesLabel.text = String(Int(weather.currently.temperature)) + " °"
                            self.summaryLabel.text = weather.currently.summary
                        }
                    } catch let jsonErr {
                        print("Error serializing json:", jsonErr)
                        
                    }
                    
                }).resume()
                
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
