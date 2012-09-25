module ChartCandy
  module Implants
  end
end

if defined? Rails::Railtie
  require 'chart-candy/implants/railtie'
elsif defined? Rails::Initializer
  raise "chart-candy is not compatible with Rails 2.3 or older"
end
