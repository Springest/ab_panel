require 'spec_helper'

describe AbPanel::Config do
  let(:config) { AbPanel::Config.new }
  context "config" do
    before do
      allow_any_instance_of(AbPanel::Config).to receive(:settings) { { exp1: { scenario1: 25, scenario2: 75 } } }
    end

    describe '.experiments' do
      subject { config.experiments }
      it { is_expected.to match_array [:exp1] }
    end

    describe '.weights' do
      subject { config.weights('exp1') }

      it { is_expected.to match_array [75.0, 25.0] }
    end
  end
  context "empty config" do
    before do
      allow(YAML).to receive(:load) { false }
    end
    describe ".settings" do
      subject { config.settings }
      it { is_expected.to eq nil }
    end

    describe ".experiments" do
      subject { config.experiments }
      it { is_expected.to eq({}) }
    end
  end
end
