// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable superfluous_disable_command implicit_return
// swiftlint:disable sorted_imports
import CoreData
import Foundation

// swiftlint:disable attributes file_length vertical_whitespace_closing_braces
// swiftlint:disable identifier_name line_length type_body_length

// MARK: - Action

internal class Action: NSManagedObject {
  internal class var entityName: String {
    return "Action"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
  @nonobjc internal class func fetchRequest() -> NSFetchRequest<Action> {
    return NSFetchRequest<Action>(entityName: entityName)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<Action> {
    return NSFetchRequest<Action>(entityName: entityName)
  }

  // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection
  @NSManaged internal var name: String
  @NSManaged internal var rawChannel: Int16
  @NSManaged internal var rawNote: Int16
  @NSManaged internal var rawStatus: Int16
  @NSManaged internal var switchInput: Bool
  @NSManaged internal var preset: PresetConfig
  @NSManaged internal var setup: Setup
  // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}

// MARK: - Camera

internal class Camera: NSManagedObject {
  internal class var entityName: String {
    return "Camera"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
  @nonobjc internal class func fetchRequest() -> NSFetchRequest<Camera> {
    return NSFetchRequest<Camera>(entityName: entityName)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<Camera> {
    return NSFetchRequest<Camera>(entityName: entityName)
  }

  // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection
  @NSManaged internal var address: String
  @NSManaged internal var name: String
  internal var rawPort: Int32? {
    get {
      let key = "rawPort"
      willAccessValue(forKey: key)
      defer { didAccessValue(forKey: key) }

      return primitiveValue(forKey: key) as? Int32
    }
    set {
      let key = "rawPort"
      willChangeValue(forKey: key)
      defer { didChangeValue(forKey: key) }

      setPrimitiveValue(newValue, forKey: key)
    }
  }
  @NSManaged internal var presetConfigs: Set<PresetConfig>?
  @NSManaged internal var setup: Setup
  @NSManaged internal var switcherInput: SwitcherInput?
  // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}

// MARK: Relationship PresetConfigs

extension Camera {
  @objc(addPresetConfigsObject:)
  @NSManaged public func addToPresetConfigs(_ value: PresetConfig)

  @objc(removePresetConfigsObject:)
  @NSManaged public func removeFromPresetConfigs(_ value: PresetConfig)

  @objc(addPresetConfigs:)
  @NSManaged public func addToPresetConfigs(_ values: Set<PresetConfig>)

  @objc(removePresetConfigs:)
  @NSManaged public func removeFromPresetConfigs(_ values: Set<PresetConfig>)
}

// MARK: - PresetConfig

internal class PresetConfig: NSManagedObject {
  internal class var entityName: String {
    return "PresetConfig"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
  @nonobjc internal class func fetchRequest() -> NSFetchRequest<PresetConfig> {
    return NSFetchRequest<PresetConfig>(entityName: entityName)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<PresetConfig> {
    return NSFetchRequest<PresetConfig>(entityName: entityName)
  }

  // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection
  @NSManaged internal var name: String
  @NSManaged internal var rawColor: Int16
  @NSManaged internal var rawPreset: Int16
  @NSManaged internal var actions: Set<Action>?
  @NSManaged internal var camera: Camera
  // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}

// MARK: Relationship Actions

extension PresetConfig {
  @objc(addActionsObject:)
  @NSManaged public func addToActions(_ value: Action)

  @objc(removeActionsObject:)
  @NSManaged public func removeFromActions(_ value: Action)

  @objc(addActions:)
  @NSManaged public func addToActions(_ values: Set<Action>)

  @objc(removeActions:)
  @NSManaged public func removeFromActions(_ values: Set<Action>)
}

// MARK: - Setup

internal class Setup: NSManagedObject {
  internal class var entityName: String {
    return "Setup"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
  @nonobjc internal class func fetchRequest() -> NSFetchRequest<Setup> {
    return NSFetchRequest<Setup>(entityName: entityName)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<Setup> {
    return NSFetchRequest<Setup>(entityName: entityName)
  }

  // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection
  @NSManaged internal var name: String
  @NSManaged internal var rawActions: NSOrderedSet?
  @NSManaged internal var rawCameras: NSOrderedSet?
  // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}

// MARK: Relationship RawActions

extension Setup {
  @objc(insertObject:inRawActionsAtIndex:)
  @NSManaged public func insertIntoRawActions(_ value: Action, at idx: Int)

  @objc(removeObjectFromRawActionsAtIndex:)
  @NSManaged public func removeFromRawActions(at idx: Int)

  @objc(insertRawActions:atIndexes:)
  @NSManaged public func insertIntoRawActions(_ values: [Action], at indexes: NSIndexSet)

  @objc(removeRawActionsAtIndexes:)
  @NSManaged public func removeFromRawActions(at indexes: NSIndexSet)

  @objc(replaceObjectInRawActionsAtIndex:withObject:)
  @NSManaged public func replaceRawActions(at idx: Int, with value: Action)

  @objc(replaceRawActionsAtIndexes:withRawActions:)
  @NSManaged public func replaceRawActions(at indexes: NSIndexSet, with values: [Action])

  @objc(addRawActionsObject:)
  @NSManaged public func addToRawActions(_ value: Action)

  @objc(removeRawActionsObject:)
  @NSManaged public func removeFromRawActions(_ value: Action)

  @objc(addRawActions:)
  @NSManaged public func addToRawActions(_ values: NSOrderedSet)

  @objc(removeRawActions:)
  @NSManaged public func removeFromRawActions(_ values: NSOrderedSet)
}

// MARK: Relationship RawCameras

extension Setup {
  @objc(insertObject:inRawCamerasAtIndex:)
  @NSManaged public func insertIntoRawCameras(_ value: Camera, at idx: Int)

  @objc(removeObjectFromRawCamerasAtIndex:)
  @NSManaged public func removeFromRawCameras(at idx: Int)

  @objc(insertRawCameras:atIndexes:)
  @NSManaged public func insertIntoRawCameras(_ values: [Camera], at indexes: NSIndexSet)

  @objc(removeRawCamerasAtIndexes:)
  @NSManaged public func removeFromRawCameras(at indexes: NSIndexSet)

  @objc(replaceObjectInRawCamerasAtIndex:withObject:)
  @NSManaged public func replaceRawCameras(at idx: Int, with value: Camera)

  @objc(replaceRawCamerasAtIndexes:withRawCameras:)
  @NSManaged public func replaceRawCameras(at indexes: NSIndexSet, with values: [Camera])

  @objc(addRawCamerasObject:)
  @NSManaged public func addToRawCameras(_ value: Camera)

  @objc(removeRawCamerasObject:)
  @NSManaged public func removeFromRawCameras(_ value: Camera)

  @objc(addRawCameras:)
  @NSManaged public func addToRawCameras(_ values: NSOrderedSet)

  @objc(removeRawCameras:)
  @NSManaged public func removeFromRawCameras(_ values: NSOrderedSet)
}

// MARK: - Switcher

internal class Switcher: NSManagedObject {
  internal class var entityName: String {
    return "Switcher"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
  @nonobjc internal class func fetchRequest() -> NSFetchRequest<Switcher> {
    return NSFetchRequest<Switcher>(entityName: entityName)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<Switcher> {
    return NSFetchRequest<Switcher>(entityName: entityName)
  }

  // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection
  internal var rawChannel: Int16? {
    get {
      let key = "rawChannel"
      willAccessValue(forKey: key)
      defer { didAccessValue(forKey: key) }

      return primitiveValue(forKey: key) as? Int16
    }
    set {
      let key = "rawChannel"
      willChangeValue(forKey: key)
      defer { didChangeValue(forKey: key) }

      setPrimitiveValue(newValue, forKey: key)
    }
  }
  internal var rawMIDIID: Int32? {
    get {
      let key = "rawMIDIID"
      willAccessValue(forKey: key)
      defer { didAccessValue(forKey: key) }

      return primitiveValue(forKey: key) as? Int32
    }
    set {
      let key = "rawMIDIID"
      willChangeValue(forKey: key)
      defer { didChangeValue(forKey: key) }

      setPrimitiveValue(newValue, forKey: key)
    }
  }
  @NSManaged internal var rawInputs: NSOrderedSet?
  // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}

// MARK: Relationship RawInputs

extension Switcher {
  @objc(insertObject:inRawInputsAtIndex:)
  @NSManaged public func insertIntoRawInputs(_ value: SwitcherInput, at idx: Int)

  @objc(removeObjectFromRawInputsAtIndex:)
  @NSManaged public func removeFromRawInputs(at idx: Int)

  @objc(insertRawInputs:atIndexes:)
  @NSManaged public func insertIntoRawInputs(_ values: [SwitcherInput], at indexes: NSIndexSet)

  @objc(removeRawInputsAtIndexes:)
  @NSManaged public func removeFromRawInputs(at indexes: NSIndexSet)

  @objc(replaceObjectInRawInputsAtIndex:withObject:)
  @NSManaged public func replaceRawInputs(at idx: Int, with value: SwitcherInput)

  @objc(replaceRawInputsAtIndexes:withRawInputs:)
  @NSManaged public func replaceRawInputs(at indexes: NSIndexSet, with values: [SwitcherInput])

  @objc(addRawInputsObject:)
  @NSManaged public func addToRawInputs(_ value: SwitcherInput)

  @objc(removeRawInputsObject:)
  @NSManaged public func removeFromRawInputs(_ value: SwitcherInput)

  @objc(addRawInputs:)
  @NSManaged public func addToRawInputs(_ values: NSOrderedSet)

  @objc(removeRawInputs:)
  @NSManaged public func removeFromRawInputs(_ values: NSOrderedSet)
}

// MARK: - SwitcherInput

internal class SwitcherInput: NSManagedObject {
  internal class var entityName: String {
    return "SwitcherInput"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
  @nonobjc internal class func fetchRequest() -> NSFetchRequest<SwitcherInput> {
    return NSFetchRequest<SwitcherInput>(entityName: entityName)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<SwitcherInput> {
    return NSFetchRequest<SwitcherInput>(entityName: entityName)
  }

  // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection
  @NSManaged internal var camera: Camera?
  @NSManaged internal var switcher: Switcher
  // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}

// swiftlint:enable identifier_name line_length type_body_length
