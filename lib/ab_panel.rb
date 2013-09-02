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

    def tests
      config.tests
    end

    def scenarios(test)
      config.scenarios test
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

      tests.each do |test|
        cs[test] ||= {}

        scenarios(test).each do |scenario|
          cs[test]["#{scenario}?"] = false
        end

        selected = scenarios(test)[rand(scenarios(test).size)]

        cs[test]["#{selected}?"] = true

        cs[test] = OpenStruct.new cs[test]
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
