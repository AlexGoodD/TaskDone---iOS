import SwiftUI
import CoreData

@objc(ColorTransformer)
class ColorTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? Color else { return nil }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(color), requiringSecureCoding: false)
            return data
        } catch {
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            if let uiColor = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor {
                return Color(uiColor)
            }
        } catch {
            return nil
        }
        return nil
    }
}
