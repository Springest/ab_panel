puts "Ab Panel."

Dir[File.expand_path(File.join(
  File.dirname(__FILE__),'ab_panel','**','*.rb'))]
    .each {|f| require f}

module AbPanel
  class << self
    def conditions
      @conditions ||= assign_conditions!
    end

    def tests
      config.tests
    end

    def scenarios(test)
      config.scenarios test
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

    def config
      @config ||= Config.new
    end
  end
end
