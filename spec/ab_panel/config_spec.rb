require 'spec_helper'

describe AbPanel::Config do
  let(:config) { AbPanel::Config.new }
  before do
    AbPanel::Config.any_instance.stub(:settings) { { exp1: { scenario1: 25, scenario2: 75 } } }
  end

  describe '.experiments' do
    subject { config.experiments }
    it { should =~ [:exp1] }
  end

  describe '.total_weight' do
    subject { config.total_weight('exp1') }

    it { should eq 100 }
  end

  describe '.weights' do
    subject { config.weights('exp1') }

    it { should =~ [75.0, 25.0] }

    context "less then 100%" do
      before { config.stub(:settings) { { exp1: { scenario1: 25, scenario2: 74 } } } }

      it "should throw an error" do
        expect{ subject }.to raise_error
      end
    end

    context "less then 100%" do
      before { config.stub(:settings) { { exp1: { scenario1: 25, scenario2: 76 } } } }

      it "should throw an error" do
        expect{ subject }.to raise_error
      end
    end
  end
end
