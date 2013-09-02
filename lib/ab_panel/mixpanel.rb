require 'mixpanel'

module AbPanel
  module Mixpanel
    class Tracker < ::Mixpanel::Tracker
      def initialize(options={})
        @tracker = ::Mixpanel::Tracker.new Config.token, ab_panel_options.merge(options)
      end

      def ab_panel_options
        {
          api_key: Config.api_key,
          env:     AbPanel.env
        }
      end

      def track(event_name, properties, options={})
        @tracker.track event_name, properties, options
      end
    end

    class Config
      def self.api_key
        config['api_key']
      end

      def self.token
        config['token']
      end

      def self.config
        @settings ||= YAML.load(
          ERB.new(File.read(File.join(Rails.root, 'config', 'mixpanel.yml'))).result)
      end
    end
  end
end
