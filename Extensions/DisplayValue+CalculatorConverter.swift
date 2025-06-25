import Foundation

/*
 *
 * Thank you so much @NightwindDev for this swift magic
 *
 */

@_cdecl("writeSwiftString")
func writeSwiftString(nsString: NSString, ptr: UnsafeMutableRawPointer) {
    ptr.assumingMemoryBound(to: String.self).pointee = String(nsString)
}

@_cdecl("swiftStringToNSString")
func swiftStringToNSString(ptr: UnsafeRawPointer) -> NSString {
    let swiftString = ptr.assumingMemoryBound(to: String.self).pointee
    return NSString(string: swiftString)
}


class DisplayValue: NSObject {
    let value: String
    let userEntered: Bool

    @nonobjc init(value: String, userEntered: Bool) {
        self.value = value
        self.userEntered = userEntered
    }

    @objc override init() {
        fatalError("init() is not supported. Use init(value:userEntered:) instead.")
    }

    @objc func valueString() -> NSString {
        return NSString(string: value)
    }

    @objc func isUserEntered() -> Bool {
        return userEntered
    }

    @objc func getDescription() -> String {
        return "Value: \(value), User Entered: \(userEntered)"
    }
}