module ChartCandy::Implants
  class Railtie < Rails::Railtie
    initializer "chart-candy" do |app|
      ActiveSupport.on_load :action_view do
        require 'chart-candy/helpers'
      end

      Mime::Type.register "application/vnd.ms-excel", :xls if not Mime::Type.lookup_by_extension :xls
    end
  end
end

dir = File.expand_path(File.dirname(__FILE__))

I18n.load_path << File.join(dir, '../../../config/locales', 'fr.yml')


