//
//  Route.swift
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015-2016 Zachary Howe
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public enum RouteError: ErrorType {
  case PatternParseError(String)
  case RegularExpressionError(ErrorType)
}

public protocol RouteProtocol {
  func matchesOnURL(URL: NSURL) -> Bool
  func parametersForURL(URL: NSURL) -> RouteParameters
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
  
  public func parametersForURL(URL: NSURL) -> RouteParameters {
    guard let path = URL.path else { return [] }
    var matchedValues = RouteParameters()
    
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
