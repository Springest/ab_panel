require 'mixpanel'

module AbPanel
  module Mixpanel
    class Tracker < ::Mixpanel::Tracker
      def initialize(options = {})
        return if !should_track?

        @tracker = ::Mixpanel::Tracker.new Config.token, ab_panel_options.merge(options)
      end

      def ab_panel_options
        opts = {
          env:     AbPanel.env,
          persist: true
        }

        AbPanel.funnels.each do |funnel|
          opts["funnel_#{funnel}"] = true
        end

        opts
      end

      def track(event_name, properties)
        return if !should_track?

        @tracker.append_track event_name, properties
      end

      def identify(distinct_id)
        return if !should_track?

        @tracker.append_identify distinct_id
      end

      private

      def should_track?
        @should_track ||= Config.environments.include?(Rails.env)
      end
    end

    class Config
      def self.token
        config[Rails.env]['token']
      end

      def self.environments
        config.keys
      end

      def self.config
        @settings ||= load_config
      end

      private

      def self.load_config
        file = File.read(File.join(Rails.root, 'config', 'mixpanel.yml'))
        YAML.load(file)
      end
    end
  end
end
