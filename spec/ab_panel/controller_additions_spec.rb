require 'spec_helper'

class Controller
  include AbPanel::ControllerAdditions

  def session
    @session ||= {}
  end
end

describe AbPanel::ControllerAdditions do
  let(:controller) { Controller.new }

  describe "#ab_panel_id" do
    subject { controller.ab_panel_id }

    it { should match /^([A-Z]|[0-9])([A-Z]|[0-9])([A-Z]|[0-9])([A-Z]|[0-9])([A-Z]|[0-9])$/ }
  end
end
