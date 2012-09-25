module ChartCandy::Builder
  def self.period(start_at, end_at, options={})
    options.reverse_merge!(step: 'day')

    start_at_format = case
      when options[:step] == 'month' then :date_without_day
      when options[:step] == 'year' then :year
      when start_at.year != end_at.year then :date_long
      when start_at.month != end_at.month then :date_long_without_year
      else :day
    end

    end_at_format = case options[:step]
      when 'month' then :date_without_day
      when 'year' then :year
      else :date_long
    end

    content = []
    content << I18n.localize(start_at, format: start_at_format)
    content << (['month', 'year'].include?(options[:step]) ? I18n.t('date.period.to_month') : I18n.t('date.period.to'))
    content << I18n.localize(end_at, format: end_at_format)

    content[0].capitalize!

    return content.join(' ')
  end
end

require 'chart-candy/builder/base.rb'
require 'chart-candy/builder/counter.rb'
require 'chart-candy/builder/donut.rb'
require 'chart-candy/builder/line.rb'
require 'chart-candy/builder/xls_builder.rb'
