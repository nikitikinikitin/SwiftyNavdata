//
//  NavdataJsonTypes.swift
//  PrivateTracker
//
//  Created by Александр Никитин on 03.06.2021.
//

import Foundation

//MARK: Fix
public struct Fix: Codable, NavObject {
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
