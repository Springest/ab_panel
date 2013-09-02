require 'ostruct'

module AbPanel
  class Config
    def initialize
      OpenStruct.new settings
    end

    def experiments
      settings.keys.map(&:to_sym)
    end

    def scenarios(experiment)
      raise ArgumentError.new( "Fatal: Experiment config not found for #{experiment}" ) unless experiments.include? experiment.to_sym
      ( settings[experiment.to_sym].map(&:to_sym) + [:original] ).uniq
    end


    def settings
      @settings ||= YAML.load(
        ERB.new(File.read(File.join(Rails.root, 'config', 'ab_panel.yml'))).result)
        .symbolize_keys
    end
  end
end
