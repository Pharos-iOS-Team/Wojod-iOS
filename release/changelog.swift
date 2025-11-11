#!/usr/bin/swift sh

import Foundation

// swiftlint:disable all

let changelogContents = try! String(contentsOfFile: "CHANGELOG.md")
let freshUnreleasedSection: String = """
    [Unreleased]
    ### Added
    - None.
    ### Changed
    - None.
    ### Deprecated
    - None.
    ### Removed
    - None.
    ### Fixed
    - None.
    ### Security
    - None.

    """

let version: String = CommandLine.arguments[1]
let sectionSeparator: String = "\n## "

let dateFormatter = ISO8601DateFormatter()
dateFormatter.formatOptions = .withFullDate
let formattedDate: String = dateFormatter.string(from: Date())

var sections: [String] = changelogContents.components(separatedBy: sectionSeparator)
sections.insert(freshUnreleasedSection, at: 1)

sections[2] = sections[2].replacingOccurrences(of: "[Unreleased]", with: "[\(version)] - \(formattedDate)")
sections[2] = sections[2].replacingOccurrences(of: "### Added\n- None.\n", with: "")
sections[2] = sections[2].replacingOccurrences(of: "### Changed\n- None.\n", with: "")
sections[2] = sections[2].replacingOccurrences(of: "### Deprecated\n- None.\n", with: "")
sections[2] = sections[2].replacingOccurrences(of: "### Removed\n- None.\n", with: "")
sections[2] = sections[2].replacingOccurrences(of: "### Fixed\n- None.\n", with: "")
sections[2] = sections[2].replacingOccurrences(of: "### Security\n- None.\n", with: "")

let newChangelogContents: String = sections.joined(separator: sectionSeparator)
try! newChangelogContents.write(toFile: "CHANGELOG.md", atomically: true, encoding: .utf8)
print("Successfully updated CHANGELOG.md.")
