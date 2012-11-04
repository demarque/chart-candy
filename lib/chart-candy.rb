module ChartCandy
  def self.localize(path, options={})
    options.reverse_merge! format: :date_long

    options[:format] = "chart_candy_#{options[:format]}".to_sym

    return I18n.localize(path, options)
  end

  def self.translate(path, options={})
    I18n.translate("chart_candy.#{path}", options)
  end

  def self.t(path, options={})
    self.translate path, options
  end
end

require "chart-candy/authentication"
require "chart-candy/base_chart"
require "chart-candy/builder"
require "chart-candy/engine"
require 'chart-candy/implants'
