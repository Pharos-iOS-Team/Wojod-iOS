// Copyright © 2025 Pharos Solutions. All rights reserved.

enum AppName: String, Decodable {
    case wojod = "Wojod"
    case hassanElnaggar = "Mr. Hassan Elnaggar"
    case perfectionInPhysics = "Perfection in Physics"
    case royalMedicine = "Royal Medicine"
    case squareCenter = "Square Center For Law"
    
    /// The unique identifier used exclusively when the app is running in **Guest Mode**.
    var guestModeKey: String {
        switch self {
        case .wojod:
            return "wojoudacademy"
        case .hassanElnaggar:
            return "mrhassanelnaggar"
        case .perfectionInPhysics:
            return "perfectioninphysics"
        case .royalMedicine:
            return "royalmedicine"
        case .squareCenter:
            return "square_center"
        }
    }
    
    /// The organization identifier used for authentication when the white-label app shares the same base URL as  **Wojod**.
    var loginOrganization: String? {
        switch self {
        case .squareCenter:
            return "square_center"
        case .royalMedicine:
            return "royal_medicine"
        default:
            return nil
        }
    }
}
