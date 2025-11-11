// Copyright © 2025 Pharos Solutions. All rights reserved.

enum AppName: String, Decodable {
    case wojod = "Wojod"
    case hassanElnaggar = "Mr. Hassan Elnaggar"
    case perfectionInPhysics = "Perfection in Physics"
    case royalMedicine = "Royal Medicine"
    
    
    var serverAppName: String {
        switch self {
        case .wojod:
            return "wojoudacademy"
        case .hassanElnaggar:
            return "mrhassanelnaggar"
        case .perfectionInPhysics:
            return "perfectioninphysics"
        case .royalMedicine:
            return "royalmedicine"
        }
    }
}
