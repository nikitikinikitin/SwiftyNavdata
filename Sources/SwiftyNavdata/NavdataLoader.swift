//
//  NavdataLoader.swift
//  PrivateTracker
//
//  Created by Александр Никитин on 03.06.2021.
//

import Foundation


///An object that decodes navdata from IFAET repository file formats (**.json** and **.dat**)
public class NavdataLoader {
    
    //MARK: JSON decoding
    
    /**
     Core method for JSON decoding. Write wrappers for this if you need error handling but have a source URL.
     - Parameter url: URL of the source.
     - Returns: A Codable type.
     */
    private static func decodeJson<T: Codable>(_ url: URL) throws -> T {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch {
            print("decodeJson: error decoding \(T.self) from \(url) - \(error)")
            throw error
        }
    }
    
    /**
     Decodes an Fixes.json file into an array of Fix objects.
     - Returns: An array of Fix objects or an empty array if something went wrong.
     - Parameter url: URL of the source.
     */
    public static func decodeFixJson(_ url: URL) throws -> [Fix] {
        let result: [Fix] = try decodeJson(url)
        return result
    }
    
    /**
     Decodes a VOR.json file into an array of VOR objects.
     - Returns: An array of VOR objects or an empty array if something went wrong.
     - Parameter url: URL of the source.
     */
    public static func decodeVorJson(_ url: URL) throws -> [VOR] {
        let result: [VOR] = try decodeJson(url)
        return result
    }
    
    /**
     Decodes an NDB.json file into an array of NDB objects.
     - Returns: An array of NDB objects or an empty array if something went wrong.
     - Parameter url: URL of the source.
     */
    public static func decodeNdbJson(_ url: URL) throws -> [NDB] {
        let result: [NDB] = try decodeJson(url)
        return result
    }
    
    /**
     Decodes a LOC.json file into an array of LOC objects.
     - Returns: An array of LOC objects or an empty array if something went wrong.
     - Parameter url: URL of the source.
     */
    public static func decodeLocJson(_ url: URL) throws -> [LOC] {
        let result: [LOC] = try decodeJson(url)
        return result
    }
    
    /**
     Decodes a MarkerBeacons.json file into an array of Beacon objects.
     - Returns: An array of Beacon objects or an empty array if something went wrong.
     - Parameter url: URL of the source.
     */
    public static func decodeMarkerBeaconsJson(_ url: URL) throws -> [Beacon] {
        let result: [Beacon] = try decodeJson(url)
        return result
    }
    
    /**
     Decodes an Fixes.json file into an array of Fix objects.
     - Returns: An array of Glideslope objects or an empty array if something went wrong.
     - Parameter url: URL of the source.
     */
    public static func decodeGlideslopesJson(_ url: URL) throws -> [Glideslope] {
        let result: [Glideslope] = try decodeJson(url)
        return result
    }
    
    /**
     Decodes an Airways.json file into an array of Airway objects.
     - Returns: An array of Airway objects or an empty array if something went wrong.
     - Parameter url: URL of the source.
     */
    public static func decodeAirwaysJson(_ url: URL) throws -> [Airway] {
        let result: [Airway] = try decodeJson(url)
        return result
    }
    
    //MARK:fix.dat
    
    /// Core method for fix.dat decoding
    private static func decodeFixDat(_ string: String) -> [Fix] {
        let lines = string.components(separatedBy: "\n")
        var fixes = [Fix]()
        for line in lines {
            let splitLine = line.components(separatedBy: " ")
            guard splitLine.count == 3 else {continue}
            if let latitude = Float(splitLine[0]),
               let longitude = Float(splitLine[1]) {
                fixes.append(Fix(latitude: latitude, longitude: longitude, name: splitLine[2]))
            }
        }
        return fixes
    }
    
    /**
     Parses a fix.dat file into an array of Fix objects.
     - Returns: An array of Fix objects or an empty array if something went wrong.
     - Parameter url: URL of the source.
     */
    public static func decodeFixDat(_ url: URL) throws -> [Fix] {
        let data = try String(contentsOf: url)
        let fixes = decodeFixDat(data)
        return fixes
    }
    
    //MARK:navigation.dat
    /**
     Core method for navigation.dat decoding.
     - ToDo: DME support is needed, but they have different formats with the same row codes and it's not used by IF anyways
     */
    private static func decodeNavdataDat(_ string: String) -> ( ndb: [NDB], vor: [VOR], loc: [LOC], glideslope: [Glideslope], beacon: [Beacon]/*, dme: [DME]*/ ) {
        var ndb = [NDB]()
        var vor = [VOR]()
        var loc = [LOC]()
        var gs = [Glideslope]()
        var bcn = [Beacon]()
        //var dme = [DME]()
        
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            let splitLine = line.components(separatedBy: " ").filter { $0 != "" }
            guard !splitLine.isEmpty else { continue }
            let rowCode = splitLine[0]
            if rowCode == "2" {
                //NDB
                guard splitLine.count >= 9 else { continue }
                if let lat = Float(splitLine[1]),
                   let lon = Float(splitLine[2]),
                   let elev = Int(splitLine[3]),
                   let freq = Int(splitLine[4]),
                   let range = Int(splitLine[5]) {
                    let name = splitLine[8..<splitLine.count].joined(separator: " ")
                    ndb.append(NDB(name: name, identifier: splitLine[7], latitude: lat, longitude: lon, elevation: elev, frequency: freq, receptionRange: range))
                }
            } else if rowCode == "3" {
                //VOR
                guard splitLine.count >= 9 else { continue }
                if let lat = Float(splitLine[1]),
                   let lon = Float(splitLine[2]),
                   let elev = Int(splitLine[3]),
                   let freq = Int(splitLine[4]),
                   let range = Int(splitLine[5]),
                   let slVar = Float(splitLine[6]) {
                    let name = splitLine[8..<splitLine.count].joined(separator: " ")
                    vor.append(VOR(name: name, identifier: splitLine[7], latitude: lat, longitude: lon, elevation: elev, frequency: freq, receptionRange: range, slavedVariation: slVar))
                }
            } else if rowCode == "4" || rowCode == "5" {
                //Loc
                guard splitLine.count >= 11 else { continue }
                if let type = Int(splitLine[0]),
                   let lat = Float(splitLine[1]),
                   let lon = Float(splitLine[2]),
                   let elev = Int(splitLine[3]),
                   let freq = Int(splitLine[4]),
                   let range = Int(splitLine[5]),
                   let bearing = Float(splitLine[6]) {
                    loc.append(LOC(name: splitLine[10], airportICAO: splitLine[8], identifier: splitLine[7], associatedRunwayNumber: splitLine[9], frequency: freq, elevation: elev, latitude: lat, longitude: lon, bearing: bearing, receptionRange: range, type: type))
                }
            } else if rowCode == "6" {
                //Glideslope
                guard splitLine.count >= 11 else { continue }
                if let lat = Float(splitLine[1]),
                   let lon = Float(splitLine[2]),
                   let elev = Float(splitLine[3]),
                   let freq = Int(splitLine[4]),
                   let range = Int(splitLine[5]),
                   let bearangle = Double(splitLine[6]) {
                    let angle = bearangle.truncatingRemainder(dividingBy: 1000) / 100
                    let bearing = bearangle - angle * 100
                    gs.append(Glideslope(name: splitLine[10], airportICAO: splitLine[8], identifier: splitLine[7], associatedRunwayNumber: splitLine[9], frequency: freq, elevation: elev, latitude: lat, longitude: lon, bearing: Float(bearing), glideslope: Float(angle), receptionRange: range))
                }
            } else if rowCode == "7" || rowCode == "8" || rowCode == "9" {
                //Beacon
                guard splitLine.count >= 9 else { continue }
                if let type = Int(splitLine[0]),
                   let lat = Float(splitLine[1]),
                   let lon = Float(splitLine[2]),
                   let elev = Float(splitLine[3]),
                   let bearing = Float(splitLine[6]){
                    bcn.append(Beacon(name: splitLine[10], type: type, airportICAO: splitLine[8], associatedRunwayNumber: splitLine[9], latitude: lat, longitude: lon, elevation: elev, bearing: bearing))
                }
            }
            /*
            else if rowCode == "12" || rowCode == "13" {
                //DME (WIP)
                continue
                guard splitLine.count >= 11 else { continue }
                if let type = Int(splitLine[0]),
                   let lat = Float(splitLine[1]),
                   let lon = Float(splitLine[2]),
                   let elev = Int(splitLine[3]),
                   let freq = Int(splitLine[4]),
                   let range = Int(splitLine[5]),
                   let bias = Float(splitLine[6]){
                    dme.append(DME(name: splitLine[10], latitude: lat, longitude: lon, elevation: elev, frequency: freq, receptionRange: range, bias: bias, identifier: splitLine[7], airportICAO: splitLine[8], associatedRunwayNumber: splitLine[9], type: type))
                }
            }
 */
        }
        return ( ndb, vor, loc, gs, bcn/*, dme*/ )
    }
    
    /**
     Parses a navigation.dat file into arrays of NDB, VOR, LOC, Glideslope, Beacon and DME objects
     - Parameter url: URL of the source.
     - Returns: A tuple of following structure: ( [NDB], [VOR], [LOC], [Glideslope], [Beacon]).
     */
    public static func decodeNavdataDat(_ url: URL) throws -> ( ndb: [NDB], vor: [VOR], loc: [LOC], glideslope: [Glideslope], beacon: [Beacon]/*, dme: [DME] */) {
        
        let data = try String(contentsOf: url)
        let (ndb, vor, loc, gs, bcn/*, dme*/) = self.decodeNavdataDat(data)
        return (ndb, vor, loc, gs, bcn/*, dme*/)
    }
    
    //MARK:airways.dat

    ///Core method for airways.dat decoding.
    private static func decodeAirwaysDat(_ string: String) -> [Airway] {
        var airways = [Airway]()
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            let splitLine = line.components(separatedBy: " ")
            guard splitLine.count >= 10 else { continue }
            if let beginningLatitude = Float(splitLine[1]),
               let beginningLongitude = Float(splitLine[2]),
               let endLatitude = Float(splitLine[4]),
               let endLongitude = Float(splitLine[5]),
               let baseAltitude = Int(splitLine[7]),
               let topAltitude = Int(splitLine[8]){
                var intersectionType: String!
                if splitLine[6] == "2" {
                    intersectionType = "high"
                } else {
                    intersectionType = "low"
                }
                airways.append(Airway(baseAltitude: baseAltitude*100, beginningLatitude: beginningLatitude, segmentName: splitLine[9], endLongitude: endLongitude, beginningLongitude: beginningLongitude, endLatitude: endLatitude, topAltitude: topAltitude*100, beginningIntersectionName: splitLine[0], endIntersectionName: splitLine[3], intersectionType: intersectionType))
            }
        }
        return airways
    }
    
    /**
     Parses an airways.dat file into an array of Airway objects.
     - Returns: An array of Airway objects
     - Parameter url: URL of the source.
     */
    public static func decodeAirwaysDat(_ url: URL) throws -> [Airway] {
        let data = try String(contentsOf: url)
        let result = decodeAirwaysDat(data)
        return result
    }
}
