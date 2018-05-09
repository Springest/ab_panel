require 'spec_helper'

class Controller
  include AbPanel::ControllerAdditions

  def session
    @session ||= {}
  end
end

describe AbPanel::ControllerAdditions do
  let(:controller) { Controller.new }

  describe "#distinct_id" do
    let(:cookies) { {} }
    before do
      allow(controller).to receive_message_chain(:request, :ssl?).and_return(true)
      allow(controller).to receive_message_chain(:cookies, :signed).and_return(cookies)
    end
    subject { controller.distinct_id }

    it { is_expected.to match /^([A-Z]|[0-9])([A-Z]|[0-9])([A-Z]|[0-9])([A-Z]|[0-9])([A-Z]|[0-9])$/ }
  end
end
