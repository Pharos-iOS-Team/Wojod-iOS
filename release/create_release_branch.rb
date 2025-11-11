#!/usr/bin/env ruby
require 'fileutils'
require 'open3'

# Colors
RED    = "\033[0;31m"
YELLOW = "\033[1;33m"
GREEN  = "\033[0;32m"
RESET  = "\033[0m"

VERSION  = ENV['VERSION']
version_increment_type = ARGV[0]
target = ARGV[1]

def run!(cmd, desc = nil)
  puts "#{YELLOW}[release/create_release_branch.rb]: #{desc || cmd} ...#{RESET}"
  stdout, stderr, status = Open3.capture3(cmd)
  unless status.success?
    puts "#{RED}[release/start.rb]: Command failed: #{cmd}#{RESET}"
    puts stdout unless stdout.empty?
    puts stderr unless stderr.empty?
    exit 1
  end
  stdout
end

# --- Validation ---
if VERSION.nil? || VERSION.empty?
  puts "#{RED}[release/create_release_branch.rb]: Error! Variable VERSION not specified, use something like 'VERSION=1.0.0 release/start_release_branch.rb major/minor/patch' instead.#{RESET}"
  exit 1
end

if version_increment_type.nil? || version_increment_type.empty?
  puts "#{RED}[release/create_release_branch.rb]: Error! VERSION increment type is not provided. Use something like 'VERSION=1.0.0 release/start_release_branch.rb major/minor/patch'#{RESET}"
  exit 1
end

# --- Install Homebrew if missing ---
unless system('which brew > /dev/null')
  run!('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"', 'Installing Homebrew')
end

# --- Install swift-sh if missing ---
unless system('which swift-sh > /dev/null')
  run!('brew install swift-sh', 'Installing swift-sh')
end

# --- Ensure Xcode path ---
current_dev_path = `xcode-select -p`.strip
desired_dev_path = '/Applications/Xcode.app/Contents/Developer'
if current_dev_path != desired_dev_path
  run!("sudo xcode-select -s #{desired_dev_path}", 'Switching Xcode path')
end

# --- Install git-flow ---
run!('brew install git-flow', 'Installing git-flow')

# --- Init git-flow ---
run!('git flow init -d', 'Initializing git-flow')

# --- Pull latest master ---
run!('git stash', 'Stashing local changes')
run!('git checkout master', 'Switching to master')
run!('git pull origin', 'Pulling latest master from origin')

# --- Pull latest develop ---
run!('git checkout develop', 'Switching to develop')
run!('git pull origin', 'Pulling latest develop from origin')

# --- Start new release ---
run!("git flow release start #{VERSION}", "Starting release #{VERSION}")

# --- Bump version ---
run!("release/version.rb #{version_increment_type} #{target}", 'Bumping version number')

# --- Finalize changelog ---
run!("release/changelog.swift #{VERSION}", 'Finalizing changelog')

# --- Commit changes ---
run!('git add .', 'Adding changes')
run!("git commit -m 'Bump version num & finalize new Changelog section' -n", 'Committing changes')

# --- Push release branch ---
run!("git push origin release/#{VERSION}", 'Pushing release branch')

# --- Success message ---
puts "#{GREEN}[release/start.rb]: Release successfully started! 🚀🚀🚀 Checkout deployment status on GitHub:#{RESET}"
puts "#{GREEN}[release/start.rb]: https://github.com/Papershift/Station-iOS/actions?query=workflow%3ARelease#{RESET}"
puts "[release/start.rb]: ----------"
puts "#{YELLOW}[release/start.rb]: Once deploy is successful, finish the release in Git-Fork & push main + versions.#{RESET}"
