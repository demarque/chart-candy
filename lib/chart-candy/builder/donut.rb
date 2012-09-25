class ChartCandy::Builder::Donut < ChartCandy::Builder::Base

  def initialize(id, options={})
    super

    @chart.merge! hole: [], label: t('label'), nature: 'donut', slices: [], show_label: true, value: t('value')
  end

  def add_hole_item(name, value)
    @chart[:hole] = [t('hole.title')].flatten if hole.empty?
    hole << t("hole.#{name}", value: value)
  end

  def add_slice(name, value, options={})
    options.reverse_merge! txt_vars: {}

    options[:txt_vars][:value] = value

    label_str = t("slices.#{name}.label", options[:txt_vars])
    tooltip = t("slices.#{name}.tooltip", options[:txt_vars])

    @chart[:slices] << { label: label_str, percent: 0, tooltip: tooltip, value: value }
  end

  def close_chart
    total = @chart[:slices].sum{ |s| s[:value] }

    @chart[:total] = { label: 'Total', value: total }

    @chart[:slices].each { |s| s[:percent] = (s[:value].to_f * 100 / total).round(2)  }
  end

  def hole
    @chart[:hole]
  end

  def show_label=(active)
    @chart[:show_label] = active
  end

  def show_label
    @chart[:show_label]
  end
end
