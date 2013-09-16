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
    def identify(ab_panel_id)
      tracker.identify ab_panel_id
    end

    def conditions
      @conditions ||= assign_conditions!
    end

    # Set the experiment's conditions.
    #
    # This is used to persist conditions from
    # the session.
    def conditions=(custom_conditions)
      return conditions unless custom_conditions
      @conditions = assign_conditions! custom_conditions
    end

    def experiments
      config.experiments
    end

    def scenarios(experiment)
      config.scenarios experiment
    end

    def env_set key, val
      env[key] = val
    end

    def env
      @env ||= {
        'conditions' => conditions
      }
    end

    private # ----------------------------------------------------------------------------

    def assign_conditions!(already_assigned=nil)
      cs = {}

      experiments.each do |experiment|
        cs[experiment] ||= {}

        scenarios(experiment).each do |scenario|
          cs[experiment]["#{scenario}?"] = false
        end

        selected = begin
          already_assigned.send(experiment).condition
        rescue
          scenarios(experiment)[rand(scenarios(experiment).size)]
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
