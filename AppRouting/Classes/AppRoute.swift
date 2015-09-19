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

public protocol AppRoute {
    func matchesOnURL(URL: NSURL) -> Bool
    func paramsForURL(URL: NSURL) -> AppRoutingParameters
}

public class AppRouterRoute: AppRoute {
    public let routePattern: String
    let regex: NSRegularExpression?
    let paramKeys: [String]?
    let error: ErrorType?
    
    public init(routePattern: String) {
        do {
            let result = try regularExpressionFromURLPattern(routePattern)
            self.routePattern = routePattern
            self.regex = result.0
            self.paramKeys = result.1
            self.error = nil
        } catch let err {
            self.routePattern = routePattern
            self.error = err
            self.regex = nil
            self.paramKeys = nil
        }
    }
    
    public func matchesOnURL(URL: NSURL) -> Bool {
        let absoluteString = URL.absoluteString
        let range = NSRange(location: 0, length: absoluteString.characters.count)
        return regex?.numberOfMatchesInString(absoluteString, options: NSMatchingOptions(rawValue: 0), range: range) == 1
    }
    
    public func paramsForURL(URL: NSURL) -> AppRoutingParameters {
        let absoluteString = URL.absoluteString
        var matchedValues = AppRoutingParameters()
        
        regex?.enumerateMatchesInString(absoluteString,
            options: NSMatchingOptions(rawValue: 0),
            range: NSRange(location: 0, length: absoluteString.characters.count),
            usingBlock: { (match, flags, stop) -> Void in
                
                if let match = match {
                    if match.range.location != NSNotFound {
                        var i = 0
                        for ri in 1..<match.numberOfRanges {
                            let range = match.rangeAtIndex(ri)
                            if let key = self.paramKeys?[i++] {
                                let range: Range<String.Index> = { (str: String, rng: NSRange) in
                                    let start = str.startIndex.advancedBy(rng.location)
                                    let end = start.advancedBy(rng.length)
                                    return Range<String.Index>(start: start, end: end)
                                }(absoluteString, range)
                                
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
    regexPattern += "$"
    
    do {
        let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpressionOptions(rawValue: 0))
        return (regex, regexGroupKeyNames)
    } catch let error {
        throw AppRouteError.RegularExpressionError(error)
    }
}
