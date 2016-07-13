require 'rails'

RSpec.configure do |c|
  c.before do
    allow(Rails).to receive(:root) { File.expand_path( '../files', __FILE__ ) }
    allow(Rails).to receive(:env) { 'test' }
  end
end
