require "rubygems"
require "bundler/setup"

require 'rspec'
require 'rails'

require File.expand_path('../../lib/chart-candy', __FILE__)

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
end
