#!/usr/bin/env ruby
require 'fileutils'

configs_path = "./App/SupportingFiles/Configs/*"
version_key  = "APP_VERSION"
files_changed_count = 0

RED   = "\033[0;31m"
GREEN = "\033[0;32m"
WHITE = "\033[1;37m"

unless %w[major minor patch].include?(ARGV[0])
  puts "#{RED}usage: ./version.rb major/minor/patch#{WHITE}"
  exit(-1)
end

Dir.glob(configs_path).each do |file|
  next unless File.file?(file)

  text = File.read(file)
  if text =~ /^#{version_key}\s*=\s*(\d+)\.(\d+)\.(\d+)/
    major, minor, build = $1.to_i, $2.to_i, $3.to_i

    case ARGV[0]
    when "major"
      major, minor, build = major + 1, 0, 0
    when "minor"
      minor, build = minor + 1, 0
    when "patch"
      build += 1
    end

    new_version = "#{major}.#{minor}.#{build}"
    new_text = text.sub(/^#{version_key}\s*=.*$/, "#{version_key} = #{new_version}")

    File.write(file, new_text)
    files_changed_count += 1
  end
end

# Delete *.xcconfig-e files
Dir.glob('./App/SupportingFiles/Configs/*.xcconfig-e').each do |f|
  FileUtils.rm_f(f)
end

puts "#{GREEN}Success. #{files_changed_count} Files have been updated#{WHITE}"
