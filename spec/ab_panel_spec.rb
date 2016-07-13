require 'spec_helper'

describe AbPanel do
  describe ".experiments" do
    subject { AbPanel.experiments }

    it { is_expected.to match_array %w(experiment1 experiment2).map(&:to_sym) }
  end

  describe ".weights" do
    let(:experiment) { AbPanel.experiments.first }
    subject { AbPanel.weights(experiment) }

    it { is_expected.to eq [25, 25, 25, 25] }

    describe "With a nonexistent experiment" do
      let(:experiment) { :does_not_exist }

      it 'should throw an ArgumentError' do
        expect { subject }.to raise_exception ArgumentError
      end
    end
  end

  describe ".scenarios" do
    subject { AbPanel.scenarios(experiment) }

    let(:experiment) { AbPanel.experiments.first }

    it { is_expected.to match_array %w( scenario1 scenario2 scenario3 original ).map(&:to_sym) }

    describe "With an nonexistent experiment" do
      let(:experiment) { :does_not_exist }

      it 'should throw an ArgumentError' do
        expect { subject }.to raise_exception ArgumentError
      end
    end
  end

  describe ".conditions" do
    subject { AbPanel.conditions.experiment1 }

    it { is_expected.to respond_to :scenario1? }
    it { is_expected.to respond_to :original? }

    describe 'uniqueness' do
      let(:conditions) do
        [
          subject.scenario1?,
          subject.scenario2?,
          subject.scenario3?,
          subject.original?
        ]
      end

      it { expect(conditions.any?).to be true }
      it { expect(conditions.all?).to be false }
      it { expect(conditions.select{|c| c}.size).to be 1 }
      it { expect(conditions.reject{|c| c}.size).to be 3 }
    end
  end

  describe ".funnels" do
    before do
      AbPanel.reset!
    end

    after do
      AbPanel.funnels = nil
    end

    it 'adds a funnel' do
      AbPanel.add_funnel('search')
      expect(AbPanel.funnels.to_a).to eq ['search']
    end

    it 'only adds a funnel when present' do
      AbPanel.add_funnel(nil)
      expect(AbPanel.funnels.to_a).to eq []
    end

    it 'does not add a funnel twice' do
      AbPanel.add_funnel('search')
      AbPanel.add_funnel('search')
      expect(AbPanel.funnels.to_a).to eq ['search']
    end

    it 'sets funnels' do
      funnels = Set.new ['search', 'cta']
      AbPanel.funnels = funnels
      expect(AbPanel.funnels.to_a).to eq funnels.to_a
    end
  end

  describe 'thread-safety' do
    it 'should set be safe' do
      AbPanel.set_env(:test, 'a')
      Thread.new { AbPanel.set_env(:test, 'b') }.join
      expect(AbPanel.env[:test]).to eq 'a'
    end
  end
end
