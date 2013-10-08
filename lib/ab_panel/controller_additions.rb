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
      session['distinct_id'] ||=
        (0..4).map { |i| i.even? ? ('A'..'Z').to_a[rand(26)] : rand(10) }.join
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
      AbPanel.conditions = session['ab_panel_conditions']
      session['ab_panel_conditions'] = AbPanel.conditions

      {
        'distinct_id' => distinct_id,
        'rack.session' => request['rack.session'],
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
    #     track_action '[visits] Course', { :course => :id }
    #   end
    #
    # This will track the event with the given name on CoursesController#show
    # and assign an options hash:
    #
    #   { 'course_id' => @course.id }
    def track_action(name, properties = {})
      funnel = properties.delete(:funnel)
      AbPanel.funnels << funnel if funnel.present?

      options = {
        distinct_id: distinct_id,
        ip:          request.remote_ip,
        time:        Time.now.utc,
      }

      AbPanel.funnels.each do |funnel|
        options["funnel_#{funnel}"] = true
      end

      AbPanel.experiments.each do |exp|
        options[exp] = AbPanel.conditions.send(exp).condition rescue nil
      end

      properties.each do |key, val|
        if respond_to?(key)
          inst = send(key)
        elsif instance_variable_defined?("@#{key}")
          inst = instance_variable_get("@#{key}")
        else
          options[key] = val
          next
        end

        val = *val

        val.each do |m|
          options["#{key}_#{m}"] = inst.send(m)
        end
      end

      AbPanel.identify(distinct_id)
      AbPanel.track(name, options.merge(ab_panel_options))

      session['mixpanel_events'] ||= AbPanel.env['rack.session']['mixpanel_events'] rescue []
    end
  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include AbPanel::ControllerAdditions
  end
end
