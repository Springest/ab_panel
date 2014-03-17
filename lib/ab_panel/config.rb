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
      ( settings[experiment.to_sym].keys.map(&:to_sym)).uniq
    end

    def total_weight(experiment)
      settings[experiment.to_sym].sum { |s| s[1].to_f }.round(1)
    end

    def weights(experiment)
      raise ArgumentError.new( "Fatal: Experiment config not found for #{experiment}" ) unless experiments.include? experiment.to_sym
      raise "Total experiment probability exceeds 100%, please check the config for #{experiment}" if total_weight(experiment) > 100.0
      raise "Total experiment probability is less than 100%, please check the config for #{experiment}" if total_weight(experiment) < 100.0
      settings[experiment.to_sym].map { |s| s[1] }
    end

    def settings
      @settings ||= YAML.load(
        ERB.new(File.read(File.join(Rails.root, 'config', 'ab_panel.yml'))).result)
        .symbolize_keys
    end
  end
end
