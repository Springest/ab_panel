require 'spec_helper'
require 'timecop'

class Controller
  include AbPanel::ControllerAdditions

  def session
    @session ||= {}
  end
end

describe AbPanel::ControllerAdditions do
  let(:controller) { Controller.new }
  before do
    request = double('request', original_url: 'http://www.foo.bar', remote_ip: '127.0.0.1')
    controller.stub(:request).and_return request
  end

  describe "#distinct_id" do
    let(:cookies) { {} }
    before { controller.stub_chain(:cookies, :signed).and_return(cookies) }
    subject { controller.distinct_id }

    it { should match /^([A-Z]|[0-9])([A-Z]|[0-9])([A-Z]|[0-9])([A-Z]|[0-9])([A-Z]|[0-9])$/ }
  end

  describe "#track_actions" do
    let(:cookies) { {} }
    before do
      controller.stub_chain(:cookies, :signed).and_return(cookies)
      controller.stub(:distinct_id) { "123AB" }
      AbPanel.stub(:experiments) { [] }
      Timecop.freeze(Time.local(2014))
    end

    after do
      Timecop.return
    end

    it "should add the URL to the tracking." do
      AbPanel.should_receive(:track).with({:name=>"Foo"},
                                          {:distinct_id=>"123AB",
                                           :ip => "127.0.0.1",
                                           :time => Time.now.utc,
                                           :url => "http://www.foo.bar"
                                          })
      controller.track_action(name: 'Foo')
    end
  end
end
