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
    content << ChartCandy.localize(start_at, format: start_at_format)
    content << (['month', 'year'].include?(options[:step]) ? ChartCandy.t('date.period.to_month') : ChartCandy.t('date.period.to'))
    content << ChartCandy.localize(end_at, format: end_at_format)

    content[0].capitalize!

    return content.join(' ')
  end

  def self.get_step_from_interval(interval)
    days = (interval / (3600 * 24)).to_i.abs

    return case days
      when 0..5 then 'day'
      when 6..27 then 'week'
      when 28..88 then 'month'
      when 89..363 then 'quarter'
      else 'year'
    end
  end
end

require 'chart-candy/builder/base.rb'
require 'chart-candy/builder/counter.rb'
require 'chart-candy/builder/donut.rb'
require 'chart-candy/builder/line.rb'
require 'chart-candy/builder/xls_builder.rb'
