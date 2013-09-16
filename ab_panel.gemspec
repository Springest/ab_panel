# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ab_panel/version'

Gem::Specification.new do |spec|
  spec.name          = "ab_panel"
  spec.version       = AbPanel::VERSION
  spec.authors       = ["Wouter de Vos"]
  spec.email         = ["wouter@springest.com"]
  spec.description   = %q{Run A/B test experiments on your Rails 3+ site using Mixpanel as a backend.}
  spec.summary       = %q{Run A/B test experiments on your Rails 3+ site using Mixpanel as a backend.}
  spec.homepage      = "https://github.com/Springest/ab_panel"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features|example)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rails", '~> 3.2'
  spec.add_development_dependency "rake"
  spec.add_development_dependency "fakeweb"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "debugger"

  spec.add_runtime_dependency "mixpanel"
end
