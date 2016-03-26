//
//  Route.swift
//
//  Created by Zach Howe on 7/24/15.
//  Copyright © 2015 Zach Howe. All rights reserved.
//

import Foundation

public struct RouteParameter {
  let name: String
  let value: String
}
extension RouteParameter: Equatable {}
public func ==(lhs: RouteParameter, rhs: RouteParameter) -> Bool {
  return lhs.name == rhs.name && lhs.value == rhs.value
}

public enum RouteError: ErrorType {
  case PatternParseError(String)
  case RegularExpressionError(ErrorType)
}

public protocol RouteProtocol {
  func matchesOnURL(URL: NSURL) -> Bool
  func paramsForURL(URL: NSURL) -> [RouteParameter]
}

public final class Route: RouteProtocol {
  public let pattern: String
  private(set) public var regex = NSRegularExpression()
  private(set) public var paramKeys = [String]()
  
  public init(pattern: String) throws {
    self.pattern = pattern
    (self.regex, self.paramKeys) = try regularExpressionFromURLPattern(pattern)
  }
  
  public func matchesOnURL(URL: NSURL) -> Bool {
    guard let path = URL.path else { return false }
    let range = NSRange(location: 0, length: path.characters.count)
    return regex.numberOfMatchesInString(path, options: NSMatchingOptions(rawValue: 0), range: range) == 1
  }
  
  public func paramsForURL(URL: NSURL) -> [RouteParameter] {
    guard let path = URL.path else { return [] }
    var matchedValues = [RouteParameter]()
    
    regex.enumerateMatchesInString(path,
      options: NSMatchingOptions(rawValue: 0),
      range: NSRange(location: 0, length: path.characters.count),
      usingBlock: { (match, flags, stop) -> Void in
        
        if let match = match {
          if match.range.location != NSNotFound {
            var i = 0
            for ri in 1..<match.numberOfRanges {
              let key = self.paramKeys[i]
              i += 1
              
              let range = { (str: String, rng: NSRange) -> Range<String.Index> in
                let start = str.startIndex.advancedBy(rng.location)
                let end = start.advancedBy(rng.length)
                return start..<end
              }(path, match.rangeAtIndex(ri))
              
              let strVal = path.substringWithRange(range)
              matchedValues.append(RouteParameter(name: key, value: strVal))
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
  
  let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpressionOptions(rawValue: 0))
  return (regex, regexGroupKeyNames)
}
