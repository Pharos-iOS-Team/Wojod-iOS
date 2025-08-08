#!/usr/bin/env ruby

# A class for building upload and submission scripts for all school configurations
class ScriptBuilder
    @configuration_files = Dir["./App/SupportingFiles/Configs/*.xcconfig"]

    # Sets the all scripts needed for uploading and submitting the apps.
    def set_script(lane, script_file_name, target)
      content = ""
      @configuration_files.each do |file_path|
        configuration_base_file_name = File.basename(file_path, '.xcconfig')
        content << "bundle exec fastlane #{lane} --env #{configuration_base_file_name.downcase}\n"
      end

      # Ensure "release" directory exists
      release_dir = "release"
      FileUtils.mkdir_p(release_dir) unless Dir.exist?(release_dir)

      script_path = File.join(release_dir, "#{script_file_name}.sh")

      # Create the file if it doesn't exist and write content
      File.write(script_path, content, mode: 'w')

      # Make the script executable
      FileUtils.chmod("+x", script_path)
    end

    # Sets the environment files for fastlane.
    def set_fastlane_env_files
      filesChangedCount = 0

      @configuration_files.each { |file_path|
          configuration_base_file_name=File.basename(file_path, '.xcconfig')
          environment_file="fastlane/.env.#{configuration_base_file_name.downcase}"
          content=""
          filesChangedCount=filesChangedCount+1

          File.open(file_path, 'r') do |file|
              file.each_line do |line|
                  # Append the bundle ID and App Store version to the file.
                  if line.include?("PRODUCT_BUNDLE_IDENTIFIER") || line.include?("APP_VERSION")
                      content << line
                  end
              end
              
              content << 'TEAM_ID = "46AX569373"'
              content << 'KEY_ID = "33B7DSRT37"'
              content << 'ISSUER_ID = "15edc47d-4fe3-4c73-b116-142c1035e1f2"'
              content << 'KEY_FILE_PATH = "fastlane/AuthKey_33B7DSRT37.p8"'
              content << "CONFIG = \"#{configuration_base_file_name}\""
              content << "\n"

              File.write(environment_file, content, mode: 'w')
          end

          puts "#{filesChangedCount}- #{File.basename(environment_file)} Created"#.green
      }

    end
end


target_argument=ARGV.first

script_builder = ScriptBuilder.new

# Sets the env files for fastlane.
script_builder.set_fastlane_env_files

# Sets the script for uploading builds for each school.
# The `upload_to_appstore` script calls the fastlane lane for each school.
script_builder.set_script('upload_to_appstore', 'upload_to_appstore', target_argument)
