//
//  File.swift
//  
//
//  Created by Александр Никитин on 06.07.2021.
//

import Foundation

///An object that decodes an Airport from a **.dat** file
public class AirportParser {
    
    //MARK: Airport parser
    private static func decodeAirport(_ fileString: String, parseNodes: NodeParsingOption) -> Airport {
        var airport = Airport(rowCode: -1, elevation: -1000, icao: "", name: "", runways: [], pavement: [], linearFeatures: [], airportBoundary: [], viewPoint: nil, startupLocations: [], lightBeacon: nil, lightingObjects: [], atcFrequencies: [])
        let lines = fileString.components(separatedBy: "\n")
        
        // To not write the same logic 10 times in the switch
        func parseFrequency(_ line: [String], code: Int, lineCount: Int) {
            guard lineCount > 2 else {return}
            if let freq = Int(line[1]) {
                let name = line[2..<lineCount].joined(separator: " ")
                airport.atcFrequencies.append(Airport.AtcFacility(rowCode: code, frequency: freq, name: name))
            }
        }
        
        //MARK: Node Parsing
        
        var currentNodeObjectNodes: [Airport.Node] = []
        var currentNodeObject: Any?
        var currentNodeObjectType = 0
        
        func parseNode(_ line: [String], code: Int, lineCount: Int, lineNumber: Int) {
            guard lineCount > 2 else {return}
            guard let lat = Float(line[1]),
                  let lon = Float(line[2]) else {return}
            var node = Airport.Node(rowCode: 111, latitude: lat, longitude: lon, bezierLatitude: nil, bezierLongitude: nil, lineType: nil)
            switch code {
            case 111:
                // PLain node
                if lineCount > 3 {
                    node.lineType = Int(line[3])
                }
                currentNodeObjectNodes.append(node)
                return
            case 112:
                // Beizer node
                if lineCount > 4 {
                    node.bezierLatitude = Float(line[3])
                    node.bezierLongitude = Float(line[4])
                    if lineCount > 5 {
                        node.lineType = Int(line[5])
                    }
                }
                currentNodeObjectNodes.append(node)
                return
            case 113:
                // PLain node, close boundary
                if lineCount > 3 {
                    node.lineType = Int(line[3])
                }
                let nextLine = lines[lineNumber + 1]
                // It can terminate on 113, but it may not. Checking for that here
                if nextLine.count > 3 {
                    let nextLineRowCode = nextLine.components(separatedBy: " ")[0]
                    if ["111", "112", "113", "114", "115", "116"].contains(nextLineRowCode) {
                        // Means we're continuing with the current object
                        currentNodeObjectNodes.append(node)
                        return
                    }
                }
            case 114:
                // Beizer node, close boundary
                if lineCount > 4 {
                    node.bezierLatitude = Float(line[3])
                    node.bezierLongitude = Float(line[4])
                    if lineCount > 5 {
                        node.lineType = Int(line[5])
                    }
                    let nextLine = lines[lineNumber + 1]
                    // It can terminate on 114, but it may not. Checking for that here
                    if nextLine.count > 3 {
                        let nextLineRowCode = nextLine.components(separatedBy: " ")[0]
                        if ["111", "112", "113", "114", "115", "116"].contains(nextLineRowCode) {
                            // Means we're continuing with the current object
                            currentNodeObjectNodes.append(node)
                            return
                        }
                    }
                }
            case 115:
                break
            case 116:
                // Beizer node
                if lineCount > 4 {
                    node.bezierLatitude = Float(line[3])
                    node.bezierLongitude = Float(line[4])
                }
            default:
                return
            }
            
            // It gets here only if the node object ends, aka only if the current row code is 113-116
            
            switch currentNodeObjectType {
            case 110:
                // Pavement
                
                if currentNodeObject is Airport.Pavement {
                    var pavement = currentNodeObject as! Airport.Pavement
                    pavement.nodes = currentNodeObjectNodes
                    airport.pavement.append(pavement)
                }
            case 120:
                // Linear feature
                if currentNodeObject is Airport.LinearFeature {
                    var linearFeature = currentNodeObject as! Airport.LinearFeature
                    linearFeature.nodes = currentNodeObjectNodes
                    airport.linearFeatures.append(linearFeature)
                }
            case 130:
                // Airport boundary
                airport.airportBoundary = currentNodeObjectNodes
            default:
                break
            }
            currentNodeObjectNodes.removeAll()
        }
        
        // This is to not have hundreds of checks for whether the node should be parsed
        var nodeHandler: (([String], Int, Int, Int) -> Void)!
        
        
        
        for lineNumber in 0..<lines.count {
            let line = lines[lineNumber].components(separatedBy: " ").filter { $0 != ""}
            let lineCount = line.count
            guard lineCount > 0 else {continue}
            switch line[0] {
            
            //MARK: Airport Header
            case "1":
                guard lineCount > 5 else {continue}
                // Land airport header
                airport.rowCode = 1
                airport.icao = line[4]
                airport.name = line[5..<lineCount].joined(separator: " ")
                if let elev = Int(line[1]) {
                    airport.elevation = elev
                }
            
            case "1302":
                guard lineCount > 2 else {continue}
                switch line[1] {
                case "iata_code":
                    airport.iata = line[2]
                case "faa_code":
                    airport.faa = line[2]
                case "datum_lat":
                    airport.latitude = Float(line[2])
                case "datum_lon":
                    airport.longitude = Float(line[2])
                case "country":
                    let value = line[2..<line.count].joined(separator: " ")
                    airport.country = value
                case "city":
                    let value = line[2..<line.count].joined(separator: " ")
                    airport.city = value
                default:
                    continue
                }
                
            //MARK: Runways
            case "100":
                // Land runway
                guard lineCount > 22 else {continue}
                let runway = Airport.Runway(rowCode: 100,
                                            width: Float(line[1]) ?? -1,
                                            surfaceType: Int(line[2]) ?? -1,
                                            shoulderSurfaceType: Int(line[3]) ?? -1,
                                            runwayEnd1: Airport.Runway.RunwayEnd(
                                                runwayNumber: line[8],
                                                latitude: Float(line[9]) ?? -1000,
                                                longitude: Float(line[10]) ?? -1000,
                                                displacedThresholdLength: Float(line[11]) ?? -1,
                                                runwayMarkingType: Int(line[13]) ?? -1),
                                            runwayEnd2: Airport.Runway.RunwayEnd(
                                                runwayNumber: line[17],
                                                latitude: Float(line[18]) ?? -1000,
                                                longitude: Float(line[19]) ?? -1000,
                                                displacedThresholdLength: Float(line[20]) ?? -1,
                                                runwayMarkingType: Int(line[22]) ?? -1))
                airport.runways.append(runway)
                
            //MARK: Lighting objects
            case "21":
                // Lighting object like PAPI
                guard lineCount > 6 else {continue}
                if let lat = Float(line[1]),
                   let lon = Float(line[2]),
                   let typeCode = Int(line[3]),
                   let orientation = Float(line[4]),
                   let glideslope = Float(line[5]){
                    var lObj = Airport.LightingObject(latitude: lat, longitude: lon, type: typeCode, orientation: orientation, glideslopeAngle: glideslope, associatedRunway: line[6], description: nil)
                    if lineCount > 7 {
                        lObj.description = line[7]
                    }
                    airport.lightingObjects.append(lObj)
                }
                
            case "18":
                // Lighting beacon
                guard lineCount > 3 else {continue}
                if let lat = Float(line[1]),
                   let lon = Float(line[2]),
                   let typeCode = Int(line[3]){
                    airport.lightBeacon = Airport.LightBeacon(latitude: lat, longitude: lon, beaconType: typeCode)
                }
                
            //MARK: Startup Locations
            case "15":
                // Old row code for a startup location
                guard lineCount > 4 else {continue}
                if let lat = Float(line[1]),
                   let lon = Float(line[2]),
                   let heading = Float(line[3]){
                    let name = line[4..<lineCount].joined(separator: " ")
                    let stLoc = Airport.StartupLocation(latitude: lat, longitude: lon, heading: heading, name: name, locationType: nil, allowedAirplaneTypes: nil, icaoWidth: nil)
                    airport.startupLocations.append(stLoc)
                }
            case "1300":
                // New code for startup locations
                guard lineCount > 4 else {continue}
                if let lat = Float(line[1]),
                   let lon = Float(line[2]),
                   let heading = Float(line[3]){
                    let name = line[6..<lineCount].joined(separator: " ")
                    var stLoc = Airport.StartupLocation(latitude: lat, longitude: lon, heading: heading, name: name, locationType: line[4], allowedAirplaneTypes: line[5], icaoWidth: nil)
                    let nextLine = lines[lineNumber+1].components(separatedBy: " ").filter { $0 != ""}
                    guard !nextLine.isEmpty else {
                        airport.startupLocations.append(stLoc)
                        continue
                    }
                    if nextLine[0] == "1301" && nextLine.count > 2 {
                        stLoc.icaoWidth = nextLine[1]
                    }
                    airport.startupLocations.append(stLoc)
                }
            case "1301":
                //Metadata for 1300 gates, already handled in case "1300"
                continue
                
            //MARK: ATC Frequencies
            //Unicom
            case "51":
                parseFrequency(line, code: 51, lineCount: lineCount)
            case "1051":
                parseFrequency(line, code: 1051, lineCount: lineCount)
                
            //Ground
            case "53":
                parseFrequency(line, code: 53, lineCount: lineCount)
            case "1053":
                parseFrequency(line, code: 1053, lineCount: lineCount)
                
            //Tower
            case "54":
                parseFrequency(line, code: 54, lineCount: lineCount)
            case "1054":
                parseFrequency(line, code: 1054, lineCount: lineCount)
                
            //Approach
            case "55":
                parseFrequency(line, code: 55, lineCount: lineCount)
            case "1055":
                parseFrequency(line, code: 1055, lineCount: lineCount)
                
            //Tower
            case "56":
                parseFrequency(line, code: 56, lineCount: lineCount)
            case "1056":
                parseFrequency(line, code: 1056, lineCount: lineCount)
                
            //MARK: Nodes
            
            case "110":
                // Pavement header
                currentNodeObjectType = 110
                let name = line[4..<lineCount].joined(separator: " ")
                if let sfcType = Int(line[1]) {
                    currentNodeObject = Airport.Pavement(surfaceType: sfcType, description: name, nodes: [])
                }
                
                if parseNodes == .parseAll {
                    nodeHandler = parseNode
                } else {
                    nodeHandler = { (_, _, _, _) in
                        return
                    }
                }
            case "120":
                // Line header
                currentNodeObjectType = 120
                let name = line[1..<lineCount].joined(separator: " ")
                currentNodeObject = Airport.LinearFeature(description: name, nodes: [])
                
                if parseNodes == .parseAll {
                    nodeHandler = parseNode
                } else {
                    nodeHandler = { (_, _, _, _) in
                        return
                    }
                }
            case "130":
                // Airport boundary header
                if parseNodes != .none {
                    nodeHandler = parseNode
                } else {
                    nodeHandler = { (_, _, _, _) in
                        return
                    }
                }
                
                currentNodeObjectType = 130
                currentNodeObject = nil
                
            case "111":
                // Plain node
                nodeHandler(line, 111, lineCount, lineNumber)
            case "112":
                // Beizer node
                nodeHandler(line, 112, lineCount, lineNumber)
            case "113":
                // Close loop Plain node
                nodeHandler(line, 113, lineCount, lineNumber)
            case "114":
                // Close loop Beizer node
                nodeHandler(line, 114, lineCount, lineNumber)
            case "115":
                // End line Plain node
                nodeHandler(line, 115, lineCount, lineNumber)
            case "116":
                // End line Beizer node
                nodeHandler(line, 116, lineCount, lineNumber)
                
            default:
                continue
            }
        }
        return airport
    }
    
    public enum NodeParsingOption {
        /// Parse only the airport boundary
        case parseBoundary
        /// Parse airport boundary, all pavements and all lines
        case parseAll
        /// Don't parse any nodes
        case none
    }
    
    /**
     Parses an apt.dat file into a detailed Airport object with detailed node information.
     - Attention: This method is perfectly fine to use, but it is suggested to move to `parseAirport(_ url: URL, parseNodes: NodeParsingOption)` for more control over parsing.
     - Note: If you don't need nodes, use parseAirportWithoutNodes for a speed increase of up to 30%
     - parameter url: Source file URL
     */
    public static func parseAirportWithNodes(_ url: URL) throws -> Airport {
        let data = try String(contentsOf: url)
        let airport = decodeAirport(data, parseNodes: .parseAll)
        return airport
    }
    
    /**
     Parses an apt.dat file into a detailed Airport object without the node information, thus ```pavement```, ```linearFeatures```, ```airportBoundary``` will be empty arrays.
     - Attention: This method is perfectly fine to use, but it is suggested to move to `parseAirport(_ url: URL, parseNodes: NodeParsingOption)` for more control over parsing.
     - Note: If you need nodes, use parseAirportWithNodes, note that the execution time might be up by more than 30%
     - parameter url: Source file URL
     */
    public static func parseAirportWithoutNodes(_ url: URL) throws -> Airport {
        let data = try String(contentsOf: url)
        let airport = decodeAirport(data, parseNodes: .none)
        return airport
    }
    
    /**
     Parses an apt.dat file into an `Airport` object.
     - Parameters:
       - url: Source file URL
       - parseNodes: a case of `NodeParsingOption` enum. See descriptions of it's cases for more info.
     */
    public static func parseAirport(_ url: URL, parseNodes: NodeParsingOption) throws -> Airport {
        let data = try String(contentsOf: url)
        let airport = decodeAirport(data, parseNodes: parseNodes)
        return airport
    }
    
    /**
     Parses all apt.dat files in a folder and all of it's subfolders and returns an array of Airport objects
     - Warning: Keep in mind, if you're gonna run it with the whole repository, it would take a few minutes and will occupy hundreds of megabytes if encoded as json
     - Parameters:
       - url: Source file URL
       - parseNodes: a case of `NodeParsingOption` enum. See descriptions of it's cases for more info.
     */
    public static func parseAllAirports(_ url: URL, parseNodes: NodeParsingOption) -> [Airport] {
        var airports = [Airport]()
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: []) else { return [] }
        let urls = enumerator.allObjects
        
        for case let url as URL in urls {
            guard url.pathExtension == "dat" else {continue}
            // autoreleasepool prevents a memory leak from String(contentsOf:)
            autoreleasepool {
            if let fileString = try? String(contentsOf: url) {
                let airport = decodeAirport(fileString, parseNodes: parseNodes)
                airports.append(airport)
            }
            }
        }
        return airports
    }
    
    /**
     Parses all apt.dat files in a folder and all of it's subfolders and returns an array of Airport objects
     - Attention: This method is perfectly fine to use, but it is suggested to move to the new version where **parseNodes** is of type `NodeParsingOption` instead of `Bool` for more control over parsing.
     - Warning: Keep in mind, if you're gonna run it with the whole repository, it would take a few minutes and will occupy hundreds of megabytes if encoded as json
     */
    public static func parseAllAirports(_ url: URL, parseNodes: Bool) -> [Airport] {
        let option: NodeParsingOption = parseNodes ? .parseAll : .none
        return parseAllAirports(url, parseNodes: option)
    }
    
    /**
     Parses all apt.dat files in a folder and all of it's subfolders and returns an array of Airport objects. This is a multithreaded method, thus, it needs to be used carefully. If used properly it can be 2-3 times faster than parseAllAirports.
     - Warning: Keep in mind, if you're gonna run it with the whole repository, it would take some time and will occupy hundreds of megabytes if encoded as json
     - Parameters:
       - url: URL of the source
       - parseNodes: a case of `NodeParsingOption` enum. See descriptions of it's cases for more info.
       - threads: Amount of threads (DispatchQueues) the function will use. **Don't set it to more than the amount of cores** the device has, it is best when the value is a bit less or equal to the core count. If set to nil, it will estimate the best amount of cores based on device's specs.
     */
    public static func parseAllAirportsMultithreaded(_ url: URL, parseNodes: NodeParsingOption, threads amountOfThreads: Int? = nil) -> [Airport] {
        var airports = [Airport]()
        var threadCount: Int!
        if amountOfThreads != nil {
            threadCount = amountOfThreads!
        } else {
            threadCount = ProcessInfo.processInfo.processorCount / 2
            if threadCount == 0 {
                threadCount = 2
            }
        }
        
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: []) else { return [] }
        let urls = enumerator.allObjects
        
        let urlsCount = urls.count
        let objectsPerQueue = urlsCount/threadCount
        if threadCount >= urlsCount {
            threadCount = urlsCount
        }
        
        // Semaphore which is used to wait for all queues to finish
        let semaphore = DispatchSemaphore(value: 0)
        
        // Queue for additions to the airports array
        let airportsArrayAdditionQueue = DispatchQueue.global(qos: .userInitiated)
        var queueCompletionCount = 0
        for i in 1...threadCount {
            DispatchQueue.global(qos: .userInitiated).async {
                
                let thisQueueUrls = urls[objectsPerQueue * (i - 1)..<objectsPerQueue * i]
                var thisQueueAirports = [Airport]()
                
                for case let url as URL in thisQueueUrls {
                    guard url.pathExtension == "dat" else {continue}
                    autoreleasepool {
                    if let fileString = try? String(contentsOf: url) {
                        let airport = decodeAirport(fileString, parseNodes: parseNodes)
                        thisQueueAirports.append(airport)
                    }
                    }
                }
                
                queueCompletionCount += 1
                airportsArrayAdditionQueue.sync {
                    // This is for no overlaps between additions to airports array
                    airports += thisQueueAirports
                }
                if queueCompletionCount >= threadCount {
                    // All queues finished
                    semaphore.signal()
                }
            }
        }
        // This makes the code wait for all threads to finish
        semaphore.wait()
        return airports
    }
    
    /**
     Parses all apt.dat files in a folder and all of it's subfolders and returns an array of Airport objects. This is a multithreaded method, thus, it needs to be used carefully. If used properly it can be 2-3 times faster than parseAllAirports.
     - Attention: This method is perfectly fine to use, but it is suggested to move to the new version where **parseNodes** is of type `NodeParsingOption` instead of `Bool` for more control over parsing.
     - Warning: Keep in mind, if you're gonna run it with the whole repository, it would take some time and will occupy hundreds of megabytes if encoded as json
     - Parameters:
       - url: URL of the source
       - parseNodes: whether the nodes would be parsed or not
       - threads: Amount of threads (DispatchQueues) the function will use. **Don't set it to more than the amount of cores** the device has, it is best when the value is a bit less or equal to the core count. If set to nil, it will estimate the best amount of cores based on device's specs.
     */
    public static func parseAllAirportsMultithreaded(_ url: URL, parseNodes: Bool, threads amountOfThreads: Int? = nil) -> [Airport] {
        let option: NodeParsingOption = parseNodes ? .parseAll : .none
        return parseAllAirportsMultithreaded(url, parseNodes: option, threads: amountOfThreads)
    }
}
