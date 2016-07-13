require 'spec_helper'

describe Array do
  describe '.weighted_sample' do
    before do
      allow(Kernel).to receive(:rand) { 0.5 }
    end

    context "Stub test" do
      subject { Kernel.rand }
      it { is_expected.to eq 0.5 }
    end

    let(:array) { [1, 2, 3, 4] }
    subject { array.weighted_sample }

    it { is_expected.to eq 3 }

    context "different random" do
      before do
        allow(Kernel).to receive(:rand) { 0 }
      end

      it { is_expected.to eq 1 }
    end

    context "different random" do
      before do
        allow(Kernel).to receive(:rand) { 1 }
      end

      it { is_expected.to eq 4 }
    end

    context "with weights" do
      subject { array.weighted_sample([1, 0, 0, 0]) }
      it { is_expected.to eq 1 }
    end

    context "all the same weights" do
      before { allow(Kernel).to receive(:rand) { 1 } }
      subject { array.weighted_sample([0, 0, 0, 0]) }
      it { is_expected.to eq 4 }
      context "random 0" do
        before { allow(Kernel).to receive(:rand) { 0 } }
        it { is_expected.to eq 1 }
      end
    end
  end
end
