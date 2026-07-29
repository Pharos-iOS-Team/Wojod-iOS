// Copyright © 2025 Pharos Solutions. All rights reserved.

enum AppName: String, Decodable {
    case wojod = "Wojod"
    case hassanElnaggar = "Mr. Hassan Elnaggar"
    case perfectionInPhysics = "Perfection in Physics"
    case royalMedicine = "Royal Medicine"
    case squareCenter = "Square Center For Law"
    case khalidKhamis = "Mr. Khalid Khamis"
    case ashourAcademy = "Dr. Ashour Academy"
    
    /// The unique identifier used exclusively when the app is running in **Guest Mode**.
    var guestModeKey: String {
        switch self {
        case .wojod:
            return "wojoudacademy"
        case .squareCenter:
            return "square_center"
        case .royalMedicine:
            return "royalmedicine"
        case .hassanElnaggar:
            return "mrhassanelnaggar"
        case .perfectionInPhysics:
            return "perfectioninphysics"
        case .khalidKhamis:
            return "mrkhalidkhamis"
        case .ashourAcademy:
            return "drashouracademy"
        }
    }
    
    /// The organization identifier used for authentication when the white-label app shares the same base URL as  **Wojod**.
    var loginOrganization: String? {
        switch self {
        case .wojod:
            return nil
        case .squareCenter:
            return "square_center"
        case .royalMedicine:
            return "royal_medicine"
        case .hassanElnaggar:
            return "hassanelnaggar"
        case .perfectionInPhysics:
            return "perfection"
        case .khalidKhamis:
            return "khaledkhamees"
        case .ashourAcademy:
            return "ashouracademy"
        }
    }
}
