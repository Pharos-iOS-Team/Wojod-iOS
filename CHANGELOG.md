# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/).

<details>
<summary>Formatting Rules for Entries</summary>
Each entry should use the following format (Asana url is shortened to the last 4 chars):

```markdown
- Summarize what was changed in a single line.  
  Task: [OACDMIOS-589](https://jira.pharos-solutions.de/browse/OACDMIOS-589) | PR: [#255](https://github.com/pharos-solutions/one-academy-ios/pull/255) | Author: [Ramy Rizkalla](https://github.com/ramywagdyrizkalla)
```

Note that at the end of the summary line, you need to add two whitespaces (`  `) for correct rendering on Bitbucket.

If needed, pluralize to `Tasks`, `PRs` or `Authors` and list multiple separated by `, `.
</details>
## [Unreleased]
### Added
- Added Force update alert using `siren`.  
  Task: [CPI-337](https://jira.pharos-solutions.de/browse/CPI-337) | PR: [#24](https://github.com/Pharos-iOS-Team/Wojod-iOS/pull/24) | Author: [Sara Rady](https://github.com/sara-rady)
### Changed
- None.
### Deprecated
- None.
### Removed
- None.
### Fixed
- Fixed Ci/CD pipeline & add staging workflow.  
  Task: [CPI-339](https://jira.pharos-solutions.de/browse/CPI-339) | PR: [#26](https://github.com/Pharos-iOS-Team/Wojod-iOS/pull/26) | Author: [Sara Rady](https://github.com/sara-rady)
- Fixed restriction on PDF sharing; it is now prevented in `SquareCenter` only.
  Task: [CPI-338](https://jira.pharos-solutions.de/browse/CPI-338) | PR: [#27](https://github.com/Pharos-iOS-Team/Wojod-iOS/pull/27) | Author: [Sara Rady](https://github.com/sara-rady)
### Security
- None.

## [1.12.0] - 2026-04-20
### Added
- Added Model Answer in Essay questions.  
  Task: [CPI-328](https://jira.pharos-solutions.de/browse/CPI-328) | PR: [#19](https://github.com/Pharos-iOS-Team/Wojod-iOS/pull/19) | Author: [Sara Rady](https://github.com/sara-rady)
- Added Comment with images in graded quizzes/exercises.  
  Task: [CPI-332](https://jira.pharos-solutions.de/browse/CPI-332) | PR: [#20](https://github.com/Pharos-iOS-Team/Wojod-iOS/pull/20) | Author: [Sara Rady](https://github.com/sara-rady)
- Added PDFViewController to prevent sharing in PDF files.  
  Task: [CPI-334](https://jira.pharos-solutions.de/browse/CPI-334) | PR: [#22](https://github.com/Pharos-iOS-Team/Wojod-iOS/pull/22) | Author: [Sara Rady](https://github.com/sara-rady)
### Fixed
- Fixed video audio was being recorded
  Task: [CPI-333](https://jira.pharos-solutions.de/browse/CPI-333) | PR: [#21](https://github.com/Pharos-iOS-Team/Wojod-iOS/pull/21) | Author: [Sara Rady](https://github.com/sara-rady)
- Fixed state label in exercise
  Task: [CPI-336](https://jira.pharos-solutions.de/browse/CPI-336) | PR: [#23](https://github.com/Pharos-iOS-Team/Wojod-iOS/pull/23) | Author: [Sara Rady](https://github.com/sara-rady)

## [1.11.0] - 2026-03-18
### Added
- Added Expired Session Alert.  
  Task: [CPI-325](https://jira.pharos-solutions.de/browse/CPI-325) | PR: [#17](https://github.com/Pharos-iOS-Team/Wojod-iOS/pull/17) | Author: [Sara Rady](https://github.com/sara-rady)
### Changed
- Changed screen capturing prevention behavior. 
  Task: [CPI-322](https://jira.pharos-solutions.de/browse/CPI-322) | PR: [#16](https://github.com/Pharos-iOS-Team/Wojod-iOS/pull/16) | Author: [Sara Rady](https://github.com/sara-rady)
- Changed youtube watermark size. 
  Task: [CPI-324](https://jira.pharos-solutions.de/browse/CPI-324) | PR: [#16](https://github.com/Pharos-iOS-Team/Wojod-iOS/pull/16) | Author: [Sara Rady](https://github.com/sara-rady)

## [1.10.0] - 2026-03-09
### Added
- Added Youtube player framework.  
  Task: [CPI-316](https://jira.pharos-solutions.de/browse/CPI-316) | PR: [#13](https://github.com/Pharos-iOS-Team/Wojod-iOS/pull/13) | Author: [Sara Rady](https://github.com/sara-rady)
- Added Square Center whitelabel app.  
  Task: [CPI-314](https://jira.pharos-solutions.de/browse/CPI-314) | PR: [#12](https://github.com/Pharos-iOS-Team/Wojod-iOS/pull/12) | Author: [Sara Rady](https://github.com/sara-rady)
### Changed
- Changed Support number for Royal medicine.  
  Task: [CPI-319](https://jira.pharos-solutions.de/browse/CPI-319) | PR: [#14](https://github.com/Pharos-iOS-Team/Wojod-iOS/pull/14) | Author: [Sara Rady](https://github.com/sara-rady)
### Fixed
- Fixed Courses and Lessons API Calls in parallel.  
  Task: [CPI-321](https://jira.pharos-solutions.de/browse/CPI-321) | PR: [#15](https://github.com/Pharos-iOS-Team/Wojod-iOS/pull/15) | Author: [Sara Rady](https://github.com/sara-rady)
  
## [1.9.0] - 2026-01-29
### Fixed
- Fixed iOS 26 issues.  
  Task: [CPI-307](https://jira.pharos-solutions.de/browse/CPI-307) | PR: [#7](https://github.com/Pharos-iOS-Team/Wojod-iOS/pull/7) | Author: [Sara Rady](https://github.com/sara-rady)
- Fixed VideoCipher view count calculation.  
  Task: [CPI-311](https://jira.pharos-solutions.de/browse/CPI-311) | PR: [#10](https://github.com/Pharos-iOS-Team/Wojod-iOS/pull/10) | Author: [Sara Rady](https://github.com/sara-rady)
### Changed
- Replaced the `Book` feature with the teacher’s contact details instead.  
  Task: [CPI-313](https://jira.pharos-solutions.de/browse/CPI-313) | PR: [#11](https://github.com/Pharos-iOS-Team/Wojod-iOS/pull/11) | Author: [Sara Rady](https://github.com/sara-rady)
  
## [1.8.0] - 2025-08-08
### Added
- Locked lessons if they are linked to unsolved quiz.
  Task: [CPI-292](https://jira.pharos-solutions.de/browse/CPI-292) | PR: [#3](https://github.com/pharos-solutions/Courses-Portal-iOS/pull/3) | Author: [Eslam Salem](https://gitlab.com/eslam.salem)
