class ChartCandy::Builder::Line < ChartCandy::Builder::Base

  def initialize(id, options={})
    super

    @chart.merge! axis: {}, legend: nil, lines: [], nature: 'line', tooltip: true
  end

  def add_dot(dot, id, x_name, y_name)
    {
      x: dot[x_name],
      y: dot[y_name],
      label_x: add_dot_label(id, dot[x_name], @chart[:axis][:x][:nature]),
      label_y: add_dot_label(id, dot[y_name], @chart[:axis][:y][:nature])
    }
  end

  def add_dot_label(id, value, nature)
    case nature
      when :date then add_dot_label_date value
      when :money then add_dot_label_money value
      else value.to_s + ' ' + t("lines.#{id}.unit")
    end
  end

  def add_dot_label_date(date)
    case @chart[:step]
      when 'day' then l(date, format: :date_long)
      when 'week' then ChartCandy.translate('date.week') + ' ' + l(date, format: :date_long).strip
      when 'month' then l(date, format: :date_without_day).capitalize
      else l(date, format: :date_long)
    end
  end

  def add_dot_label_money(amount)
    sprintf("%0.02f", amount.round(2)).gsub('.', ',') + ' $'
  end

  def add_line(id, original_data, options={})
    options.reverse_merge! axis_y: "left", txt_vars: {}, key_x: "time", key_y: "value"

    data = original_data.map{ |d| add_dot(d, id, options[:key_x], options[:key_y]) }

    [:x, :y].each do |key|
      [:min, :max].each { |m| @chart[:axis][key][m] = to_money_format(@chart[:axis][key][m]) } if money? key
    end

    data = original_data.map do |d|
      [:key_x, :key_y].each { |key| d[options[key]] = to_money_format(d[options[key]]) if money?(key[-1,1]) }
      add_dot(d, id, options[:key_x], options[:key_y])
    end

    @chart[:lines] << { axis_y: options[:axis_y], data: data, label: t("lines.#{id}.label", options[:txt_vars]), unit: t("lines.#{id}.unit"), total: get_total(data) }
  end

  def add_x_axis(nature, original_data, options={})
    options.reverse_merge! key: "time"

    data = original_data.map{ |d| d[options[:key]] }

    set_period_from_data data if not @from and nature == :date

    @chart[:axis][:x] = { nature: nature, label: t("axis.x.label"), min: data.min, max: data.max, max_ticks: data.length }
  end

  def add_y_axis(nature, original_data, options={})
    options.reverse_merge! key: 'value', max: nil, min: nil

    data = original_data.map{ |d| d[options[:key]] }

    min = options[:min] ? options[:min] : data.min
    max = options[:max] ? options[:max] : data.max

    @chart[:axis][:y] = { nature: nature, label: t('axis.y.label'), min: min, max: max, max_ticks: data.length }
  end

  def close_chart
    super

    @chart[:legend] = (@chart[:lines].length > 1) if @chart[:legend].nil?
  end

  def date_based?
    @chart[:axis][:x] and @chart[:axis][:x][:nature] == :date
  end

  def get_total(data)
    { label: 'Total', value: data.sum{ |d| d[:y] } }
  end

  def legend=(active)
    @chart[:legend] = active
  end

  def legend
    @chart[:legend]
  end

  def money?(key)
    @chart[:axis][key.to_sym][:nature] == :money
  end

  def to_money_format(value)
    (BigDecimal.new(value) / 100).round(2)
  end

  def tooltip=(active)
    @chart[:tooltip] = active
  end

  def tooltip
    @chart[:tooltip]
  end
end
