source "https://rubygems.org"

gem "fastlane"

# Ruby 3.4 moved 'abbrev' out of the default stdlib into a bundled gem.
# fastlane's dependency highline 2.0.x uses it without declaring it, which
# causes a LoadError on Ruby 3.4+ runners. Declaring it here fixes that.
gem "abbrev"
