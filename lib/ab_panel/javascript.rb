module AbPanel
  class Javascript
    def self.environment
      props = { distinct_id: AbPanel.env["distinct_id"] }

      AbPanel.funnels.each { |f| props["funnel_#{f}"] = true }

      AbPanel.experiments.each { |exp| props[exp] = AbPanel.conditions.send(exp).condition }
      props.to_json
    end
  end
end
