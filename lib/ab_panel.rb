puts "Ab Panel."

Dir[File.expand_path(File.join(
  File.dirname(__FILE__),'ab_panel','**','*.rb'))]
    .each {|f| require f}

module AbPanel
  class << self

    # Track event in Mixpanel backend.
    def track(event_name, properties, options={})
      tracker.track event_name, properties, options
    end

    def conditions
      @conditions ||= assign_conditions!
    end

    # Set the experiment's conditions.
    #
    # This is used to persist conditions from
    # the session.
    def conditions=(custom_conditions)
      @conditions = custom_conditions || conditions
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
        'conditions'           => conditions
      }
    end

    private # ----------------------------------------------------------------------------

    def assign_conditions!
      cs = {}

      experiments.each do |experiment|
        cs[experiment] ||= {}

        scenarios(experiment).each do |scenario|
          cs[experiment]["#{scenario}?"] = false
        end

        selected = scenarios(experiment)[rand(scenarios(experiment).size)]

        cs[experiment]["#{selected}?"] = true

        cs[experiment][:condition] = selected

        cs[experiment] = OpenStruct.new cs[experiment]
      end

      OpenStruct.new cs
    end

    def tracker
      @tracker ||= Mixpanel::Tracker.new
    end

    def config
      @config ||= Config.new
    end
  end
end
