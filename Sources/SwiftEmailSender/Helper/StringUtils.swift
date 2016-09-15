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
    /// Converts a Swift string to a UTF encoded Data
    ///
    /// - Parameter str: String
    ///
    /// - Returns: Data?
    ///
    public static func toUtf8String(_ str: String) -> Data? {
        return str.data(using: String.Encoding.utf8)
    }


    ///
    /// Converts a Swift string to a UTF encoded null terminated Data
    ///
    /// - Parameter str: String
    ///
    /// - Returns: Data?
    ///
    public static func toNullTerminatedUtf8String(_ str: String) -> Data? {
        let cString = str.cString(using: String.Encoding.utf8)
        return cString?.withUnsafeBufferPointer() { buffer -> Data? in
            return buffer.baseAddress != nil ? Data(bytes: buffer.baseAddress!, count: buffer.count) : nil
        }
    }


    ///
    /// Converts a UTF 8 encoded string to a Swift String
    ///
    /// - Parameter data: The UTF-8 encoded string to convert
    ///
    /// - Returns: String?
    ///
    public static func fromUtf8String(_ data: Data) -> String? {
        return String(data: data, encoding: String.Encoding.utf8)
    }
}

extension String {
    func preg_test(pattern: String) -> Bool {
        if ( self.range(of: pattern, options: .regularExpression) != nil ) {
            return true;
        }

        return false;
    }

    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines);
    }

    func split(separator: String) -> Array<String> {
        return self.components(separatedBy: separator);
    }
}
