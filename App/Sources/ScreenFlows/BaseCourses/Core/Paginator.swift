// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

final class Paginator<Item> {
    typealias FetchPage = (_ page: Int, _ completion: @escaping (Result<[Item], Error>) -> Void) -> Void

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

    func loadNextPage(completion: @escaping (Result<[Item], Error>) -> Void) {
        guard !isLoading, hasMorePages else {
            completion(.success([]))
            return
        }

        isLoading = true
        let requestedPage = page

        fetchPage(requestedPage) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let newItems):
                if requestedPage == self.firstPage {
                    self.items.removeAll()
                }
                self.items.append(contentsOf: newItems)
                self.hasMorePages = !newItems.isEmpty
                self.page += 1
                completion(.success(newItems))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func refresh(completion: @escaping (Result<[Item], Error>) -> Void) {
        reset()
        loadNextPage(completion: completion)
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
