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
        #if os(Linux)
        let data = nsstr.dataUsingEncoding(NSUTF8StringEncoding)
        #else
        let data = nsstr.data(using: NSUTF8StringEncoding)
        #endif
        return data
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
        #if os(Linux)
        let cString = nsstr.cStringUsingEncoding(NSUTF8StringEncoding)
        #else
        let cString = nsstr.cString(using: NSUTF8StringEncoding)
        #endif

        let data = NSData(bytes: cString, length: Int(strlen(cString!))+1)
        return data
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
