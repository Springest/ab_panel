module AbPanel
  class Javascript
    def self.environment
      self.environment_hash.to_json
    end

    def self.environment_hash
      props = { distinct_id: AbPanel.env["distinct_id"] }
      props.merge!(AbPanel.properties) if AbPanel.properties

      AbPanel.funnels.each { |f| props["funnel_#{f}"] = true }

      AbPanel.experiments.each { |exp| props[exp] = AbPanel.conditions.send(exp).condition }

      props
    end
  end
end
