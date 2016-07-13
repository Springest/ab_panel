require 'set'
require_relative './array'

Dir[File.expand_path(File.join(
  File.dirname(__FILE__),'ab_panel','**','*.rb'))]
    .each {|f| require f}

module AbPanel
  class << self

    # Track event in Mixpanel backend.
    def track(event_name, properties)
      tracker.track event_name, properties
    end

    # Identify
    def identify(distinct_id)
      tracker.identify distinct_id
    end

    def conditions
      Thread.current[:ab_panel_conditions] ||= assign_conditions!
    end

    def serialized_conditions
      cs = {}

      conditions.each_pair do |key, value|
        cs[key] = value.marshal_dump
      end

      cs.to_json
    end

    # Set the experiment's conditions.
    #
    # This is used to persist conditions from
    # the session.
    def conditions=(custom_conditions)
      return conditions unless custom_conditions
      Thread.current[:ab_panel_conditions] = assign_conditions! custom_conditions
    end

    def experiments
      config.experiments
    end

    def scenarios(experiment)
      config.scenarios experiment
    end

    def weights(experiment)
      config.weights experiment
    end

    def properties
      env[:properties]
    end

    def env
      Thread.current[:ab_panel_env] ||= {
        'conditions' => conditions
      }
    end

    def reset!
      Thread.current[:ab_panel_env] = nil
      Thread.current[:ab_panel_conditions] = nil
    end

    def set_env(key, value)
      env[key] = value
    end

    def funnels
      env[:funnels] ||= Set.new
    end

    def funnels=(funnels)
      env[:funnels] = funnels
    end

    def add_funnel(funnel)
      funnels.add(funnel) if funnel.present?
    end

    private # ----------------------------------------------------------------------------

    def assign_conditions!(already_assigned=nil)
      cs = {}

      if already_assigned
        already_assigned.each do |key, value|
          already_assigned[key] = OpenStruct.new(already_assigned[key])
        end
      end

      already_assigned = OpenStruct.new already_assigned

      experiments.each do |experiment|
        cs[experiment] ||= {}

        scenarios(experiment).each do |scenario|
          cs[experiment]["#{scenario}?"] = false
        end

        selected = begin
          already_assigned.send(experiment).condition
        rescue
          scenarios(experiment).weighted_sample(weights(experiment))
        end

        cs[experiment]["#{selected}?"] = true

        cs[experiment][:condition] = selected

        cs[experiment] = OpenStruct.new cs[experiment]
      end

      OpenStruct.new cs
    end

    def tracker
      Mixpanel::Tracker.new
    end

    def config
      @config ||= Config.new
    end
  end
end
