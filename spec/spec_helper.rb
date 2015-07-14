require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'simplecov'
SimpleCov.start do
  add_filter 'spec/dummy'
  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
  add_group 'Helpers', 'app/helpers'
  add_group 'Libraries', 'lib'
end

ENV['RAILS_ENV'] = 'test'
require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rspec/rails'
require 'ffaker'
require 'byebug'
require 'spree/testing_support/factories'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec
  config.color = true
  config.use_transactional_fixtures = true
  config.fail_fast = ENV['FAIL_FAST'] || false
  config.order = "random"
end
