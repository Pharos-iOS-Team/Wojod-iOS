// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

enum EmptyStateType {
    case noOrganizations
    case emptySearch
    case noPurchasedCourses
    case noRelatedCourses
    case noExploreMoreCourses
    case loading

    var title: String {
        switch self {
        case .loading:
            return ""
        default:
            return L10n.Home.Search.emptyStateTitle
        }
    }

    var description: String {
        switch self {
        case .noOrganizations:
            return L10n.Organizations.emptyDescription
        case .emptySearch:
            return L10n.Home.Search.emptyStateDescription
        case .noPurchasedCourses, .noRelatedCourses, .noExploreMoreCourses:
            return L10n.Home.defaultEmptyState
        case .loading:
            return ""
        }
    }

    var buttonTitle: String? {
        switch self {
        case .noOrganizations:
            return L10n.Organizations.firstApply
        default:
            return nil
        }
    }

    var verticalOffset: CGFloat {
        switch self {
        case .noPurchasedCourses:
            return 30
        default:
            return 140
        }
    }
}
