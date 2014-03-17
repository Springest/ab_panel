require 'spec_helper'

describe Array do
  describe '.weighted_sample' do
    before do
      Kernel.stub(:rand) { 0.5 }
    end

    context "Stub test" do
      subject { Kernel.rand }
      it { should eq 0.5 }
    end

    let(:array) { [1, 2, 3, 4] }
    subject { array.weighted_sample }

    it { should eq 3 }

    context "different random" do
      before do
        Kernel.stub(:rand) { 0 }
      end

      it { should eq 1 }
    end

    context "different random" do
      before do
        Kernel.stub(:rand) { 1 }
      end

      it { should eq 4 }
    end

    context "with weights" do
      subject { array.weighted_sample([1, 0, 0, 0]) }
      it { should eq 1 }
    end
    
    context "all the same weights" do
      before { Kernel.stub(:rand) { 1 } }
      subject { array.weighted_sample([0, 0, 0, 0]) }
      it { should eq 4 }
    end
  end
end
