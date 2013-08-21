puts "Ab Panel."

Dir[File.expand_path(File.join(
  File.dirname(__FILE__),'ab_panel','**','*.rb'))]
    .each {|f| require f}

module AbPanel
  class << self
    def tests
      config.tests
    end

    def scenarios(test)
      config.scenarios test
    end

    private # ----------------------------------------------------------------------------

    def config
      @config ||= Config.new
    end
  end
end
