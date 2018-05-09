module AbPanel
  module ControllerAdditions
    extend ActiveSupport::Concern

    # Track a single variable
    #
    # Example:
    #  track_variable :name, value
    def track_variable(name, value)
      ab_panel_options[name.to_sym] = value
    end

    # Track multiple variables at once.
    #
    # Example:
    #  track_variables { foo: 'bar', ping: 'pong'}
    def track_variables(variables={})
      variables.each do |key, val|
        track_variable key, val
      end
    end

    # This sets a unique id for this user.
    #
    # You could override this in your ApplicationController to use your
    # own implementation, e.g.:
    #
    #   `current_user.id` for logged in users.
    def distinct_id
      distinct_id = cookies.signed['distinct_id']

      return distinct_id if distinct_id

      distinct_id = (0..4).map { |i| i.even? ? ('A'..'Z').to_a[rand(26)] : rand(10) }.join

      cookies.signed['distinct_id'] =
        {
          value: distinct_id,
          httponly: true,
          secure: request.ssl?
        }

      distinct_id
    end

    def ab_panel_options
      @ab_panel_options ||= {}
    end

    # Initializes AbPanel's environment.
    #
    # Typically, this would go in a global before filter.
    #
    #   class ApplicationController < ActionController::Base
    #     before_filter :initialize_ab_panel!
    #   end
    #
    # This makes sure an ab_panel session is re-initialized on every
    # request. Experiment conditions and unique user id are preserved
    # in the user's session.
    def initialize_ab_panel!(options = {})
      AbPanel.reset!


      AbPanel.conditions =
        if cookies.signed[:ab_panel_conditions]
          JSON.parse(cookies.signed[:ab_panel_conditions])
        else
          nil
        end

      cookies.signed[:ab_panel_conditions] = {
        value: AbPanel.serialized_conditions,
        httponly: true,
        secure: request.ssl?
      }

      AbPanel.funnels = Set.new(cookies.signed[:ab_panel_funnels])
      cookies.signed[:ab_panel_funnels] = {
        value: AbPanel.funnels,
        httponly: true,
        secure: request.ssl?
      }

      {
        'distinct_id' => distinct_id,
        'rack.session' => request.env['rack.session'],
        'ip' => request.remote_ip
      }.each do |key, value|
        AbPanel.set_env(key, value)
      end
    end

    # Track controller actions visits.
    #
    # name       - The name of the event in Mixpanel.
    # properties - The properties to be associated with the event.
    #
    # Example:
    #
    #   def show
    #     track_action '[visits] Course', { :course_id => @course.id }
    #   end
    #
    # This will track the event with the given name on CoursesController#show
    # with the passed in attributes.
    def track_action(name, properties = {})
      AbPanel.add_funnel(properties.delete(:funnel))

      options = {
        distinct_id: distinct_id,
        time:        Time.now.utc,
      }.merge(properties)

      AbPanel.funnels.each do |funnel|
        options["funnel_#{funnel}"] = true
      end

      AbPanel.experiments.each do |exp|
        options[exp] = AbPanel.conditions.send(exp).condition rescue nil
      end

      options.merge!(ab_panel_options)
      AbPanel.set_env(:properties, options)

      AbPanel.identify(distinct_id)
      AbPanel.track(name, options.merge(ab_panel_options))
    end
  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include AbPanel::ControllerAdditions
  end
end
