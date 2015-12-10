//
//  Route.swift
//
//  Created by Zach Howe on 7/24/15.
//  Copyright © 2015 Zach Howe. All rights reserved.
//

import Foundation

public enum RouteError: ErrorType {
  case PatternParseError(String)
  case RegularExpressionError(ErrorType)
}

public protocol RouteProtocol {
  func matchesOnURL(URL: NSURL) -> Bool
  func paramsForURL(URL: NSURL) -> RouteParameters
}

private extension NSURL {
  func pathAndQuery() -> String {
    if let query = self.query {
      return (self.path ?? "") + "?" + query
    }
    return self.path ?? ""
  }
}

public class Route: RouteProtocol {
  public let pattern: String
  private(set) public var regex = NSRegularExpression()
  private(set) public var paramKeys = [String]()
  
  public init(pattern: String) throws {
    self.pattern = pattern
    (self.regex, self.paramKeys) = try regularExpressionFromURLPattern(pattern)
  }
  
  public func matchesOnURL(URL: NSURL) -> Bool {
    let absoluteString = URL.pathAndQuery()
    let range = NSRange(location: 0, length: absoluteString.characters.count)
    return regex.numberOfMatchesInString(absoluteString, options: NSMatchingOptions(rawValue: 0), range: range) == 1
  }
  
  public func paramsForURL(URL: NSURL) -> RouteParameters {
    let absoluteString = URL.pathAndQuery()
    var matchedValues = RouteParameters()
    
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
                matchedValues[key] = RouteParameter.Number(intVal)
              } else {
                matchedValues[key] = RouteParameter.Text(strVal)
              }
            }
          }
        }
    })
    
    return matchedValues
  }
}

private let RouteDelimiterStart = ":"
private let RouteDelimiterEnd = ":"
private let RouteRegularExpressionCaptureGroupPattern = "([^/]*)"

private func regularExpressionFromURLPattern(pattern: String) throws -> (NSRegularExpression, [String]) {
  let patternScanner = NSScanner(string: pattern)
  patternScanner.charactersToBeSkipped = nil
  
  var regexPattern = ""
  var regexGroupKeyNames: [String] = []
  
  var scannedString: NSString?
  while (!patternScanner.atEnd) {
    if patternScanner.scanUpToString(RouteDelimiterStart, intoString: &scannedString),
      let scannedString = scannedString as? String {
        regexPattern += scannedString
    }
    
    if patternScanner.scanString(RouteDelimiterStart, intoString: nil) {
      if patternScanner.scanUpToString(RouteDelimiterEnd, intoString: &scannedString),
        let scannedString = scannedString as? String {
          regexGroupKeyNames.append(scannedString)
          regexPattern += RouteRegularExpressionCaptureGroupPattern
          patternScanner.scanString(RouteDelimiterEnd, intoString: nil)
      } else {
        throw RouteError.PatternParseError("Did not find RouteDelimiterEnd (\"\(RouteDelimiterEnd)\") after RouteDelimiterStart (\"\(RouteDelimiterStart)\")")
      }
    }
  }
  regexPattern += "/?$" // ignore trailing slash
  
  do {
    let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpressionOptions(rawValue: 0))
    return (regex, regexGroupKeyNames)
  } catch let error {
    throw RouteError.RegularExpressionError(error)
  }
}
