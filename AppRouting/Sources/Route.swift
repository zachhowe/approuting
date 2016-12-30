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

public enum RouteError: Error {
  case patternParseError(String)
  case regularExpressionError(Error)
}

public protocol RouteProtocol {
  func matches(url: URL) -> Bool
  func parameters(url: URL) -> RouteParameters
}

public final class Route: RouteProtocol {
  public let pattern: String
  var regex = NSRegularExpression()
  var paramKeys = [String]()
  
  public init(pattern: String) throws {
    self.pattern = pattern
    (regex, paramKeys) = try regularExpressionFromURLPattern(pattern)
  }
  
  public func matches(url: URL) -> Bool {
    let range = NSRange(location: 0, length: url.path.characters.count)
    return regex.numberOfMatches(in: url.path,
                                 options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                 range: range) == 1
  }
  
  public func parameters(url: URL) -> RouteParameters {
    var matchedValues = RouteParameters()
    
    let path = url.path
    
    regex.enumerateMatches(in: path,
      options: NSRegularExpression.MatchingOptions(rawValue: 0),
      range: NSRange(location: 0, length: path.characters.count),
      using: { (match, flags, stop) -> Void in
        
        if let match = match {
          if match.numberOfRanges >= 2 {
            var paramKeyIndex = 0
            for rangeIndex in 1 ..< match.numberOfRanges {
              let key = self.paramKeys[paramKeyIndex]
              paramKeyIndex += 1
              
              let rng = match.rangeAt(rangeIndex)
              
              let lower = path.index(path.startIndex, offsetBy: rng.location)
              let upper = path.index(lower, offsetBy: rng.length)
              
              matchedValues.append(RouteParameter(name: key, value: path[lower ..< upper]))
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

private func regularExpressionFromURLPattern(_ pattern: String) throws -> (NSRegularExpression, [String]) {
  let patternScanner = Scanner(string: pattern)
  patternScanner.charactersToBeSkipped = nil
  
  var regexPattern = ""
  var regexGroupKeyNames: [String] = []
  
  var scannedString: NSString?
  while (!patternScanner.isAtEnd) {
    if patternScanner.scanUpTo(RouteDelimiterStart, into: &scannedString),
      let scannedString = scannedString as? String {
        regexPattern += scannedString
    }
    
    if patternScanner.scanString(RouteDelimiterStart, into: nil) {
      if patternScanner.scanUpTo(RouteDelimiterEnd, into: &scannedString),
        let scannedString = scannedString as? String {
          regexGroupKeyNames.append(scannedString)
          regexPattern += RouteRegularExpressionCaptureGroupPattern
          patternScanner.scanString(RouteDelimiterEnd, into: nil)
      } else {
        throw RouteError.patternParseError("Did not find RouteDelimiterEnd (\"\(RouteDelimiterEnd)\") after RouteDelimiterStart (\"\(RouteDelimiterStart)\")")
      }
    }
  }
  regexPattern += "/?$" // ignore trailing slash
  
  let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options(rawValue: 0))
  return (regex, regexGroupKeyNames)
}
