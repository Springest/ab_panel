require 'spec_helper'

describe AbPanel do
  describe ".tests" do
    subject { AbPanel.tests }

    it { should =~ %w(test1 test2).map(&:to_sym) }
  end

  describe ".scenarios" do
    subject { AbPanel.scenarios(test) }

    let(:test) { AbPanel.tests.first }

    it { should =~ %w( scenario1 scenario2 scenario3 original ) }

    describe "With an unexisting test" do
      let(:test) { :does_not_exist }

      it 'should throw an ArgumentError' do
        expect { subject }.to raise_exception ArgumentError
      end
    end
  end
end
