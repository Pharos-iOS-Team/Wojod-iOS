// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  internal typealias AssetColorTypeAlias = NSColor
  internal typealias AssetImageTypeAlias = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  internal typealias AssetColorTypeAlias = UIColor
  internal typealias AssetImageTypeAlias = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Colors {
    internal static let backgroundLightGreyColor = ColorAsset(name: "backgroundLightGreyColor")
    internal static let backgroundLightPurple = ColorAsset(name: "backgroundLightPurple")
    internal static let darkGreyColor = ColorAsset(name: "darkGreyColor")
    internal static let errorAlertBackgroundColor = ColorAsset(name: "errorAlertBackgroundColor")
    internal static let errorAlertLabelColor = ColorAsset(name: "errorAlertLabelColor")
    internal static let informationViewColor = ColorAsset(name: "informationViewColor")
    internal static let labelGreyColor = ColorAsset(name: "labelGreyColor")
    internal static let lightAccentColor = ColorAsset(name: "lightAccentColor")
    internal static let lightGreyColor = ColorAsset(name: "lightGreyColor")
    internal static let sendButtonColor = ColorAsset(name: "sendButtonColor")
    internal static let superLightGrey = ColorAsset(name: "superLightGrey")
    internal static let superLightGreyBackgroundColor = ColorAsset(name: "superLightGreyBackgroundColor")
    internal static let tabBarColor = ColorAsset(name: "tabBarColor")
  }
  internal enum Images {
    internal static let accentColor = ColorAsset(name: "AccentColor")
    internal static let backIcon = ImageAsset(name: "BackIcon")
    internal static let backIconWhite = ImageAsset(name: "BackIconWhite")
    internal static let filledStar = ImageAsset(name: "filledStar")
    internal static let star = ImageAsset(name: "star")
    internal static let collapse = ImageAsset(name: "collapse")
    internal static let expand = ImageAsset(name: "expand")
    internal static let nextIndicator = ImageAsset(name: "nextIndicator")
    internal static let quiz = ImageAsset(name: "quiz")
    internal static let errorSymbol = ImageAsset(name: "errorSymbol")
    internal static let pdf = ImageAsset(name: "pdf")
    internal static let excelExtension = ImageAsset(name: "ExcelExtension")
    internal static let imageExtension = ImageAsset(name: "ImageExtension")
    internal static let pdfExtension = ImageAsset(name: "PDFExtension")
    internal static let unknownExtension = ImageAsset(name: "UnknownExtension")
    internal static let videoExtension = ImageAsset(name: "VideoExtension")
    internal static let wordExtension = ImageAsset(name: "WordExtension")
    internal static let adImage = ImageAsset(name: "adImage")
    internal static let coursesLogo = ImageAsset(name: "CoursesLogo")
    internal static let welcomeJohnSignInToContinueCopy = ImageAsset(name: "Welcome John! Sign in to continue Copy")
    internal static let welcome = ImageAsset(name: "Welcome")
    internal static let path = ImageAsset(name: "Path")
    internal static let academicInfoTitleAr = ImageAsset(name: "AcademicInfoTitleAr")
    internal static let academicInfoTitleEn = ImageAsset(name: "AcademicInfoTitleEn")
    internal static let addAvatarTitleAr = ImageAsset(name: "AddAvatarTitleAr")
    internal static let addAvatarTitleEn = ImageAsset(name: "AddAvatarTitleEn")
    internal static let signUpTitlePageOneAr = ImageAsset(name: "SignUpTitlePageOneAr")
    internal static let signUpTitlePageOneEn = ImageAsset(name: "SignUpTitlePageOneEn")
    internal static let letsKnowMoreTitleAr = ImageAsset(name: "LetsKnowMoreTitleAr")
    internal static let letsKnowMoreTitleEn = ImageAsset(name: "LetsKnowMoreTitleEn")
    internal static let locationInfoTitleAr = ImageAsset(name: "LocationInfoTitleAr")
    internal static let locationInfoTitleEn = ImageAsset(name: "LocationInfoTitleEn")
    internal static let firstMilestoneAr = ImageAsset(name: "FirstMilestoneAr")
    internal static let firstMilestoneEn = ImageAsset(name: "FirstMilestoneEn")
    internal static let fourthMilestoneAr = ImageAsset(name: "FourthMilestoneAr")
    internal static let fourthMilestoneEn = ImageAsset(name: "FourthMilestoneEn")
    internal static let secondMilestoneAr = ImageAsset(name: "SecondMilestoneAr")
    internal static let secondMilestoneEn = ImageAsset(name: "SecondMilestoneEn")
    internal static let thirdMilestoneAr = ImageAsset(name: "ThirdMilestoneAr")
    internal static let thirdMilestoneEn = ImageAsset(name: "ThirdMilestoneEn")
    internal static let wrongCredentialsAr = ImageAsset(name: "WrongCredentialsAr")
    internal static let wrongCredentialsEn = ImageAsset(name: "wrongCredentialsEn")
    internal static let boyAvatarFaded = ImageAsset(name: "boyAvatarFaded")
    internal static let disclosureIndicator = ImageAsset(name: "disclosureIndicator")
    internal static let gear = ImageAsset(name: "Gear")
    internal static let tick = ImageAsset(name: "Tick")
    internal static let alert = ImageAsset(name: "alert")
    internal static let notification = ImageAsset(name: "notification")
    internal static let privacy = ImageAsset(name: "privacy")
    internal static let setting = ImageAsset(name: "setting")
    internal static let shape = ImageAsset(name: "Shape")
    internal static let splash = ImageAsset(name: "Splash")
    internal static let home = ImageAsset(name: "Home")
    internal static let homeSelected = ImageAsset(name: "HomeSelected")
    internal static let courses = ImageAsset(name: "courses")
    internal static let coursesSelected = ImageAsset(name: "coursesSelected")
    internal static let settings = ImageAsset(name: "settings")
    internal static let settingsSelected = ImageAsset(name: "settingsSelected")
    internal static let boyAvatar = ImageAsset(name: "boyAvatar")
    internal static let close = ImageAsset(name: "close")
    internal static let defaultAvatar = ImageAsset(name: "defaultAvatar")
    internal static let download = ImageAsset(name: "download")
    internal static let girlAvatar = ImageAsset(name: "girlAvatar")
    internal static let girlAvatarFaded = ImageAsset(name: "girlAvatarFaded")
    internal static let helpCenter = ImageAsset(name: "helpCenter")
    internal static let homeNotification = ImageAsset(name: "homeNotification")
    internal static let newGenericExt = ImageAsset(name: "newGenericExt")
    internal static let nextIcon = ImageAsset(name: "nextIcon")
    internal static let notificationAvatar = ImageAsset(name: "notificationAvatar")
    internal static let oval = ImageAsset(name: "oval")
    internal static let pdfIcon = ImageAsset(name: "pdfIcon")
    internal static let person = ImageAsset(name: "person")
    internal static let playButton = ImageAsset(name: "playButton")
    internal static let plusIcn = ImageAsset(name: "plusIcn")
    internal static let selectedRadioButton = ImageAsset(name: "selectedRadioButton")
    internal static let selectedRadioButton2 = ImageAsset(name: "selectedRadioButton2")
    internal static let small = ImageAsset(name: "small")
    internal static let unselectedRadioButton = ImageAsset(name: "unselectedRadioButton")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ColorAsset {
  internal fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  internal var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

internal extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct DataAsset {
  internal fileprivate(set) var name: String

  #if os(iOS) || os(tvOS) || os(OSX)
  @available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
  internal var data: NSDataAsset {
    return NSDataAsset(asset: self)
  }
  #endif
}

#if os(iOS) || os(tvOS) || os(OSX)
@available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
internal extension NSDataAsset {
  convenience init!(asset: DataAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(name: asset.name, bundle: bundle)
    #elseif os(OSX)
    self.init(name: NSDataAsset.Name(asset.name), bundle: bundle)
    #endif
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  internal var image: AssetImageTypeAlias {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = AssetImageTypeAlias(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = AssetImageTypeAlias(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

internal extension AssetImageTypeAlias {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
