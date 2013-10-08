class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :initialize_ab_panel!

  after_filter :ab_env_logger

  def ab_env_logger
    Rails.logger.info "Start AB Panel Log output ====================="
    Rails.logger.info session
    Rails.logger.info AbPanel.env
    Rails.logger.info "End of AB Panel Log output ===================="
  end
end
