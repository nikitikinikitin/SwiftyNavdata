//
//  NavdataJsonTypes.swift
//  PrivateTracker
//
//  Created by Александр Никитин on 03.06.2021.
//

import Foundation

//MARK: Fix
public struct Fix: Codable, NavObject {
    public init(latitude: Float, longitude: Float, name: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
    }
    
    public var latitude: Float
    public var longitude: Float
    public var name: String
    
    // Names start with capital leters, so this is required for JSON decoding
    private enum CodingKeys: String, CodingKey {
        case latitude = "Latitude"
        case longitude = "Longitude"
        case name = "Name"
    }
}

//MARK: Localizer
public struct LOC: Codable, NavObject {
    public init(name: String, airportICAO: String, identifier: String, associatedRunwayNumber: String, frequency: Int, elevation: Int, latitude: Float, longitude: Float, bearing: Float, receptionRange: Int, type: Int) {
        self.name = name
        self.airportICAO = airportICAO
        self.identifier = identifier
        self.associatedRunwayNumber = associatedRunwayNumber
        self.frequency = frequency
        self.elevation = elevation
        self.latitude = latitude
        self.longitude = longitude
        self.bearing = bearing
        self.receptionRange = receptionRange
        self.type = type
    }
    
    public var name: String
    public var airportICAO: String
    public var identifier: String
    public var associatedRunwayNumber: String
    public var frequency: Int
    public var elevation: Int
    public var latitude: Float
    public var longitude: Float
    public var bearing: Float
    public var receptionRange: Int
    public var type: Int
}

//MARK: NDB
public struct NDB: Codable, NavObject {
    public init(name: String, identifier: String, latitude: Float, longitude: Float, elevation: Int, frequency: Int, receptionRange: Int) {
        self.name = name
        self.identifier = identifier
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
        self.frequency = frequency
        self.receptionRange = receptionRange
    }
    
    public var name: String
    public var identifier: String
    public var latitude: Float
    public var longitude: Float
    public var elevation: Int
    public var frequency: Int
    public var receptionRange: Int
}

//MARK: VOR
public struct VOR: Codable, NavObject {
    
    public init(name: String, identifier: String, latitude: Float, longitude: Float, elevation: Int, frequency: Int, receptionRange: Int, slavedVariation: Float) {
        self.name = name
        self.identifier = identifier
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
        self.frequency = frequency
        self.receptionRange = receptionRange
        self.slavedVariation = slavedVariation
    }
    
    public var name: String
    public var identifier: String
    public var latitude: Float
    public var longitude: Float
    public var elevation: Int
    public var frequency: Int
    public var receptionRange: Int
    public var slavedVariation: Float
}

//MARK: Beacons
//MarkerBeacons.json in the repo
public struct Beacon: Codable, NavObject {
    public init(name: String, type: Int, airportICAO: String, associatedRunwayNumber: String, latitude: Float, longitude: Float, elevation: Float, bearing: Float) {
        self.name = name
        self.type = type
        self.airportICAO = airportICAO
        self.associatedRunwayNumber = associatedRunwayNumber
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
        self.bearing = bearing
    }
    
    public var name: String
    public var type: Int
    public var airportICAO: String
    public var associatedRunwayNumber: String
    public var latitude: Float
    public var longitude: Float
    public var elevation: Float
    public var bearing: Float
}

//MARK: Glideslope
public struct Glideslope: Codable, NavObject {
    
    public init(name: String, airportICAO: String, identifier: String, associatedRunwayNumber: String, frequency: Int, elevation: Float, latitude: Float, longitude: Float, bearing: Float, glideslope: Float, receptionRange: Int) {
        self.name = name
        self.airportICAO = airportICAO
        self.identifier = identifier
        self.associatedRunwayNumber = associatedRunwayNumber
        self.frequency = frequency
        self.elevation = elevation
        self.latitude = latitude
        self.longitude = longitude
        self.bearing = bearing
        self.glideslope = glideslope
        self.receptionRange = receptionRange
    }
    
    public var name: String
    public var airportICAO: String
    public var identifier: String
    public var associatedRunwayNumber: String
    public var frequency: Int
    public var elevation: Float
    public var latitude: Float
    public var longitude: Float
    public var bearing: Float
    public var glideslope: Float
    public var receptionRange: Int
}


//MARK: DME
/*
public struct DME: Codable, NavObject {
    public var name: String
    public var latitude: Float
    public var longitude: Float
    public var elevation: Int
    public var frequency: Int
    public var receptionRange: Int
    public var bias: Float
    public var identifier: String
    public var airportICAO: String
    public var associatedRunwayNumber: String
    public var type: Int
}
*/

//MARK: Airway
public struct Airway: Codable {
    public init(baseAltitude: Int, beginningLatitude: Float, segmentName: String, endLongitude: Float, beginningLongitude: Float, endLatitude: Float, topAltitude: Int, beginningIntersectionName: String, endIntersectionName: String, intersectionType: String) {
        self.baseAltitude = baseAltitude
        self.beginningLatitude = beginningLatitude
        self.segmentName = segmentName
        self.endLongitude = endLongitude
        self.beginningLongitude = beginningLongitude
        self.endLatitude = endLatitude
        self.topAltitude = topAltitude
        self.beginningIntersectionName = beginningIntersectionName
        self.endIntersectionName = endIntersectionName
        self.intersectionType = intersectionType
    }
    
    public var baseAltitude: Int
    public var beginningLatitude: Float
    public var segmentName: String
    public var endLongitude: Float
    public var beginningLongitude: Float
    public var endLatitude: Float
    public var topAltitude: Int
    public var beginningIntersectionName: String
    public var endIntersectionName: String
    public var intersectionType: String
}

//MARK: NavObject protocol
public protocol NavObject {
    var name: String { get set }
    var latitude: Float { get set }
    var longitude: Float { get set }
}
