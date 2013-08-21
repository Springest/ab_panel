puts "Ab Panel::ControllerAdditions."

module AbPanel
  module ControllerAdditions
    extend ActiveSupport::Concern

    def ab_panel_id
      session[:ab_panel_id] ||=
        (0..4).map { |i| i.even? ? ('A'..'Z').to_a[rand(26)] : rand(10) }.join
    end
  end
end
