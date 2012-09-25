#require 'chart-candy/helpers'

module ChartCandy::Implants
  class Railtie < Rails::Railtie
    initializer "chart-candy" do |app|
      ActiveSupport.on_load :action_view do
        require 'chart-candy/helpers'
      end
    end
  end
end
