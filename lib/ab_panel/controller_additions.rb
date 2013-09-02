module AbPanel
  module ControllerAdditions
    extend ActiveSupport::Concern

    # This sets a unique id for this user.
    #
    # You could override this in your ApplicationController to use your
    # own implementation, e.g.:
    #
    #   `current_user.id` for logged in users.
    def ab_panel_id
      session[:ab_panel_id] ||=
        (0..4).map { |i| i.even? ? ('A'..'Z').to_a[rand(26)] : rand(10) }.join
    end

    # Sets the environment hash for every request.
    #
    # Experiment conditions and unique user id are preserved
    # in the user's session.
    #
    # You could override this to match your own env.
    def ab_panel_env
      {
        'REMOTE_ADDR'          => request['REMOTE_ADDR'],
        'HTTP_X_FORWARDED_FOR' => request['HTTP_X_FORWARDED_FOR'],
        'rack.session'         => request['rack.session'],
        'rails.env'            => Rails.env
      }
    end

    module ClassMethods
      # Initializes AbPanel's environment.
      #
      # Typically, this would go in the ApplicationController.
      #
      #   class ApplicationController < ActionController::Base
      #     initialize_ab_panel!
      #   end
      #
      # This makes sure an ab_panel session is re-initialized on every
      # request. Experiment conditions and unique user id are preserved
      # in the user's session.
      def initialize_ab_panel!
        self.before_filter(options.slice(:only, :except)) do |controller|
          # Persist the conditions.
          AbPanel.conditions = controller.session['ab_panel_conditions']

          {
            'mixpanel_events' => controller.request['mixpanel_events'],
            'ab_panel_id'     => controller.ab_panel_id
          }.merge(controller.ab_panel_env).each do |key, val|
            AbPanel.env_set key, val
          end
        end
      end

      # Track controller actions visits.
      #
      # name       - The name of the event in Mixpanel.
      # properties - The properties to be associated with the event.
      #
      # Example:
      #
      #   track_action '[visits] Booking form', { :only => :book_now,  :hotel => :id }
      #
      # This will track the event with the given name on Controller#book_now
      # and assign an options hash:
      #
      #   { 'hotel_id' => @hotel.id }
      def track_visit(name, properties={})
        self.after_filter(options.slice(:only, :except)) do |controller|
          options = {}

          properties.each do |key, val|
            if controller.respond_to?(key)
              inst = controller.send(key)
            elsif controller.instance_variable_defined?("@#{key}")
              inst = controller.instance_variable_get("@#{key}")
            else
              options[key] = val
              next
            end

            val = *val

            val.each do |m|
              options["#{key}_#{m}"] = inst.send(m)
            end
          end
        end

        AbPanel.track name, options
      end
    end
  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include AbPanel::ControllerAdditions
  end
end
