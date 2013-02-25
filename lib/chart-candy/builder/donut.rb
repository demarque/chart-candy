class ChartCandy::Builder::Donut < ChartCandy::Builder::Base

  def initialize(id, options={})
    super

    @chart.merge! hole: [], label: t('label'), nature: 'donut', slices: [], show_label: true, unit: :number, value: t('value')
  end

  def add_hole_item(name, value)
    @chart[:hole] = [t('hole.title')].flatten if hole.empty?
    hole << t("hole.#{name}", value: value)
  end

  def add_slice(name, value, options={})
    options.reverse_merge! txt_vars: {}

    return if value.to_i <= 0

    value = value.round(2) if money?
    valuef = money? ? format_money(value) : value

    options[:txt_vars][:value] = valuef

    label_str = t("slices.#{name}.label", options[:txt_vars])
    tooltip = t("slices.#{name}.tooltip", options[:txt_vars])

    @chart[:slices] << { label: label_str, percent: 0, tooltip: tooltip, value: value, valuef: valuef }
  end

  def close_chart
    total = @chart[:slices].sum{ |s| s[:value] }

    total = total.round(2) if money?

    @chart[:total] = { label: 'Total', value: total }

    fill_percents
  end

  def format_money(value)
    if value > 99
      "#{value.round} $"
    else
      sprintf("%0.02f", (value.to_f).round(0)).gsub('.', ',') + ' $'
    end
  end

  def hole
    @chart[:hole]
  end

  def money?
    @chart[:unit] == :money
  end

  def show_label=(active)
    @chart[:show_label] = active
  end

  def show_label
    @chart[:show_label]
  end

  def unit=(unit_sym)
    @chart[:unit] = unit_sym.to_sym if [:number, :money].include? unit_sym.to_sym
  end

  def unit
    @chart[:unit]
  end

  private

  def fill_percents
    @chart[:slices].each { |s| s[:percent] = (s[:value].to_f * 100 / @chart[:total][:value]).round(2) }
  end
end
