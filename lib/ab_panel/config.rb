require 'ostruct'

module AbPanel
  class Config
    def initialize
      OpenStruct.new settings
    end

    def experiments
      return {} if !settings
      settings.keys.map(&:to_sym)
    end

    def scenarios(experiment)
      raise ArgumentError.new( "Fatal: Experiment config not found for #{experiment}" ) unless experiments.include? experiment.to_sym
      ( settings[experiment.to_sym].keys.map(&:to_sym)).uniq
    end

    def weights(experiment)
      raise ArgumentError.new( "Fatal: Experiment config not found for #{experiment}" ) unless experiments.include? experiment.to_sym
      settings[experiment.to_sym].map { |s| s[1] }
    end

    def settings
      return @settings if defined?(@settings)
      results = YAML.load(ERB.new(File.read(File.join(Rails.root, 'config', 'ab_panel.yml'))).result)
      @settings = results ? results.symbolize_keys : nil
    end
  end
end
