require 'fastlane/action'
require_relative '../helper/download_hocky_build_helper'

module Fastlane
  module Actions
    class DownloadHockyBuildAction < Action
      def self.run(params)
        UI.message("The download_hocky_build plugin is working!")
      end

      def self.description
        "Helps to download build from HockeyApp"
      end

      def self.authors
        ["Anton Morozov"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Helps to download build from HockeyApp Helps to download build from HockeyApp (iOS and Android)"
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "DOWNLOAD_HOCKY_BUILD_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
