//
//  AppRoute.swift
//
//  Created by Zach Howe on 7/24/15.
//  Copyright © 2015 Zach Howe. All rights reserved.
//

import Foundation

public enum AppRouteError: ErrorType {
    case PatternParseError(String)
    case RegularExpressionError(ErrorType)
}

public protocol AppRouteProtocol {
    func matchesOnURL(URL: NSURL) -> Bool
    func paramsForURL(URL: NSURL) -> AppRoutingParameters
}

public class AppRoute: AppRouteProtocol {
    public let routePattern: String
    private(set) public var regex = NSRegularExpression()
    private(set) public var paramKeys = [String]()
    
    public init(routePattern: String) throws {
        self.routePattern = routePattern
        (self.regex, self.paramKeys) = try regularExpressionFromURLPattern(routePattern)
    }
    
    public func matchesOnURL(URL: NSURL) -> Bool {
        let absoluteString = URL.absoluteString
        let range = NSRange(location: 0, length: absoluteString.characters.count)
        return regex.numberOfMatchesInString(absoluteString, options: NSMatchingOptions(rawValue: 0), range: range) == 1
    }
    
    public func paramsForURL(URL: NSURL) -> AppRoutingParameters {
        let absoluteString = URL.absoluteString
        var matchedValues = AppRoutingParameters()
        
        regex.enumerateMatchesInString(absoluteString,
            options: NSMatchingOptions(rawValue: 0),
            range: NSRange(location: 0, length: absoluteString.characters.count),
            usingBlock: { (match, flags, stop) -> Void in
                
                if let match = match {
                    if match.range.location != NSNotFound {
                        var i = 0
                        for ri in 1..<match.numberOfRanges {
                            let key = self.paramKeys[i++]
                            
                            let range = { (str: String, rng: NSRange) -> Range<String.Index> in
                                let start = str.startIndex.advancedBy(rng.location)
                                let end = start.advancedBy(rng.length)
                                return Range<String.Index>(start: start, end: end)
                                }(absoluteString, match.rangeAtIndex(ri))
                            
                            let strVal = absoluteString.substringWithRange(range)
                            
                            // TODO: let route pattern determine type
                            if let intVal = Int(strVal) {
                                matchedValues[key] = AppRoutingParameter.Number(intVal)
                            } else {
                                matchedValues[key] = AppRoutingParameter.Text(strVal)
                            }
                        }
                    }
                }
        })
        
        return matchedValues
    }
}

private let RouteDelimterStart = ":"
private let RouteDelimterEnd = ":"
private let RouteRegularExpressionCaptureGroupPattern = "([^/]*)"

private func regularExpressionFromURLPattern(pattern: String) throws -> (NSRegularExpression, [String]) {
    let patternScanner = NSScanner(string: pattern)
    patternScanner.charactersToBeSkipped = nil
    
    var regexPattern = ""
    var regexGroupKeyNames: [String] = []
    
    var scannedString: NSString?
    while (!patternScanner.atEnd) {
        if patternScanner.scanUpToString(RouteDelimterStart, intoString: &scannedString),
            let scannedString = scannedString as? String {
                regexPattern += scannedString
        }
        
        if patternScanner.scanString(RouteDelimterStart, intoString: nil) {
            if patternScanner.scanUpToString(RouteDelimterEnd, intoString: &scannedString),
                let scannedString = scannedString as? String {
                    regexGroupKeyNames.append(scannedString)
                    regexPattern += RouteRegularExpressionCaptureGroupPattern
                    patternScanner.scanString(RouteDelimterEnd, intoString: nil)
            } else {
                throw AppRouteError.PatternParseError("Did not find RouteDelimterEnd (\"\(RouteDelimterEnd)\") after RouteDelimterStart (\"\(RouteDelimterStart)\")")
            }
        }
    }
    regexPattern += "/?$" // ignore trailing slash
    
    do {
        let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpressionOptions(rawValue: 0))
        return (regex, regexGroupKeyNames)
    } catch let error {
        throw AppRouteError.RegularExpressionError(error)
    }
}
