require 'spec_helper'

describe AbPanel do
  describe ".experiments" do
    subject { AbPanel.experiments }

    it { should =~ %w(experiment1 experiment2).map(&:to_sym) }
  end

  describe ".weights" do
    let(:experiment) { AbPanel.experiments.first }
    subject { AbPanel.weights(experiment) }

    it { should == [25, 25, 25, 25] }

    describe "With an unexisting experiment" do
      let(:experiment) { :does_not_exist }

      it 'should throw an ArgumentError' do
        expect { subject }.to raise_exception ArgumentError
      end
    end
  end

  describe ".scenarios" do
    subject { AbPanel.scenarios(experiment) }

    let(:experiment) { AbPanel.experiments.first }

    it { should =~ %w( scenario1 scenario2 scenario3 original ).map(&:to_sym) }

    describe "With an unexisting experiment" do
      let(:experiment) { :does_not_exist }

      it 'should throw an ArgumentError' do
        expect { subject }.to raise_exception ArgumentError
      end
    end
  end

  describe ".conditions" do
    subject { AbPanel.conditions.experiment1 }

    it { should respond_to :scenario1? }
    it { should respond_to :original? }

    describe 'uniqueness' do
      let(:conditions) do
        [
          subject.scenario1?,
          subject.scenario2?,
          subject.scenario3?,
          subject.original?
        ]
      end

      it { conditions.any?.should be true }
      it { conditions.all?.should be false }
      it { conditions.select{|c| c}.size.should be 1 }
      it { conditions.reject{|c| c}.size.should be 3 }
    end
  end

  describe ".funnels" do
    after do
      AbPanel.funnels = nil
    end

    it 'adds a funnel' do
      AbPanel.add_funnel('search')
      AbPanel.funnels.to_a.should == ['search']
    end

    it 'only adds a funnel when present' do
      AbPanel.add_funnel(nil)
      AbPanel.funnels.to_a.should == []
    end

    it 'does not add a funnel twice' do
      AbPanel.add_funnel('search')
      AbPanel.add_funnel('search')
      AbPanel.funnels.to_a.should == ['search']
    end

    it 'sets funnels' do
      funnels = Set.new ['search', 'cta']
      AbPanel.funnels = funnels
      AbPanel.funnels.to_a.should == funnels.to_a
    end
  end
end
