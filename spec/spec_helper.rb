puts "Spec Helper."
require 'rubygems'
require 'active_support/all'

require File.join(File.dirname(__FILE__), "../lib", "ab_panel")

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}
