/**
* Copyright IBM Corporation 2015
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
**/

#if os(OSX) || os(iOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Foundation

// MARK: StringUtils

public class StringUtils {

    ///
    /// Converts a Swift string to a UTF encoded NSData
    ///
    /// - Parameter str: String
    ///
    /// - Returns: NSData?
    ///
    public static func toUtf8String(_ str: String) -> NSData? {
        let nsstr:NSString = str.bridge()
        return nsstr.data(using: NSUTF8StringEncoding)
    }


    ///
    /// Converts a Swift string to a UTF encoded null terminated NSData
    ///
    /// - Parameter str: String
    ///
    /// - Returns: NSData?
    ///
    public static func toNullTerminatedUtf8String(_ str: String) -> NSData? {
        let nsstr:NSString = str.bridge()
        let cString = nsstr.cString(using: NSUTF8StringEncoding)
        return NSData(bytes: cString, length: Int(strlen(cString!))+1)
    }


    ///
    /// Converts a UTF 8 encoded string to a Swift String
    ///
    /// - Parameter str: String
    ///
    /// - Returns: String?
    ///
    public static func fromUtf8String(_ data: NSData) -> String? {
        let str = NSString(data: data, encoding: NSUTF8StringEncoding)
        return str!.bridge()
    }
}


// MARK: String extensions
//
// Because that auto bridged Strings to NSStrings do not exist yet for Linux, a bridge method
// must be called on the String. This bridge method does not exist on Mac OS X. Therefore, these
// extensions are added to the String structure so that bridge can be called regardless of 
// operating systems.
//
#if os(OSX) || os(iOS)

public extension String {
    func bridge() -> NSString {
        return self as NSString
    }
}

public extension NSString {
    func bridge() -> String {
        return self as String
    }
}

#endif
