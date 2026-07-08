// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

final class Paginator<Item> {
    typealias FetchPage = (_ page: Int) async throws -> [Item]

    private(set) var items: [Item] = []
    private(set) var page: Int
    private(set) var isLoading = false
    private(set) var hasMorePages = true

    private let firstPage: Int
    private let fetchPage: FetchPage

    init(firstPage: Int = 1, fetchPage: @escaping FetchPage) {
        self.firstPage = firstPage
        self.page = firstPage
        self.fetchPage = fetchPage
    }

    @discardableResult
    func loadNextPage() async throws -> [Item] {
        guard !isLoading, hasMorePages else { return [] }

        isLoading = true
        let requestedPage = page

        do {
            let newItems = try await fetchPage(requestedPage)
            isLoading = false

            if requestedPage == firstPage {
                items.removeAll()
            }
            items.append(contentsOf: newItems)
            hasMorePages = !newItems.isEmpty
            page += 1
            return newItems
        } catch {
            isLoading = false
            throw error
        }
    }

    func refresh() async throws -> [Item] {
        reset()
        return try await loadNextPage()
    }

    func reset() {
        page = firstPage
        items.removeAll()
        hasMorePages = true
        isLoading = false
    }

    func replaceItems(_ newItems: [Item]) {
        items = newItems
    }
}
