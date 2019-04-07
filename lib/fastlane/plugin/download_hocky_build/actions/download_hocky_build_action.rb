require 'fastlane/action'
require 'faraday'
require 'faraday_middleware'
require 'json'

require_relative '../helper/download_hocky_build_helper'

module Fastlane
  module Actions
    class DownloadHockyBuildAction < Action
        HOST_NAME = 'https://rink.hockeyapp.net'

        def self.run(params)
            UI.message("The download_hocky_build plugin is working!")

            api_token = params[:api_token]
            app_id = params[:app_id]
            output_directory = params[:output_directory]
            output_file = params[:output_file]
            output_info_file = params[:output_info_file]

            self.get_first_version(api_token, app_id, output_directory, output_file, output_info_file)
        end
    
  
        def self.connection(api_token)
            Faraday.new(:url => HOST_NAME) do |faraday|
                faraday.request  :multipart
                faraday.request  :url_encoded
                faraday.adapter  Faraday.default_adapter
                faraday.headers['X-HockeyAppToken'] = api_token
            end
        end


        def self.get_first_version(api_token, app_id, output_directory, output_file, output_info_file)

            conn = self.connection(api_token)
            response = conn.get do |req|
                req.url("/api/2/apps/#{app_id}/app_versions/")
            end

            if response.status == 200
                UI.message("Got app_versions successfully!")
                versions_json = JSON.parse(response.body)
                
                first_version = versions_json['app_versions'].first
                download_url = first_version['download_url']

                if download_url
                    UI.message("Got download_url: #{download_url} successfully!")
                else
                    UI.user_error!("Unable to parse build info. Status code is #{response.status}")
                    false
                end
                
                self.parse_build_url(download_url, api_token, app_id, output_directory, output_file, output_info_file)
            else
                UI.user_error!("Something went wrong with API request. Failed to get app_versions. Status code is #{response.status}")
                false
            end
        end


        def self.parse_build_url(url, api_token, app_id, output_directory, output_file, output_info_file)

            conn = self.connection(api_token)
            response = conn.get do |req|
                req.url("/api/2/apps/#{app_id}/app_versions?include_build_urls=true&build_url=#{url}")
            end

            if response.status == 200
                versions_json = JSON.parse(response.body)
                if versions_json
                    first_version = versions_json['app_versions'].first
                    storeBuildInfo(first_version, output_directory, output_info_file)
                    build_url = first_version["build_url"]
                    self.download_build(build_url, output_directory, output_file)
                else
                    UI.user_error!("Unable to get app_versions json")
                    false
                end
            else
                UI.user_error!("Something went wrong with API request. Status code is #{response.status}")
            end
        end


        def self.storeBuildInfo(version, output_directory, output_info_file)
            Dir.mkdir(output_directory) unless File.exists?(output_directory)
            path = File.join(output_directory, output_info_file)
            File.open(path,"w") do |f|
                f.write(version)
            end
        end


        def self.download_build(build_url, output_directory, output_file)

            if build_url.nil?
                UI.user_error!("URL to download the build is empty!")
                false
            end

            UI.success "Start to download the build file, which may take a minute"

            Dir.mkdir(output_directory) unless File.exists?(output_directory)
            path = File.join(output_directory, output_file)
            File.open(path, "wb") do |saved_file|
                open(build_url, "rb") do |read_file|
                    saved_file.write(read_file.read)
                end
            end
            UI.success "Successfully downloaded build 🍺"
        end


      def self.description
        "Helps to download builds from HockeyApp (iOS and Android)"
      end

      def self.authors
        ["Anton Morozov"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "DOWNLOAD_HOCKY_BUILD_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)

            FastlaneCore::ConfigItem.new(key: :api_token,
                                         env_name: "DOWNLOAD_HOCKY_BUILD_API_TOKEN",
                                         description: "API Token for Hockey Access",
                                         optional: false,
                                         type: String,
                                         verify_block: proc do |value|
                                         UI.user_error!("No API token for Hockey given, pass using `api_token: 'token'`") if value.to_s.length == 0
                                         end),

            FastlaneCore::ConfigItem.new(key: :app_id,
                                         env_name: "DOWNLOAD_HOCKY_BUILD_APP_ID",
                                         description: "Application identifier of the app you want to download",
                                         optional: false,
                                         type: String,
                                         verify_block: proc do |value|
                                         UI.user_error!("No app_id is given, pass using `app_id: 'id'`") if value.to_s.length == 0
                                         end),

            FastlaneCore::ConfigItem.new(key: :output_directory,
                                         env_name: "DOWNLOAD_HOCKY_BUILD_DIRECTORY",
                                         description: "Path to download folder",
                                         optional: false,
                                         type: String,
                                         default_value: File.expand_path('.')),

            FastlaneCore::ConfigItem.new(key: :output_file,
                                         env_name: "DOWNLOAD_HOCKY_BUILD_PATH",
                                         description: "Path to your symbols file",
                                         optional: false,
                                         type: String,
                                         default_value: File.expand_path('.')),

            FastlaneCore::ConfigItem.new(key: :output_info_file,
                                         env_name: "DOWNLOAD_HOCKY_BUILD_INFO_PATH",
                                         description: "Path to your symbols info file",
                                         optional: false,
                                         type: String,
                                         default_value: File.expand_path('.'))
                        ]
      end

      def self.is_supported?(platform)
         [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
