module AbPanel
  class Javascript
    def self.environment
      props = { distinct_id: AbPanel.env["ab_panel_id"] }
      AbPanel.experiments.each { |exp| props[exp] = AbPanel.conditions.send(exp).condition }
      props.to_json
    end
  end
end
