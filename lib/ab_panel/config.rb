require 'ostruct'

module AbPanel
  class Config
    def initialize
      OpenStruct.new settings
    end

    def tests
      settings.keys.map(&:to_sym)
    end

    def scenarios(test)
      raise ArgumentError.new( "Fatal: Test config not found for #{test}" ) unless tests.include? test.to_sym
      ( settings[test.to_sym].map(&:to_sym) + [:original] ).uniq
    end


    def settings
      @settings ||= YAML.load(
        ERB.new(File.read(File.join(Rails.root, 'config', 'ab_panel.yml'))).result)
        .symbolize_keys
    end
  end
end
