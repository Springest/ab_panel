require 'spec_helper'

describe AbPanel::Config do
  let(:config) { AbPanel::Config.new }
  context "config" do
    before do
      AbPanel::Config.any_instance.stub(:settings) { { exp1: { scenario1: 25, scenario2: 75 } } }
    end

    describe '.experiments' do
      subject { config.experiments }
      it { should =~ [:exp1] }
    end

    describe '.weights' do
      subject { config.weights('exp1') }

      it { should =~ [75.0, 25.0] }
    end
  end
  context "empty config" do
    before do
      YAML.stub(:load) { false }
    end
    describe ".settings" do
      subject { config.settings }
      it { should eq nil }
    end
  end
end
