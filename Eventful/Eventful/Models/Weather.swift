//
//  Weather.swift
//  Eventful
//
//  Created by Shawn Miller on 9/6/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation


struct Weather: Codable {
    let latitude, longitude: Double
    let timezone: String
    let offset: Int
    let currently : Currently
    
//    init(latitude: String,longitude: String,timezone: String,offset: Int,currently : Currently) {
//        self.latitude = latitude
//        self.longitude = longitude
//        self.timezone = timezone
//        self.offset = offset
//        self.currently = currently
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case currently = "currently",latitude = "latitude",longitude = "longitude",timezone = "timezone", offset = "offset"
//    }
//
    }



struct Currently: Codable {
    let time: Int
    let summary, icon: String
    let precipIntensity: Double
    let precipProbability: Double // must be Double not Int
    let temperature, apparentTemperature: Double
    let dewPoint, humidity, pressure, windSpeed: Double
    let windGust, windBearing, cloudCover, uvIndex, visibility: Double
    
//    init(time: Int,summary: String,icon: String,precipIntensity: Double,precipProbability: Int, precipType: String,temperature: Double,apparentTemperature: Double,dewPoint: Double, humidity: Double,pressure: Double,windSpeed: Double, windGust: Double,windBearing: Double,cloudCover: Double,uvIndex: Double,visibility: Double) {
//        self.time = time
//        self.summary = summary
//        self.icon = icon
//        self.precipIntensity = precipIntensity
//        self.precipProbability = precipProbability
//        self.precipType = precipType
//        self.temperature = temperature
//        self.apparentTemperature = apparentTemperature
//        self.dewPoint = dewPoint
//        self.humidity = humidity
//        self.pressure = pressure
//        self.windSpeed = windSpeed
//        self.windGust = windGust
//        self.windBearing = windBearing
//        self.cloudCover = cloudCover
//        self.uvIndex = uvIndex
//        self.visibility = visibility
//
//    }
//
//    enum CodingKeys : Any, CodingKey {
//        case time,summary,icon,precipIntensity,precipProbability,precipType,temperature,apparentTemperature,
//        dewPoint,humidity,pressure,windSpeed,windGust,windBearing,cloudCover,uvIndex,visibility
//    }

}

