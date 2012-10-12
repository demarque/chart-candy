class ChartCandy::Builder::Base
  def initialize(id, options={})
    options.reverse_merge! from: nil, to: nil, step: nil

    @from = options[:from] ? Time.parse(options[:from]) : nil
    @to = options[:to] ? Time.parse(options[:to]) : Time.now

    @chart = { id: id }
    @chart[:step] = options[:step] if options[:step]
    @chart[:title] = t('title')
    @chart[:period] = ChartCandy::Builder.period(@from, @to, step: @chart[:step]) if @from
  end

  def close_chart
    # Hooks before closing a chart
  end

  def filename
    name = [title.parameterize]
    name << @from.strftime('%Y%m%d') if @from
    name << @to.strftime('%Y%m%d') if @to

    return name.compact.join('-')
  end

  def id
    @chart[:id]
  end

  def l(date, options={})
    options.reverse_merge!(format: :date_long)

    return I18n.localize(date, options)
  end

  def period
    @chart[:period]
  end

  def set_period_from_data(data)
    @from = data.first
    @to = data.last

    @chart[:step] = ChartCandy::Builder.get_step_from_interval(data[1] - data[0]) if not @chart[:step]

    @chart[:period] = ChartCandy::Builder.period @from, @to, step: @chart[:step]
  end

  def t(path, vars={})
    vars.reverse_merge! :default => ''

    I18n.translate("chart_candy.#{id.gsub('-', '_')}.#{path}", vars)
  end

  def title
    @chart[:title]
  end

  def to_json
    close_chart

    return @chart.to_json
  end

  def to_xls
    close_chart

    return ChartCandy::Builder::XlsBuilder.chart_to_xls @chart
  end
end
