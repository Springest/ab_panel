require 'rails'

RSpec.configure do |c|
  c.before do
    Rails.stub(:root) { File.expand_path( '../../../', __FILE__ ) }
    Rails.stub(:env) { 'test' }
  end
end
